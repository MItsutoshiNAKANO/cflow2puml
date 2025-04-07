#! /usr/bin/env perl

use v5.38;
use strict;
use warnings;
use utf8;
use Getopt::Std;

=encoding utf8

=head1 NAME

cflow2puml.pl - Convert cflow output to PlantUML format

=head1 SYNOPSIS

    cflow2puml.pl [OPTIONS] OUTPUT.cflow...
    Options:
        -t TITLE
            Set the title of the PlantUML diagram.
        --help
            Show this help message and exit.
        --version
            Show the version of the script and exit.

=head1 DESCRIPTION

This script converts the output of cflow (a tool for generating
call graphs from C source code) to PlantUML format.

It reads the cflow output from the specified input file or standard
input and generates a PlantUML class diagram.
The output is written to standard output in the PlantUML format.

The script uses the Getopt::Std module for command-line option
parsing and the utf8 module for handling UTF-8 encoding.
The script is designed to be used with Perl 5.38 or later.

The script reads the cflow output line by line and parses it to
extract the function names, return types, arguments, file names,
line numbers, and the rest of the line.
The function names are stored in a hash with the function name as the
key and a hash reference as the value.
The relationships between the functions are stored in an array of
hash references, each containing the parent and child function names.
The relationships are stored in the order they appear in the cflow
output.
The script generates a PlantUML class diagram using the
function names, return types, arguments, file names, line numbers,
and the relationships between the functions.

=head1 OPTIONS

=over

=item B<-t> I<TITLE>

Set the title of the PlantUML diagram.

=item B<--help>

Show this help message and exit.

=item B<--version>

Show the version of the script and exit.

=back

=head1 EXAMPLE

    cflow2puml.pl output.cflow > output.puml

This command will read the cflow output from the file output.cflow
and write the PlantUML class diagram to the file output.puml.
The output will be in the PlantUML format, which can be used to
generate a UML class diagram.
The output can be viewed using the PlantUML tool or any other
compatible tool.

=head1 CONSTANTS

The script uses the following constants:

=over

=item HELP

The help message for the script.

=item $VERSION

The version of the script.

=item $Getopt::Std::STANDARD_HELP_VERSION = 1

    @see L<Getopt::Std

=back

=cut

use constant HELP => <<_END_OF_HELP_;
Usage: $0 [OPTIONS] [FILE1.cflow FILE2.cflow ...]
Options:
    -t TITLE
        Set the title of the PlantUML diagram.
    --help
        Show this help message and exit.
    --version
        Show the version of the script and exit.
_END_OF_HELP_

my $VERSION = '0.2.0-SNAPSHOT';
$Getopt::Std::STANDARD_HELP_VERSION = 1;

=head1 SUBROUTINES FOR HELP AND VERSION

The following subroutines are used to print the help message and
the version of the script.
The subroutine HELP_MESSAGE prints the help message and the
subroutine VERSION_MESSAGE prints the version of the script.
The subroutine HELP_MESSAGE is called when the user
specifies the --help option
or when the user specifies an invalid option.
The subroutine VERSION_MESSAGE is called when the user
specifies the --version option.

=head2 HELP_MESSAGE

The following subroutine is used to print the help message and
the version of the script.
The subroutine HELP_MESSAGE is called when the user
specifies the --help option
or when the user specifies an invalid option.

=head2 VERSION_MESSAGE

The following subroutine is used to print the version of the script.
The subroutine VERSION_MESSAGE is called when the user
specifies the --version option.

=cut

sub HELP_MESSAGE { print HELP }
sub VERSION_MESSAGE { say $VERSION }

=head1 SUBROUTINE FOR LOADING CFLOW OUTPUT

The following subroutine is used to load the cflow output from the
specified input file or standard input.
The cflow output is read line by line and parsed to extract the
function names, return types, arguments, file names, line numbers,
and the rest of the line.
The function names are stored in a hash with the function name as the
key and a hash reference as the value.

=head2 load_cflow

    $hash_ref = load_cflow($in);

The function load_cflow() takes one argument: a file handle.

The function returns a hash reference with two keys:

=over

=item relations

A reference to an array of relationships.

=item functions

A reference to a hash of functions.

=back

