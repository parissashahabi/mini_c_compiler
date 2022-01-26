%{
	void yyerror(char* s);
	int yylex();
    int yyabort();
	#include "stdio.h"
	#include "stdlib.h"
	#include "ctype.h"
	#include "string.h"
	int flag=0;
	int flag2=0;

	#define ANSI_COLOR_RED		"\x1b[31m"
	#define ANSI_COLOR_GREEN	"\x1b[32m"
	#define ANSI_COLOR_CYAN		"\x1b[36m"
	#define ANSI_COLOR_RESET	"\x1b[0m"

	extern char curid[20];
	extern char curtype[20];
	extern char curval[20];

%}

%nonassoc IF
%token INT CHAR
%token RETURN MAIN
%token VOID
%token WHILE FOR 
%token BREAK CONTINUE
%expect 4

%token identifier
%token integer_constant string_constant off_limit_integer_constant

%nonassoc ELSEIF 
%nonassoc ELSE 
  
%right XOR_assignment_operator OR_assignment_operator
%right AND_assignment_operator
%right multiplication_assignment_operator division_assignment_operator
%right addition_assignment_operator subtraction_assignment_operator
%right assignment_operator

%left OR_operator
%left AND_operator
%left pipe_operator
%left caret_operator
%left amp_operator
%left equality_operator inequality_operator
%left lessthan_assignment_operator lessthan_operator greaterthan_assignment_operator greaterthan_operator
%left add_operator subtract_operator
%left multiplication_operator division_operator

%right exclamation_operator
%left increment_operator decrement_operator 


%start program

%%
program
			: declaration_list;

declaration_list
			: declaration D;

D
			: declaration_list
			| ;

declaration
			: variable_declaration 
			| function_declaration
            | main_function_declaration;

variable_declaration
			: type_specifier variable_declaration_list '.';

variable_declaration_list
			: variable_declaration_identifier V;

V
			: ',' variable_declaration_list 
			| ;

variable_declaration_identifier 
			: identifier vdi;

vdi 
            : assignment_operator expression 
            | ; 


type_specifier 
			: INT | CHAR
			| VOID ;

main_function_declaration
            : main_function_declaration_type main_function_declaration_param_statement;

main_function_declaration_type
            :type_specifier MAIN '(' {flag2=1;};

main_function_declaration_param_statement
            :')' statement;

function_declaration
			: function_declaration_type function_declaration_param_statement {if (flag2==1){yyerror("error");}};

function_declaration_type
			: type_specifier identifier '(' ;

function_declaration_param_statement
			: params ')' statement;

params 
			: parameters_list;

parameters_list 
			: /*type_specifier*/parameters_identifier_list;

parameters_identifier_list 
			: identifier
            | identifier ',' identifier
            | identifier ',' identifier ',' identifier;

statement 
			: expression_statment | compound_statement 
			| conditional_statements | iterative_statements 
			| return_statement | break_statement | continue_statement
			| variable_declaration;

compound_statement 
			: '{' statment_list '}' ;

statment_list 
			: statement statment_list 
			| ;

expression_statment 
			: expression '.' 
			| '.' ;

conditional_statements 
			: IF '(' simple_expression ')' statement conditional_statements_breakup;

conditional_statements_breakup
            : ELSEIF '(' simple_expression ')' statement conditional_statements_breakup
			| ELSE statement
			| ;

iterative_statements 
			: WHILE '(' simple_expression ')' statement 
			| FOR '(' INT expression ',' simple_expression ',' expression ')';

return_statement 
			: RETURN return_statement_breakup;

return_statement_breakup
			: '.' 
			| expression '.' ;

break_statement 
			: BREAK '.' ;

continue_statement
            : CONTINUE '.';

expression 
			: identifier expression_breakup
			| simple_expression ;

expression_breakup
			: assignment_operator expression 
			| addition_assignment_operator expression 
			| subtraction_assignment_operator expression 
			| multiplication_assignment_operator expression 
			| division_assignment_operator expression 
			| increment_operator 
			| decrement_operator ;

simple_expression 
			: and_expression simple_expression_breakup;

simple_expression_breakup 
			: OR_operator and_expression simple_expression_breakup | ;

and_expression 
			: unary_relation_expression and_expression_breakup;

and_expression_breakup
			: AND_operator unary_relation_expression and_expression_breakup
			| ;

unary_relation_expression 
			: exclamation_operator unary_relation_expression 
			| regular_expression ;

regular_expression 
			: sum_expression regular_expression_breakup;

regular_expression_breakup
			: relational_operators sum_expression 
			| ;

relational_operators 
			: greaterthan_assignment_operator | lessthan_assignment_operator | greaterthan_operator 
			| lessthan_operator | equality_operator | inequality_operator ;

sum_expression 
			: sum_expression sum_operators term 
			| term ;

sum_operators 
			: add_operator 
			| subtract_operator ;

term
			: term MULOP factor 
			| factor ;

MULOP 
			: multiplication_operator | division_operator ;

factor 
			: immutable | identifier ;

immutable 
			: '(' expression ')' 
			| call | constant;

call
			: identifier '(' arguments ')';

arguments 
			: arguments_list | ;

arguments_list 
			: expression A;

A
			: ',' expression A 
			| ;

constant 
			: integer_constant
            | off_limit_integer_constant {yyerror("The limit of integers was rejected");}
			| string_constant;

%%

extern FILE *yyin;
extern int yylineno;
extern char *yytext;

int main(int argc , char **argv)
{
	yyin = fopen(argv[1], "r");
	yyparse();

	if(flag == 0)
	{
		
	}
}

void yyerror(char *s)
{
	printf("%d %s %s\n", yylineno, s, yytext);
	flag=1;
	printf(ANSI_COLOR_RED "Status: Parsing Failed - Invalid\n" ANSI_COLOR_RESET);
}


int yywrap()
{
	return 1;
}