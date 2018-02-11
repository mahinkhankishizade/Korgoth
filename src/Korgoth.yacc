// Define the tokens

%token ASSIGNMENT
%token DIGIT
%token SPACE
%token STRING
%token ALPHABETIC
%token ALPHANUMERIC
%token VARIABLE
%token SETVARIABLE
%token VECTORVARIABLE
%token INTEGER
%token FLOAT
%token LPARANTHESIS
%token RPARANTHESIS
%token LCURLYBRACE
%token RCURLYBRACE
%token LSQUAREBRACKET
%token RSQUAREBRACKET
%token COMMA
%token NEWLINE
%token SEMICOLON
%token ADDITION
%token SUBTRACTION
%token MULTIPLICATION
%token DIVISION
%token MODULO
%token CROSSPRODUCT
%token INCREMENT
%token DECREMENT
%token FACTORIAL
%token EXPONENT
%token ABSOLUTE
%token BOOLEAN
%token AND
%token OR
%token NOT
%token LESS
%token GREATER
%token LESSOREQUAL
%token GREATEROREQUAL
%token EQUAL
%token NOTEQUAL
%token MAINFUNCTION
%token FUNCTION
%token RETURN
%token FOR
%token WHILE
%token DO
%token IF
%token ELSE
%token TAKE
%token SHOW
%token UNION
%token INTERSECTION
%token COMBINATION
%token PERMUTATION
%token SINE
%token COSINE
%token TANGENT
%token COTANGENT
%token SECANT
%token COSECANT
%token ARCSINE
%token ARCCOSINE
%token ARCTANGENT
%token ARCCOTANGENT
%token MINIMUM
%token MAXIMUM
%token SQUAREROOT
%token NTHROOT
%token LOGN
%token LOG
%token PI
%token NATURALE
%token NONSTAR  
%token NONSTARNONDIV  
%token NONNEWLINE

// The union holding different values of the tokens is defined to show errors

%union 
{
    char * string;
    int integer;
}

// Define the token value types
%type <string> VARIABLE

// define associativity of operations
%left ADDITION SUBTRACTION // the order defines precedence, 
%left MULTIPLICATION DIVISION MODULO // so *, % and / has higher precedence than + and -
%left EXPONENT // ^ is the higest

%{ 
    #include <iostream> 
    #include <string>
    #include <set>
    using namespace std;
    
    extern int yylineno;
    void yyerror(string);
    int yylex(void);
    int errorCounter;
    set<string> var_symbols;
    set<string> defined_func_symbols;
    set<string> used_func_symbols;
    set<int> function_line_number;
    int current_line_number = -1;
    bool endOfProgram = false;
%}


%%
program :
    main_func program_tail |
    error {if(current_line_number != yylineno && !endOfProgram){yyerror("main function required");}current_line_number = yylineno;}

main_func :
    MAINFUNCTION LSQUAREBRACKET statements RSQUAREBRACKET {endOfProgram = true;}

program_tail :
    func program_tail|
    
func:
    FUNCTION VARIABLE LPARANTHESIS parameters RPARANTHESIS LSQUAREBRACKET statements function_return RSQUAREBRACKET {defined_func_symbols.insert(string($2));}

function_return:
    RETURN all_expressions SEMICOLON |

statements:
    statement statements |

statement:
    expression SEMICOLON |
    for_stmt |
    while_stmt |
    if_stmt |
    error
    
expression:
    func_call |
    special_function_call |
    assignment |
    
 
assignment:
    VARIABLE ASSIGNMENT arg {var_symbols.insert(string($1));} |
    SETVARIABLE ASSIGNMENT set_expression |
    VECTORVARIABLE ASSIGNMENT vector_expression |
    variable_def INCREMENT |
    variable_def DECREMENT

func_call:
    VARIABLE LPARANTHESIS arg_list RPARANTHESIS {used_func_symbols.insert(string($1)); function_line_number.insert(int(yylineno));}

special_function_call:
    SHOW LPARANTHESIS string_add RPARANTHESIS |
    SHOW LPARANTHESIS variable_def RPARANTHESIS |
    TAKE LPARANTHESIS VARIABLE RPARANTHESIS 

