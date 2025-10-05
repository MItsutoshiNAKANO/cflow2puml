# NAME

cflow2puml.pl - Convert cflow output to PlantUML format

# USAGE

    cflow2puml.pl [OPTIONS] OUTPUT.cflow...

# OPTIONS

- **-t** _TITLE_

    Set the title of the PlantUML diagram.

- **--help**

    Show this help message and exit.

- **--version**

    Show the version of the script and exit.

# DESCRIPTION

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

# EXAMPLE

    cflow2puml.pl output.cflow > output.puml

This command will read the cflow output from the file output.cflow
and write the PlantUML class diagram to the file output.puml.
The output will be in the PlantUML format, which can be used to
generate a UML class diagram.
The output can be viewed using the PlantUML tool or any other
compatible tool.

# DIAGNOSTICS

The script will print error messages to standard error if it
encounters any issues while reading the input file or writing to
standard output.
The script will also print a help message if the user specifies
the **--help** option or if the user specifies an invalid option.
The script will print the version of the script if the user
specifies the **--version** option.
The script will croak if it cannot read the input file or write
to standard output.
The script will croak with the following messages:

    cannot print to STDOUT: ERROR_MESSAGE

## EDQUOT

The user's quota of disk blocks on the filesystem
containing the file referred to by fd has been exhausted.

## EFBIG

An attempt was made to write a file that exceeds the
implementation-defined maximum file size or the process's
file size limit, or to write at a position past the maximum
allowed offset.

## EINTR

The call was interrupted by a signal before any data was written;
see signal(7).

## EIO

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

## ENOSPC

The device containing the file referred to by fd has
no room for the data.

## EPERM

The operation was prevented by a file seal; see fcntl(2).

## EPIPE

STDOUT is connected to a pipe or socket whose reading end is
closed.  When this happens the writing process will also
receive a SIGPIPE signal.  (Thus, the write return value is
seen only if the program catches, blocks or ignores this
signal.)

# EXIT STATUS

The script exits with the following status codes:

- 0) Success
- Others: Failure

# CONSTANTS

The script uses the following constants:

## `HELP`

The help message for the script.

## `$VERSION`

The version of the script.

## `$Getopt::Std::STANDARD_HELP_VERSION`

