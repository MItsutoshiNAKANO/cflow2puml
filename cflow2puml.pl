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

This script reads the output of the cflow command and converts it to
PlantUML format. The cflow command generates a call graph of C
functions, which this script processes to create a UML class diagram.
The script expects the cflow output.
The cflow output should be in the format:

    <indent>function() <return_type> function_name (arg1, arg2, ...) at file:line_number>
    <indent>function() <return_type> function_name (arg1, arg2, ...) at file:line_number>...

The script will read the cflow output from the specified file(s) or
from standard input if no file is specified.

The script will generate a PlantUML class diagram with the functions
as classes and the function calls as relationships between them.

The script will output the PlantUML class diagram to standard output.
The script uses the following format for the PlantUML class diagram:

    @startuml

    class function_name <<file:line_number>> {
      arg1
      arg2
      ...
    }

    function_name --> function_name
    ...

    @enduml

The script will also print the relationships between the functions in
the format:

    function_name --> function_name
    ...

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

=head1 CONSTANTS

The script uses the following constants:

=over

=item HELP

The help message for the script.

=item $VERSION

The version of the script.

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

    my ($funcs, $relations) = load_cflow($in);

Load the cflow output from the specified input file or standard input.
Returns a reference to a hash of functions and a reference to an array
of relationships between the functions.

The functions are stored in a hash with the function name as the key
and a hash reference as the value. The hash reference contains the
following keys:

=over

=item indent

The indentation level of the function in the cflow output.

=item ret

The return type of the function.

=item args

An array reference containing the arguments of the function.

=item file

The file where the function is defined.

=item line

The line number where the function is defined.

=item rest

The rest of the line from the cflow output.

=item printed

A flag indicating whether the function has been printed
in the PlantUML output.

=back

The relationships are stored in an array of hash references, each
containing the following keys:

=over

=item parent

The parent function name.

=item child

The child function name.

=back

The relationships are stored in the order they appear in the cflow
output.

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
            my @args = split /, /, $args;
            $funcs{$func} = {
                indent => $indent, ret => $ret, args => \@args, file => $file,
                line => $line, rest => $rest, printed => 0
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
    return (\%funcs, \@relations);
}
################################################################

=head1 SUBROUTINES FOR PRINTING PLANTUML

The following subroutines are used to print the functions and
classes in the PlantUML format.
The functions are printed only if they have not been printed
before. The functions are printed in the order of their
relationships. The classes are printed in the following format:

    class function_name <<file:line_number>> {
      arg1
      arg2
      ...
    }

The relationships are printed in the following format:

    function_name --> function_name

The relationships are printed in the order they appear in the
cflow output.
The functions are printed to the specified output file or
standard output. The classes are printed to the specified
output file or standard output. The classes are printed in
the order of their relationships.

=head2 print_func

    print_func($name, $funcs, $out);

Print the function with the specified name in the PlantUML format.
The function is printed to the specified output file or standard output.
The function is printed only if it has not been printed before.
The function is printed in the following format:

    class function_name <<file:line_number>> {
      arg1
      arg2
      ...
    }

=cut

sub print_func($name, $funcs, $out = *STDOUT) {
    my $func = $funcs->{$name};
    my ($file, $line, $arguments) = (
        $func->{file}, $func->{line}, $func->{args}
    );
    utf8::encode($func);
    utf8::encode($file);
    utf8::encode($line);
    say $out 'class ' . $name . ' <<' . $file . ':' . $line . '>> {';
    foreach my $arg (@$arguments) {
        utf8::encode($arg);
        say '  ' . $arg;
    }
    say "---\n}\n";
    ++$funcs->{$name}->{printed};
}

########################################

=head2 print_classes

    print_classes($relations, $funcs, $out);

Print the classes in the PlantUML format.
The classes are printed to the specified output file or standard
output.
The classes are printed in the order of their relationships.
The classes are printed in the following format:

    class function_name <<file:line_number>> {
      arg1
      arg2
      ...
    }

=cut

sub print_classes($relations, $funcs, $out = *STDOUT) {
    foreach my $relation (@$relations) {
        my ($parent, $child) = ($relation->{parent}, $relation->{child});
        if ($parent and not $funcs->{$parent}->{printed}) {
            print_func($parent, $funcs, $out);
        }
        unless ($funcs->{$child}->{printed}) {
            print_func($child, $funcs, $out);
        }
    }
}

########################################

=head2 print_relations

    print_relations($relations, $out);

Print the relationships between the functions in the PlantUML format.
The relationships are printed to the specified output file or standard
output. The relationships are printed in the order they appear in the
cflow output.

The relationships are printed in the following format:

    function_name --> function_name
    ...

=cut

sub print_relations($relations, $out = *STDOUT) {
    foreach my $relation (@$relations) {
        my ($parent, $child) = ($relation->{parent}, $relation->{child});
        utf8::encode($parent);
        utf8::encode($child);
        say $out $parent . ' --> ' . $child if $parent;
    }
}

################################################################

=head1 MAIN PROGRAM

The main program reads the cflow output from the specified input file
or standard input. The cflow output is read line by line and parsed
to extract the function names, return types, arguments, file names,
line numbers, and the rest of the line. The function names are stored
in a hash with the function name as the key and a hash reference
as the value. The hash reference contains the following keys:

=over

=item indent

The indentation level of the function in the cflow output.

=item ret

The return type of the function.

=item args

An array reference containing the arguments of the function.

=item file

The file where the function is defined.

=item line

The line number where the function is defined.

=item rest

The rest of the line from the cflow output.

=item printed

A flag indicating whether the function has been printed
in the PlantUML output.

=back

The relationships are stored in an array of hash references, each
containing the following keys:

=over

=item parent

The parent function name.

=item child

The child function name.

=back

The relationships are stored in the order they appear in the cflow
output.
The script will generate a PlantUML class diagram with the functions
as classes and the function calls as relationships between them.
The script will output the PlantUML class diagram to standard output.
The script uses the following format for the PlantUML class diagram:

    @startuml

    class function_name <<file:line_number>> {
      arg1
      arg2
      ...
    }

    function_name --> function_name
    ...

    @enduml

The script will also print the relationships between the functions in
the format:

    function_name --> function_name
    ...

=cut

getopts('t:', \my %opts) or die HELP;

say '@startuml';
if ($opts{t}) { say 'title ' . $opts{t} . "\n" } else { say '' }
my ($funcs, $relations) = load_cflow();
print_classes($relations, $funcs);
print_relations($relations);
say "\n" . '@enduml';

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