arg_list:
    arg arg_list_tail |
        
arg_list_tail:
    COMMA arg arg_list_tail |

arg:
    arithmetic_expression |
    boolean_expression |
    string_add |
    func_call
    
string_add:
    STRING string_tail
    
string_tail:
    ADDITION string_def |
    ADDITION operand |
    ADDITION bool_def |

arithmetic_expression:
    arithmetic_expression add_or_sub arithmetic_expression_lvl2 |
    arithmetic_expression_lvl2

arithmetic_expression_lvl2:
    arithmetic_expression_lvl2 mul_mod_div arithmetic_expression_lvl3 |
    arithmetic_expression_lvl3

arithmetic_expression_lvl3:
    arithmetic_expression_lvl3 EXPONENT factor |
    factor

factor:
    operand |
    LPARANTHESIS arithmetic_expression RPARANTHESIS |
    ABSOLUTE arithmetic_expression ABSOLUTE

add_or_sub:
    ADDITION |
    SUBTRACTION

mul_mod_div:
    MULTIPLICATION |
    MODULO |
    DIVISION

set_expression:
    set_expression union_or_intersection set_definition |
    set_definition 

union_or_intersection:
    UNION|
    INTERSECTION

vector_expression:
    vector_expression add_or_sub vector_priority_lvl2 |
    vector_priority_lvl2

vector_priority_lvl2:
    vector_priority_lvl2 MULTIPLICATION vector_priority_lvl3 |
    vector_priority_lvl3

vector_priority_lvl3:
    vector_priority_lvl3 CROSSPRODUCT vector_priority_lvl4 |
    vector_priority_lvl4

vector_priority_lvl4:
    vector_definition |
    LPARANTHESIS vector_expression RPARANTHESIS

operand:
    int_def |
    float_def |
    factorial_def |
    sine_function_def | 
    cosine_function_def |
    tangent_function_def |
    cotangent_function_def |
    secant_function_def |
    cosecant_function_def |
    arcsine_function_def |
    arccosine_function_def |
    arctangent_function_def |
    arccotangent_function_def |
    minimum_function_def |
    maximum_function_def |
    squareroot_function_def |
    nthroot_function_def |
    logn_function_def |
    log_function_def |
    combination_function_def |
    permutation_function_def |
    variable_def
    
parameters:
    VARIABLE parameters_tail {var_symbols.insert(string($1));} |
    
parameters_tail:
    COMMA VARIABLE parameters_tail {var_symbols.insert(string($2));} |

all_expressions:
    all_definitions|
    all_expressions COMMA all_definitions|
    all_expressions COMMA|

all_definitions:
    string_def|
    bool_def|
    vector_expression|
    arithmetic_expression|
    set_expression 


vector_definition:
    LESS arithmetic_expression COMMA arithmetic_expression GREATER |
    vector_name_def 

set_definition:
    LCURLYBRACE all_expressions RCURLYBRACE |
    set_name_def
 
string_def: 
    string_add 
    
int_def:
    INTEGER 

bool_def:
    BOOLEAN 

float_def:
    FLOAT |
    constant 

factorial_def:
    int_def FACTORIAL |
    variable_def FACTORIAL

variable_def:
    VARIABLE {if(var_symbols.count(string($1))==0) yyerror("variable \"" + string($1) + "\" is not defined");}

set_name_def:
    SETVARIABLE 
    
vector_name_def:
    VECTORVARIABLE 
      
boolean_expression:
    BOOLEAN condition_2 |
    arithmetic_expression boolean_operations condition_1 |
    LPARANTHESIS boolean_expression RPARANTHESIS condition_2 |
    NOT BOOLEAN condition_2 |
    NOT arithmetic_expression boolean_operations condition_1 |
    NOT LPARANTHESIS boolean_expression RPARANTHESIS condition_2

condition_1:
    BOOLEAN |
    arithmetic_expression |
    NOT BOOLEAN |
    NOT arithmetic_expression 


condition_2:
    boolean_operations condition_3 |