The function reads the cflow output from the specified input file
or standard input and parses it to extract the function names,
return types, arguments, file names, line numbers, and the rest of
the line.
The function names are stored in a hash with the function name as
the key and a hash reference as the value.
The relationships are stored in an array of hash references,
each containing the parent and child function names.

=cut

sub load_cflow($in = *ARGV) {
    my (%funcs, @relations, @stack);
    while (<$in>) {
        utf8::decode($_);
        chomp;
        chomp;
        if (/^( *)(\w+)\(\) <(.*) (\w+) \((.*)\) at (.*):(\d+)>(.*)$/) {
            my ($indent, $func, $ret, $func2, $args, $file, $line, $rest) = (
                length($1) / 4, $2, $3, $4, $5, $6, $7, $8
            );
            my @args_list = split /, /, $args;
            $funcs{$func} = {
                indent => $indent, ret => $ret, args => \@args_list,
                file => $file, line => $line, rest => $rest, printed => 0
            };
            if ($indent < @stack) { @stack = @stack[0 .. $indent - 1] }
            $stack[$indent] = $func;
            my $parent = $indent ? $stack[$indent - 1] : '';
            unless (
                grep {
                    $_->{parent} eq $parent and $_->{child} eq $func
                } @relations
            ) { push @relations, { parent => $parent, child => $func } }
        }
    }
    return { relations => \@relations, functions => \%funcs };
}
################################################################

=head1 SUBROUTINES FOR MAKE OUTPUT FOR PLANTUML

The following subroutines are used to generate the PlantUML output
from the cflow output.
The subroutine make_func generates the PlantUML class definition
for a function.

=head2 make_func

    my @out = make_func($name, $funcs);

Generates the PlantUML class definition for a function.
The function name is passed as the first argument and the hash of
functions is passed as the second argument.
The function returns an array of strings containing the PlantUML
class definition.
The class definition includes the function name, return type,
arguments, file name, line number, and the rest of the line.
The class definition is formatted according to the PlantUML
specification.
The function name is used as the class name and the return type
is used as the class stereotype.
The arguments are included in the class definition as attributes.
The file name and line number are included in the class definition
as notes.
The class definition is formatted as follows:

    class FUNCTION_NAME <<SOURCE_FILE_NAME:LINE_NUMBER>> {
        ARGUMENTS
        ...
        ---
    }

The class definition is indented according to the indentation level
    of the function in the cflow output.
The class definition is printed only once for each function.

=cut

sub make_func($name, $funcs) {
    my $func = $funcs->{$name};
    my ($file, $line, $arguments) = (
        $func->{file}, $func->{line}, $func->{args}
    );
    ++$funcs->{$name}->{printed};
    my @out = ('class ', $name, ' <<', $file, ':', $line , '>> {', "\n");
    foreach my $arg (@$arguments) { push @out, '  ', $arg, "\n" }
    push @out, "  ---\n}\n\n";
    @out;
}
########################################

=head2 make_classes

    my @out = make_classes($relations, $funcs);

The function make_classes() generates the PlantUML classes
definitions for all the functions in the cflow output.
The function takes two arguments:

    a reference to an array of relationships and
    a reference to a hash of functions.

The function iterates over the relationships and generates the
PlantUML class definition for each function.
The function checks if the parent function has been printed
before generating the class definition for the child function.
The function returns an array of strings containing the PlantUML.

=cut

sub make_classes($relations, $funcs) {
    my @out;
    foreach my $relation (@$relations) {
        my ($parent, $child) = ($relation->{parent}, $relation->{child});
        if ($parent and not $funcs->{$parent}->{printed}) {
            push @out, make_func($parent, $funcs);
        }
        unless ($funcs->{$child}->{printed}) {
            push @out, make_func($child, $funcs);
        }
    }
    @out;
}
########################################

=head2 make_relations

    my @out = make_relations($relations);

The function make_relations() generates the PlantUML
relationships for all the functions in the cflow output.
The function takes one argument:

    a reference to an array of relationships.

The function iterates over the relationships and generates the
PlantUML relationships for each function.
The function returns an array of strings containing the PlantUML
relationships.
The relationships are formatted as follows:

    PARENT_FUNCTION --> CHILD_FUNCTION

