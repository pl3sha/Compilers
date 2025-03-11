%{
#include <iostream>
#include <fstream>
#include <cstdio>
#include <string>

#include "Parser.h"
#include "CoolLexer.h"

#undef YY_DECL
#define YY_DECL int CoolLexer::yylex()

%}

white_space  [ \t]*
digit   [1-9][0-9]*
alpha   [A-Za-z]
alpha_num  ({alpha}|{digit}|_)
identifier  {alpha}{alpha_num}*
unsigned_integer ({digit}|[0])
string                  \"([^\"\n]|\\\n)*\"
bad_string              \"([^\"\n])*
hex_number  0[xX][0-9a-fA-F]+
oct_number  0[0-7]+
float_number  0\.[0-9]+([eE][+-]?[0-9]+)?|{digit}?"."{digit}+([eE][+-]?{digit}+)?

%x COMMENT

%option warn batch noyywrap c++
%option yylineno
%option yyclass="CoolLexer"

%%

--[^\n]*          { }

"(*"              { comment_level = 1; BEGIN(COMMENT); }
<COMMENT>"(*"     { comment_level++; }
<COMMENT>"*)"     { 
                     comment_level--; 
                     if (comment_level == 0) BEGIN(INITIAL); 
                 }
<COMMENT>\n       { lineno++; }
<COMMENT><<EOF>>  { Error("EOF in comment"); } 
<COMMENT>.        { }

class              return TOKEN_CLASS;
inherits           return TOKEN_INHERITS;
if                 return TOKEN_IF;
then               return TOKEN_THEN;
else               return TOKEN_ELSE;
fi                 return TOKEN_FI;
while              return TOKEN_WHILE;
loop               return TOKEN_LOOP;
pool               return TOKEN_POOL;
let                return TOKEN_LET;
in                 return TOKEN_IN;
case               return TOKEN_CASE;
esac               return TOKEN_ESAC;
new                return TOKEN_NEW;
isvoid             return TOKEN_ISVOID;
not                return TOKEN_NOT;
true               return TOKEN_TRUE;
false              return TOKEN_FALSE;
"<="               return TOKEN_LEQ;
">="               return TOKEN_GEQ;
"="                return TOKEN_EQ;
"<"                return TOKEN_LT;
">"                return TOKEN_GT;
"~"                return TOKEN_NEG;
"->"               return TOKEN_ARROW;

{unsigned_integer} return TOKEN_UNSIGNED_INTEGER;
{string}  return TOKEN_STRING;
{bad_string}  { Error("unterminated string"); }
{identifier}  return TOKEN_IDENTIFIER;
[*/+\-.,;:(){}\[\]] return yytext[0];
"@"                     return yytext[0];
"'"                     return yytext[0];
{white_space}  { }
\n   lineno++;
.|\n   { Error("unrecognized character"); }
{hex_number}  { Error("hex error"); }
{float_number}  { Error("float number incorrect"); }
{oct_number}  { Error("oct error"); }

%%

void CoolLexer::Error(const char* msg) const
{
    std::cerr << "Lexer error (line " << lineno + 1 << "): " << msg << ": lexeme '" << YYText() << "'\n";
    std::exit(YY_EXIT_FAILURE);
}