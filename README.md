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

# SUBROUTINES FOR PRINTING PLANTUML

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

## print\_func

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

## print\_classes

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

## print\_relations

    print_relations($relations, $out);

Print the relationships between the functions in the PlantUML format.
The relationships are printed to the specified output file or standard
output. The relationships are printed in the order they appear in the
cflow output.

The relationships are printed in the following format:

    function_name --> function_name
    ...

# MAIN PROGRAM

The main program reads the cflow output from the specified input file
or standard input. The cflow output is read line by line and parsed
to extract the function names, return types, arguments, file names,
line numbers, and the rest of the line. The function names are stored
in a hash with the function name as the key and a hash reference
as the value. The hash reference contains the following keys:

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