condition_3:
    boolean_expression |
    arithmetic_expression |
    NOT arithmetic_expression 

boolean_operations:
    AND |
    OR |
    LESS |
    GREATER |
    LESSOREQUAL |
    GREATEROREQUAL |
    EQUAL |
    NOTEQUAL

constant:
    PI |
    NATURALE

for_stmt:
    FOR LPARANTHESIS assignment SEMICOLON boolean_expression SEMICOLON assignment RPARANTHESIS LSQUAREBRACKET statements RSQUAREBRACKET

while_stmt:
    WHILE LPARANTHESIS boolean_expression RPARANTHESIS LSQUAREBRACKET statements RSQUAREBRACKET

if_stmt:
    IF LPARANTHESIS boolean_expression RPARANTHESIS LSQUAREBRACKET statements RSQUAREBRACKET else_stmt

else_stmt:
    ELSE LSQUAREBRACKET statements RSQUAREBRACKET |

sine_function_def:
    SINE LPARANTHESIS arithmetic_expression RPARANTHESIS

cosine_function_def:
    COSINE LPARANTHESIS arithmetic_expression RPARANTHESIS

tangent_function_def:
    TANGENT LPARANTHESIS arithmetic_expression RPARANTHESIS

cotangent_function_def:
    COTANGENT LPARANTHESIS arithmetic_expression RPARANTHESIS

secant_function_def:
    SECANT LPARANTHESIS arithmetic_expression RPARANTHESIS

cosecant_function_def:
    COSECANT LPARANTHESIS arithmetic_expression RPARANTHESIS

arcsine_function_def:
    ARCSINE LPARANTHESIS arithmetic_expression RPARANTHESIS

arccosine_function_def:
    ARCCOSINE LPARANTHESIS arithmetic_expression RPARANTHESIS

arctangent_function_def:
    ARCTANGENT LPARANTHESIS arithmetic_expression RPARANTHESIS

arccotangent_function_def:
    ARCCOTANGENT LPARANTHESIS arithmetic_expression RPARANTHESIS

minimum_function_def:
    MINIMUM LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS

maximum_function_def:
    MAXIMUM LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS

squareroot_function_def:
    SQUAREROOT LPARANTHESIS arithmetic_expression RPARANTHESIS

nthroot_function_def:
    NTHROOT LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS

logn_function_def:
    LOGN LPARANTHESIS arithmetic_expression RPARANTHESIS

log_function_def:
    LOG LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS

combination_function_def:
    COMBINATION LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS

permutation_function_def:
    PERMUTATION LPARANTHESIS arithmetic_expression COMMA arithmetic_expression RPARANTHESIS


%%

// report errors
extern int yylineno;

void yyerror(string s) 
{
	errorCounter++;
	cout << "Error occured at line " << yylineno << ": " << s << endl;
}


void funcCallCheck() 
{
    set<string>::iterator it;
    int count = 0;
    for (it = used_func_symbols.begin(); it != used_func_symbols.end(); ++it)
    {
         string tmp = *it;
         set<int>::iterator it3;
         int count2 = 0;
         int lineno = -1;
         for (it3 = function_line_number.begin(); it3 != function_line_number.end(); ++it3)
         {
            if(count == count2)
            {
                lineno = *it3;
                break;
            }
            count2++;
         }
        set<string>::iterator it2;
         bool stopFlag = false;
         for (it2 = defined_func_symbols.begin(); it2 != defined_func_symbols.end(); ++it2)
         {
            string tmp2 = *it2;
            if(tmp.compare(tmp2) == 0)
            {
                stopFlag = true;
                break;
            }
         }
         if(!stopFlag)
         {
            cout << "Error occured at line " << lineno << ": \"" << tmp << "\" is not defined!"  << endl;
            errorCounter++;
        }
        stopFlag = false;
         count++;
    }
}

int main()
{
	errorCounter=0;
	yyparse();
    funcCallCheck();
	if(errorCounter>0) {
		cout << "Parsing has been completed with " << errorCounter << " errors." <<endl;
	} else {
		cout << "Input program is working. It is written in KORGOTH correctly." <<endl;
	}
	return 0;
}


