#! /usr/bin/env perl

use Modern::Perl 2025;
use utf8;

use Readonly;
use English qw(-no_match_vars);
use Getopt::Std;
use Carp       qw(croak);
use List::Util qw(any);

=encoding utf8

=head1 NAME

cflow2puml.pl - Convert cflow output to PlantUML format

=head1 USAGE

    cflow2puml.pl [OPTIONS] OUTPUT.cflow...

=head1 OPTIONS

=over

=item B<-t> I<TITLE>

Set the title of the PlantUML diagram.

=item B<--help>

Show this help message and exit.

=item B<--version>

Show the version of the script and exit.

=back

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

=head1 EXAMPLE

    cflow2puml.pl output.cflow > output.puml

This command will read the cflow output from the file output.cflow
and write the PlantUML class diagram to the file output.puml.
The output will be in the PlantUML format, which can be used to
generate a UML class diagram.
The output can be viewed using the PlantUML tool or any other
compatible tool.

=head1 DIAGNOSTICS

The script will print error messages to standard error if it
encounters any issues while reading the input file or writing to
standard output.
The script will also print a help message if the user specifies
the B<--help> option or if the user specifies an invalid option.
The script will print the version of the script if the user
specifies the B<--version> option.
The script will croak if it cannot read the input file or write
to standard output.
The script will croak with the following messages:

    cannot print to STDOUT: ERROR_MESSAGE

=head2 EDQUOT

The user's quota of disk blocks on the filesystem
containing the file referred to by fd has been exhausted.

=head2 EFBIG

An attempt was made to write a file that exceeds the
implementation-defined maximum file size or the process's
file size limit, or to write at a position past the maximum
allowed offset.

=head2 EINTR

The call was interrupted by a signal before any data was written;
see signal(7).

=head2 EIO

A low-level I/O error occurred while modifying the inode.
This error may relate to the write-back of data written by
an earlier write(), which may have been issued to a
different file descriptor on the same file.  Since Linux
4.13, errors from write-back come with a promise that they
may be reported by subsequent.  write() requests, and will
be reported by a subsequent fsync(2) (whether or not they
were also reported by write()).  An alternate cause of EIO
on networked filesystems is when an advisory lock had been
taken out on the file descriptor and this lock has been
lost.  See the Lost locks section of fcntl(2) for further
details.

=head2 ENOSPC

The device containing the file referred to by fd has
no room for the data.

=head2 EPERM

The operation was prevented by a file seal; see fcntl(2).

=head2 EPIPE

STDOUT is connected to a pipe or socket whose reading end is
closed.  When this happens the writing process will also
receive a SIGPIPE signal.  (Thus, the write return value is
seen only if the program catches, blocks or ignores this
signal.)

=head1 EXIT STATUS

The script exits with the following status codes:

=over

=item 0) Success

=item 1) Error

=back

=head1 CONSTANTS

The script uses the following constants:

=head2 C<$HELP>

The help message for the script.

=head2 C<$VERSION>

The version of the script.

=head2 C<$Getopt::Std::STANDARD_HELP_VERSION>

see L<Getopt::Std>

=cut

Readonly my $HELP => <<"_END_OF_HELP_";
Usage: $PROGRAM_NAME [OPTIONS] [FILE1.cflow FILE2.cflow ...]
Options:
    -t TITLE
        Set the title of the PlantUML diagram.
    --help
        Show this help message and exit.
    --version
        Show the version of the script and exit.
_END_OF_HELP_

Readonly our $VERSION => '0.3.0-SNAPSHOT';
$Getopt::Std::STANDARD_HELP_VERSION = 1;

=head1 SUBROUTINES FOR HELP AND VERSION

The following subroutines are used to print the help message and
the version of the script.
The subroutine HELP_MESSAGE prints the help message and the
subroutine VERSION_MESSAGE prints the version of the script.
The subroutine HELP_MESSAGE is called when the user
specifies the B<--help> option
or when the user specifies an invalid option.
The subroutine VERSION_MESSAGE is called when the user
specifies the B<--version> option.

=head2 HELP_MESSAGE

The following subroutine is used to print the help message and
the version of the script.
The subroutine HELP_MESSAGE is called when the user
specifies the B<--help> option
or when the user specifies an invalid option.

=head2 VERSION_MESSAGE

The following subroutine is used to print the version of the script.
The subroutine VERSION_MESSAGE is called when the user
specifies the B<--version> option.

=cut

sub HELP_MESSAGE    { return print $HELP }
sub VERSION_MESSAGE { return say $VERSION }

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