see [Getopt::Std](https://metacpan.org/pod/Getopt%3A%3AStd)

# SUBROUTINES FOR HELP AND VERSION

The following subroutines are used to print the help message and
the version of the script.
The subroutine HELP\_MESSAGE prints the help message and the
subroutine VERSION\_MESSAGE prints the version of the script.
The subroutine HELP\_MESSAGE is called when the user
specifies the **--help** option
or when the user specifies an invalid option.
The subroutine VERSION\_MESSAGE is called when the user
specifies the **--version** option.

## HELP\_MESSAGE

The following subroutine is used to print the help message and
the version of the script.
The subroutine HELP\_MESSAGE is called when the user
specifies the **--help** option
or when the user specifies an invalid option.

## VERSION\_MESSAGE

The following subroutine is used to print the version of the script.
The subroutine VERSION\_MESSAGE is called when the user
specifies the **--version** option.

# SUBROUTINE FOR LOADING CFLOW OUTPUT

The following subroutine is used to load the cflow output from the
specified input file or standard input.
The cflow output is read line by line and parsed to extract the
function names, return types, arguments, file names, line numbers,
and the rest of the line.
The function names are stored in a hash with the function name as the
key and a hash reference as the value.

## load\_cflow

    $hash_ref = load_cflow($in);

The function load\_cflow() takes one argument: a file handle.

The function returns a hash reference with two keys:

- relations

    A reference to an array of relationships.

- functions

    A reference to a hash of functions.

The function reads the cflow output from the specified input file
or standard input and parses it to extract the function names,
return types, arguments, file names, line numbers, and the rest of
the line.
The function names are stored in a hash with the function name as
the key and a hash reference as the value.
The relationships are stored in an array of hash references,
each containing the parent and child function names.

# SUBROUTINES FOR MAKE OUTPUT FOR PLANTUML

The following subroutines are used to generate the PlantUML output
from the cflow output.
The subroutine make\_func generates the PlantUML class definition
for a function.

## make\_func

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

## make\_classes

    my @out = make_classes($relations, $functions);

The function make\_classes() generates the PlantUML classes
definitions for all the functions in the cflow output.
The function takes two arguments:

    a reference to an array of relationships and
    a reference to a hash of functions.

The function iterates over the relationships and generates the
PlantUML class definition for each function.
The function checks if the parent function has been printed
before generating the class definition for the child function.
The function returns an array of strings containing the PlantUML.

## make\_relations

    my @out = make_relations($relations);

The function make\_relations() generates the PlantUML
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

## make\_diagram

    my @out = make_diagram($relations, $functions, $title = '');

The function make\_diagram() generates the PlantUML diagram
for the cflow output.
The function takes three arguments:

    a reference to an array of relationships,
    a reference to a hash of functions, and
    an optional title for the diagram.

The function generates the PlantUML diagram using the
function make\_classes() and the function make\_relations().
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

# MAIN PROGRAM

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

# DEPENDENCIES

This script requires [Getopt::Std](https://metacpan.org/pod/Getopt%3A%3AStd), [strict](https://metacpan.org/pod/strict), [warnings](https://metacpan.org/pod/warnings), and [utf8](https://metacpan.org/pod/utf8).
It also requires [Readonly](https://metacpan.org/pod/Readonly), [English](https://metacpan.org/pod/English), [Carp](https://metacpan.org/pod/Carp), and [List::Util](https://metacpan.org/pod/List%3A%3AUtil).

## [Getopt::Std](https://metacpan.org/pod/Getopt%3A%3AStd)

For command-line option parsing.

## [strict](https://metacpan.org/pod/strict)

For strict variable declaration.

## [warnings](https://metacpan.org/pod/warnings)

For warning messages.

## [utf8](https://metacpan.org/pod/utf8)

For handling UTF-8 encoding.

## [Readonly](https://metacpan.org/pod/Readonly)

For defining read-only variables.

## [English](https://metacpan.org/pod/English)

For more readable variable names.

## [Carp](https://metacpan.org/pod/Carp)

For error handling.

## [List::Util](https://metacpan.org/pod/List%3A%3AUtil)

For utility function `any`.

# AUTHOR

Mitsutoshi Nakano <ItSANgo@gmail.com>

# LICENSE AND COPYRIGHT

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

# SEE ALSO

- [https://plantuml.com/class-diagram](https://plantuml.com/class-diagram)

    For more information on PlantUML class diagrams.

- [https://www.gnu.org/software/cflow/](https://www.gnu.org/software/cflow/)

    For more information on cflow.

- [https://metacpan.org/pod/Getopt::Std](https://metacpan.org/pod/Getopt::Std)

    For more information on Getopt::Std.

- [https://metacpan.org/pod/strict](https://metacpan.org/pod/strict)

    For more information on strict variable declaration.

- [https://metacpan.org/pod/warnings](https://metacpan.org/pod/warnings)

    For more information on warnings.

- [https://metacpan.org/pod/utf8](https://metacpan.org/pod/utf8)

    For more information on utf8 encoding.

- [https://metacpan.org/pod/Readonly](https://metacpan.org/pod/Readonly)

    For defining read-only variables.

- [https://metacpan.org/pod/English](https://metacpan.org/pod/English)

    For more readable variable names.

- [https://metacpan.org/pod/Carp](https://metacpan.org/pod/Carp)

    For error handling.

- [https://metacpan.org/pod/List::Util](https://metacpan.org/pod/List::Util)

    For utility function `any`.

- [https://perldoc.perl.org/perlintro](https://perldoc.perl.org/perlintro)

    For more information on Perl.
