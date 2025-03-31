# NAME

cflow2puml.pl - Convert cflow output to PlantUML format

# SYNOPSIS

    cflow2puml.pl [OPTIONS] OUTPUT.cflow...
    Options:
        -t TITLE
            Set the title of the PlantUML diagram.
        --help
            Show this help message and exit.
        --version
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

# OPTIONS

- **-t** _TITLE_

    Set the title of the PlantUML diagram.

- **--help**

    Show this help message and exit.

- **--version**

    Show the version of the script and exit.

# EXAMPLE

    cflow2puml.pl output.cflow > output.puml

This command will read the cflow output from the file output.cflow
and write the PlantUML class diagram to the file output.puml.
The output will be in the PlantUML format, which can be used to
generate a UML class diagram.
The output can be viewed using the PlantUML tool or any other
compatible tool.

# CONSTANTS

The script uses the following constants:

- HELP

    The help message for the script.

- $VERSION

    The version of the script.

# SUBROUTINES FOR HELP AND VERSION

The following subroutines are used to print the help message and
the version of the script.
The subroutine HELP\_MESSAGE prints the help message and the
subroutine VERSION\_MESSAGE prints the version of the script.
The subroutine HELP\_MESSAGE is called when the user
specifies the --help option
or when the user specifies an invalid option.
The subroutine VERSION\_MESSAGE is called when the user
specifies the --version option.

## HELP\_MESSAGE

The following subroutine is used to print the help message and
the version of the script.
The subroutine HELP\_MESSAGE is called when the user
specifies the --help option
or when the user specifies an invalid option.

## VERSION\_MESSAGE

The following subroutine is used to print the version of the script.
The subroutine VERSION\_MESSAGE is called when the user
specifies the --version option.

# SUBROUTINE FOR LOADING CFLOW OUTPUT

The following subroutine is used to load the cflow output from the
specified input file or standard input.
The cflow output is read line by line and parsed to extract the
function names, return types, arguments, file names, line numbers,
and the rest of the line.
The function names are stored in a hash with the function name as the
key and a hash reference as the value.

## load\_cflow

    my ($funcs, $relations) = load_cflow($in);

Load the cflow output from the specified input file or standard input.
Returns a reference to a hash of functions and a reference to an array
of relationships between the functions.

The functions are stored in a hash with the function name as the key
and a hash reference as the value. The hash reference contains the
following keys:

- indent

    The indentation level of the function in the cflow output.

- ret

    The return type of the function.

- args

    An array reference containing the arguments of the function.

- file

    The file where the function is defined.

- line

    The line number where the function is defined.

- rest

    The rest of the line from the cflow output.

- printed

    A flag indicating whether the function has been printed
    in the PlantUML output.

The relationships are stored in an array of hash references, each
containing the following keys:

- parent

    The parent function name.

- child

    The child function name.

The relationships are stored in the order they appear in the cflow
output.

# SUBROUTINES FOR MAKE OUTPUT FOR PLANTUML

The following subroutines are used to generate the PlantUML output
from the cflow output.
The subroutine make\_func generates the PlantUML class definition
for a function.

## make\_func

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

    class FUNCTION_NAME <<source_file_name:line_number>> {
        ARGUMENTS
        ...
        ---
    }

The class definition is indented according to the indentation level
    of the function in the cflow output.
The class definition is printed only once for each function.

## make\_classes

    my @out = make_classes($relations, $funcs);

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
    my @out = make\_diagram($relations, $funcs, $title = '');

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

This script requires Perl 5.38 or later and the following modules:

- [Getopt::Std](https://metacpan.org/pod/Getopt%3A%3AStd)

    For command-line option parsing

- [v5.38](https://metacpan.org/pod/v5.38)

    For modern Perl features

- [strict](https://metacpan.org/pod/strict)

    For strict variable declaration

- [warnings](https://metacpan.org/pod/warnings)

    For warning messages

- [utf8](https://metacpan.org/pod/utf8)

    For handling UTF-8 encoding

# COPYRIGHT

2025 by Mitsutoshi Nakano <ItSANgo@gmail.com>

# LICENSE

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

- [https://perldoc.perl.org/perlintro](https://perldoc.perl.org/perlintro)

    For more information on Perl.