sub load_cflow( $in = *ARGV ) {
    my ( %functions, @relations, @stack );
    while (<$in>) {
        utf8::decode($_);
        chomp;
        chomp;
        Readonly my $INDENT      => q{(?<indent>\s*)};
        Readonly my $FUNC        => q{(?<func>\w+)\(\)};
        Readonly my $DECLARATION => q{(?<ret>.*)\s(\w+)\s\((?<args>.*)\)};
        Readonly my $LOCATION    => q{(?<file>.*):(?<line>\d+)};
        if (m{\A$INDENT $FUNC \s <$DECLARATION \s at \s $LOCATION>}xms) {
            Readonly my $INDENT_SIZE => 4;
            my $depth = length( $LAST_PAREN_MATCH{indent} ) / $INDENT_SIZE;
            my @arguments = split m{,\s}xms, $LAST_PAREN_MATCH{args};
            my $func      = $LAST_PAREN_MATCH{func};
            $functions{$func} = {
                indent  => $depth,
                ret     => $LAST_PAREN_MATCH{ret},
                args    => \@arguments,
                file    => $LAST_PAREN_MATCH{file},
                line    => $LAST_PAREN_MATCH{line},
                printed => 0
            };
            if ( $depth < @stack ) { @stack = @stack[ 0 .. $depth - 1 ] }
            $stack[$depth] = $func;
            my $parent = $depth ? $stack[ $depth - 1 ] : q{};

            if ( not any { $_->{parent} eq $parent and $_->{child} eq $func }
                @relations )
            {
                push @relations, { parent => $parent, child => $func };
            }
        }
    }
    return { relations => \@relations, functions => \%functions };
}
################################################################

=head1 SUBROUTINES FOR MAKE OUTPUT FOR PLANTUML

The following subroutines are used to generate the PlantUML output
from the cflow output.
The subroutine make_func generates the PlantUML class definition
for a function.

=head2 make_func

    my @out = make_func($name, $functions);

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

sub make_func( $name, $functions ) {
    my $func = $functions->{$name};
    my ( $file, $line, $arguments )
        = ( $func->{file}, $func->{line}, $func->{args} );
    ++$functions->{$name}->{printed};
    my @out = ( 'class ', $name, q{ <<}, $file, q{:}, $line, '>> {', "\n" );
    foreach my $arg ( @{$arguments} ) { push @out, q{  }, $arg, "\n" }
    push @out, "  ---\n}\n\n";
    return @out;
}
########################################

=head2 make_classes

    my @out = make_classes($relations, $functions);

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

sub make_classes( $relations, $functions ) {
    my @out;
    foreach my $relation ( @{$relations} ) {
        my ( $parent, $child ) = ( $relation->{parent}, $relation->{child} );
        if ( $parent and not $functions->{$parent}->{printed} ) {
            push @out, make_func( $parent, $functions );
        }
        if ( not $functions->{$child}->{printed} ) {
            push @out, make_func( $child, $functions );
        }
    }
    return @out;
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
    foreach my $relation ( @{$relations} ) {
        my ( $parent, $child ) = ( $relation->{parent}, $relation->{child} );
        if ($parent) { push @out, $parent, ' --> ', $child, "\n" }
    }
    return @out;
}

=head2 make_diagram

    my @out = make_diagram($relations, $functions, $title = '');

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

sub make_diagram( $relations, $functions, $title = q{} ) {
    my @out = ( '@startuml', "\n" );
    if ($title) { push @out, 'title ', $title }
    push @out, "\n";
    push @out, make_classes( $relations, $functions );
    push @out, make_relations($relations);
    push @out, "\n", '@enduml', "\n";
    return @out;
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

getopts( 't:', \my %opts ) or croak $HELP;
my $hash_ref = load_cflow;
my $out      = join q{},
    make_diagram( $hash_ref->{relations}, $hash_ref->{functions}, $opts{t} );
utf8::encode($out);
print $out or croak 'cannot print to STDOUT:' . $OS_ERROR;

__END__

=head1 DEPENDENCIES

This script requires L<Modern::Perl> 2025,
L<Getopt::Std>, L<strict>, L<warnings>, and L<utf8>.
It also requires L<Readonly>, L<English>, L<Carp>, and L<List::Util>.

=head2 L<Modern::Perl>

For modern Perl features.

=head2 L<Getopt::Std>

For command-line option parsing.

=head2 L<strict>

For strict variable declaration.

=head2 L<warnings>

For warning messages.

=head2 L<utf8>

For handling UTF-8 encoding.

=head2 L<Readonly>

For defining read-only variables.

=head2 L<English>

For more readable variable names.

=head2 L<Carp>

For error handling.

=head2 L<List::Util>

For utility function C<any>.

=head1 AUTHOR

Mitsutoshi Nakano <ItSANgo@gmail.com>

=head1 LICENSE AND COPYRIGHT

2025 Mitsutoshi Nakano <ItSANgo@gmail.com>

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

=item L<https://metacpan.org/pod/Readonly>

For defining read-only variables.

=item L<https://metacpan.org/pod/English>

For more readable variable names.

=item L<https://metacpan.org/pod/Carp>

For error handling.

=item L<https://metacpan.org/pod/List::Util>

For utility function C<any>.

=item L<https://perldoc.perl.org/perlintro>

For more information on Perl.

=back
