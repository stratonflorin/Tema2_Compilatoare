%{
#include<stdio.h>
#include<string.h>

int yylex();
int OKstatus=1;
char mesage_err[50];
int yyerror(const char *mesage_err)
{
	OKstatus=0;
	printf("\e[1;31mError:%s\e[0m", mesage_err);
	return 0;
}
class simbols_table
{
	char *name;
	int initialized_status;
	simbols_table *next;
public:
	static simbols_table *head;
	static simbols_table *tail;

	simbols_table()
	{
		simbols_table::head=NULL;
		simbols_table::tail=NULL;
	}

	simbols_table(char *name)
	{
		this->name=new char[strlen(name)+1];
		strcpy(this->name, name);
		this->initialized_status=0;
		this->next=NULL;
	}
	
	bool found_simbol(char *name)
	{
		simbols_table *aux=simbols_table::head;
		while(aux)
		{
			if(!strcmp(aux->name, name))
			{
				return 1;
			}
			aux=aux->next;
		}
		return 0;
	}

	void add_simbol(char *name)
	{
		simbols_table *aux=new simbols_table(name);
		if(!simbols_table::head)
		{
			simbols_table::head=aux;
			simbols_table::tail=aux;
		}
		else
		{
			simbols_table::tail->next=aux;
			simbols_table::tail=aux;
		}
	}

	void initialize_simbol(char *name)
	{
		simbols_table *aux=simbols_table::head;
		while(aux)
		{
			if(!strcmp(aux->name, name))
			{
				aux->initialized_status=1;
				
			}
			aux=aux->next;
		}	
	}

	int initialized_status_verify(char *name)
	{
		simbols_table *aux=simbols_table::head;
		while(aux)
		{
			if(!strcmp(aux->name, name))
			{
				return aux->initialized_status;
			}
			aux=aux->next;
		}
		return 0;
	}
	
};
simbols_table *mytable=NULL;
simbols_table *simbols_table::head;
simbols_table *simbols_table::tail;
%}

%union 
{
	char *string;
	int status; 
}

%token <string> TOKEN_PROG TOKEN_VAR TOKEN_BEGIN TOKEN_END TOKEN_TYPE_INTEGER TOKEN_ASSIGN TOKEN_DIVIDE TOKEN_MULTIPLY TOKEN_PLUS TOKEN_MINUS TOKEN_LEFTB TOKEN_RIGHTB TOKEN_READ TOKEN_WRITE TOKEN_FOR TOKEN_DO TOKEN_TO TOKEN_POINT

%token <string> TOKEN_ID
%token <string> TOKEN_VALUE

%type <string> id_list factor term exp

%start progr

%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_MUTIPLY TOKEN_DIVIDE

%locations

%%

progr:
	TOKEN_PROG progr_name TOKEN_VAR dec_list TOKEN_BEGIN stmt_list TOKEN_END TOKEN_POINT
	|
	error
	{
		OKstatus=0;
	}
	;

progr_name:
	TOKEN_ID
	;
	
dec_list:
	dec_list ';' dec
	|
	dec
	;
dec:
	id_list ':' type
	{
		char *name=strtok($1, "&");
		while(name)
		{
			if(mytable->head)
			{
				if(mytable->found_simbol(name))
				{
					yyerror(mesage_err);
					printf(" %s:  \e[1;31mMultiple declaration of variable!\n\e[0m", name);
					
				}
				else
				{
					mytable->add_simbol(name);
				}
			}
			else
			{
				mytable->add_simbol(name);
			}
		name=strtok(NULL, "&");
		}
	}
	;

id_list:
	id_list ',' TOKEN_ID
	{
		strcat($$, "&");
		strcat($$, $3);
	}
	|
	TOKEN_ID
	;

type:
	TOKEN_TYPE_INTEGER
	;

stmt_list:
	stmt_list ';' stmt
	|
	stmt
	;

stmt:
	assign
	|
	read
	|
	write
	|
	for
	;

assign:
	TOKEN_ID TOKEN_ASSIGN exp
	{
		if(!mytable->found_simbol($1))
		{
			yyerror(mesage_err);
			printf(" %s:  \e[1;31mVariable undeclared!\n\e[0m", $1);
			
		}
		else
		{
			mytable->initialize_simbol($1);
		}
	}
	;

exp:
	exp TOKEN_PLUS term
	|
	exp TOKEN_MINUS term
	|
	term
	;

term:
	term TOKEN_MULTIPLY factor
	|
	term TOKEN_DIVIDE factor
	{
		if(!strcmp($3,"0"))
		{
			yyerror(mesage_err);
			printf(" %s %s %s:  \e[1;31mDevide to zero!\n\e[0m",$1,"DIV", $3);
			
		}
	}
	|
	factor
	;

factor:
	TOKEN_LEFTB exp TOKEN_RIGHTB
	|
	TOKEN_VALUE
	|
	TOKEN_ID
	{
		char *name=$1;
		
		if(!mytable->found_simbol(name))
		{
			yyerror(mesage_err);
			printf(" %s:  \e[1;31mVariable undeclared!\n\e[0m", name);
			
		}
		else
		{
			if(!mytable->initialized_status_verify(name))
			{
				yyerror(mesage_err);
				printf(" %s:  \e[1;31mVariable used without being initialized!\n\e[0m", name);
				
			}
		}
	}
	;

read:
	TOKEN_READ TOKEN_LEFTB id_list TOKEN_RIGHTB
	{
		char *name=strtok($3, "&");
		while(name)
		{
			if(!mytable->found_simbol(name))
			{
				yyerror(mesage_err);
				printf(" %s:  \e[1;31mVariable undeclared!\n\e[0m", name);
				
			}
			else
			{
				mytable->initialize_simbol(name);
			}
			name=strtok(NULL,"&");
		}
	}
	;

write:
	TOKEN_WRITE TOKEN_LEFTB id_list TOKEN_RIGHTB
	{
		char *name=strtok($3, "&");
		while(name)
		{
			if(!mytable->found_simbol(name))
			{
				
				yyerror(mesage_err);
				printf(" %s:  \e[1;31mVariable undeclared!\n\e[0m", name);
				
			}
			else
			{
				if(!mytable->initialized_status_verify(name))
				{	
					yyerror(mesage_err);
					printf(" %s:  \e[1;31mVariable used without being initialized!\n\e[0m", name);
					
				}
			}
			name=strtok(NULL,"&");
		}
	}
	;

for:
	TOKEN_FOR index_exp TOKEN_DO body
	;

index_exp:
	TOKEN_ID TOKEN_ASSIGN exp TOKEN_TO exp
	{
		char *name=$1;
		if(!mytable->found_simbol(name))
		{
			yyerror(mesage_err);
			printf(" %s:  \e[1;31mVariable undeclared!\n\e[0m", name);
			
		}
		else
		{
			mytable->initialize_simbol(name);
		}	
	}
	;

body:
	TOKEN_BEGIN stmt_list TOKEN_END
	|
	stmt
	;

%%

int main()
{
	yyparse();
	if(OKstatus==1)
	{
		printf("\e[1;32mAnalysis didn't return error! :)\n\e[0m");
	}
	return 1;
}

