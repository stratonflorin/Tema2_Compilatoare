%{
	#include <stdio.h>
	#include "y.tab.h"

	int lineNo = 1;
	int colNo = 1;
%}

%%
"PROGRAM"		{ colNo+=7; return TOKEN_PROG; }
"VAR"			{ colNo+=3; return TOKEN_VAR; }
"BEGIN"			{ colNo+=5; return TOKEN_BEGIN; }
"END"			{ colNo+=3; return TOKEN_END; }
[a-z][a-zA-Z0-9]*	{ yylloc.first_line = lineNo; 
			  yylloc.first_column = colNo; 
			  colNo+=strlen(yytext); 
			  yylval.string = new char[strlen(yytext)+1]; 
			  strcpy(yylval.string,yytext);
		          return TOKEN_ID; }
";"			{ colNo+=1; return ';'; }		
":"			{ colNo+=1; return ':'; }
"INTEGER"		{ colNo+=7; return TOKEN_TYPE_INTEGER; }
","			{ colNo+=1; return ','; }
":="			{ colNo+=1; return TOKEN_ASSIGN; }
"+"			{ colNo+=1; return TOKEN_PLUS; }
"-"			{ colNo+=1; return TOKEN_MINUS; }
"*"			{ colNo+=1; return TOKEN_MULTIPLY; }
"DIV"			{ colNo+=1; return TOKEN_DIVIDE; }
0|[1-9][0-9]*		{ yylloc.first_line = lineNo; 
			  yylloc.first_column = colNo; 
			  colNo+=strlen(yytext); 
			  yylval.string = new char[strlen(yytext)+1]; 
			  strcpy(yylval.string,yytext);
			  return TOKEN_VALUE; }
"("			{ colNo+=1; return TOKEN_LEFTB; }
")"			{ colNo+=1; return TOKEN_RIGHTB; }
"READ"			{ colNo+=4; return TOKEN_READ; }
"WRITE"			{ colNo+=5; return TOKEN_WRITE; }
"FOR"			{ colNo+=3; return TOKEN_FOR; }
"DO"			{ colNo+=2; return TOKEN_DO; }
"TO"			{ colNo+=2; return TOKEN_TO; }
\n			{ lineNo++; colNo=1; }
" "			{ colNo+=1; }
"\."			{ colNo+=1; return TOKEN_POINT; }
%%