The relationships are printed only if the parent function is
defined.
The function returns an array of strings containing the PlantUML
relationships.
The relationships are formatted according to the PlantUML
specification.
The relationships are printed in the order they appear in the
cflow output.
The function checks if the parent function is defined before
generating the relationship.

=cut

sub make_relations($relations) {
    my @out;
    foreach my $relation (@$relations) {
        my ($parent, $child) = ($relation->{parent}, $relation->{child});
        push @out, $parent, ' --> ', $child, "\n" if $parent;
    }
    @out;
}

=head2 make_diagram

    my @out = make_diagram($relations, $funcs, $title = '');

The function make_diagram() generates the PlantUML diagram
for the cflow output.
The function takes three arguments:

    a reference to an array of relationships,
    a reference to a hash of functions, and
    an optional title for the diagram.

The function generates the PlantUML diagram using the
function make_classes() and the function make_relations().
The function returns an array of strings containing the PlantUML
diagram.
The diagram is formatted according to the PlantUML
specification.
The diagram includes the title, the class definitions for all
the functions, and the relationships between the functions.
The diagram is printed in the order they appear in the
cflow output.
The function checks if the title is defined before generating
the diagram.
The function returns an array of strings containing the PlantUML
diagram.
The diagram is formatted as follows:

    @startuml
    title TITLE

    CLASS_DEFINITIONS

    RELATIONSHIPS

    @enduml

The diagram is printed only once for each function.

=cut

sub make_diagram($relations, $funcs, $title = '') {
    my @out = ('@startuml', "\n");
    push @out, 'title ', $title, "\n" if $title;
    push @out, "\n";
    push @out, make_classes($relations, $funcs);
    push @out, make_relations($relations);
    push @out, "\n", '@enduml', "\n";
    @out;
}
################################################################

=head1 MAIN PROGRAM

The function checks if the title is defined before generating
the diagram.
The function returns an array of strings containing the PlantUML
diagram.
The diagram is formatted according to the PlantUML specification.
The diagram includes the title, the class definitions for all
the functions, and the relationships between the functions.
The diagram is printed in the order they appear in the cflow output.
The function checks if the title is defined before generating
the diagram.
The function returns an array of strings containing the PlantUML
diagram.
The diagram is formatted as follows:

    @startuml
    title TITLE

    CLASS_DEFINITIONS

    RELATIONSHIPS

    @enduml

The diagram is printed only once for each function.
The script uses the Getopt::Std module for command-line option
parsing and the utf8 module for handling UTF-8 encoding.
The script is designed to be used with Perl 5.38 or later.
The script reads the cflow output from the specified input file
or standard input and generates a PlantUML class diagram.
The output is written to standard output in the PlantUML format.

=cut

getopts('t:', \my %opts) or die HELP;
my $hash_ref = load_cflow();
my $out = join '', make_diagram(
    $hash_ref->{relations}, $hash_ref->{functions}, $opts{t}
);
utf8::encode($out);
print $out;

__END__

=head1 DEPENDENCIES

This script requires Perl 5.38 or later and the following modules:

=over

=item L<Getopt::Std>

For command-line option parsing

=item L<v5.38>

For modern Perl features

=item L<strict>

For strict variable declaration

=item L<warnings>

For warning messages

=item L<utf8>

For handling UTF-8 encoding

=back

=head1 COPYRIGHT

2025 by Mitsutoshi Nakano <ItSANgo@gmail.com>

=head1 LICENSE

SPDX-License-Identifier: Apache-2.0

This program is free software; you can redistribute it and/or modify
it under the terms of the Apache License, Version 2.0.
You may obtain a copy of the License at

    <http://www.apache.org/licenses/LICENSE-2.0>

This program is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 SEE ALSO

=over

=item L<https://plantuml.com/class-diagram>

For more information on PlantUML class diagrams.

=item L<https://www.gnu.org/software/cflow/>

For more information on cflow.

=item L<https://metacpan.org/pod/Getopt::Std>

For more information on Getopt::Std.

=item L<https://metacpan.org/pod/strict>

For more information on strict variable declaration.

=item L<https://metacpan.org/pod/warnings>

For more information on warnings.

=item L<https://metacpan.org/pod/utf8>

For more information on utf8 encoding.

=item L<https://perldoc.perl.org/perlintro>

For more information on Perl.

=back
