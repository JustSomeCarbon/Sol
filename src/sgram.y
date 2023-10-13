/* Definitions */

%{
    #include <stdio.h>
    #include "tree.h"
    extern int yylex(void);
    extern void yyerror(char const *);

    struct tree* root;
%}

//%define parse.lac full      // required for verbose error reporting
//%define parse.error verbose // required for detailed error messages
%error-verbose

%union {
    struct tree* treeptr;
}

%token <treeptr> BOOLEAN INT FLOAT CHAR STRING SYMBOL HEADVAR TAILVAR
%token <treeptr> LITERALBOOL LITERALINT LITERALHEX LITERALFLOAT
%token <treeptr> LITERALCHAR LITERALSTRING LITERALSYMBOL FUNCTION
%token <treeptr> STRUCT ADD SUBTRACT MULTIPLY DIVIDE MODULO
%token <treeptr> ASSIGNMENT BAR ARROWOP RETURN DOT
%token <treeptr> EQUALTO LBRACE RBRACE LPAREN RPAREN
%token <treeptr> LBRACKET RBRACKET COMA COLON SEMICOLON MODSPACE
%token <treeptr> MAINFUNC IDENTIFIER USE DROPVAL
%token <treeptr> ISEQUALTO NOTEQUALTO LOGICALAND LOGICALOR NOT INCREMENT DECREMENT
%token <treeptr> GREATERTHANOREQUAL LESSTHANOREQUAL GREATERTHAN LESSTHAN

%type <treeptr> SourceSpace
%type <treeptr> SourceFile
%type <treeptr> ModDecl
%type <treeptr> UseDecl
%type <treeptr> ImportList
%type <treeptr> StructDecl
%type <treeptr> StructBody
%type <treeptr> StructParams
%type <treeptr> StructParam
%type <treeptr> FunctionDecl
%type <treeptr> FunctionHeader
%type <treeptr> FunctionBody
%type <treeptr> FunctionBodyDecls
%type <treeptr> FunctionBodyDecl
%type <treeptr> LocalNameCall
%type <treeptr> LocalNameDecl
%type <treeptr> SpaceFuncCall
%type <treeptr> PatternBlocks
%type <treeptr> PatternBlock
%type <treeptr> ModName
%type <treeptr> Type
%type <treeptr> Name
%type <treeptr> VarAssignment
%type <treeptr> StructVarDecl
%type <treeptr> StructVarParams
%type <treeptr> FormalParamListOpt
%type <treeptr> FormalParamList
%type <treeptr> FormalParam
%type <treeptr> ArgListOpt
%type <treeptr> ArgList
%type <treeptr> ArgVal
%type <treeptr> Primary
%type <treeptr> TuppleType
%type <treeptr> TuppleDecl
%type <treeptr> TuppleConst
%type <treeptr> TuppleConstVals
%type <treeptr> Literal
%type <treeptr> FieldAccess
%type <treeptr> Field
%type <treeptr> PostFixExpr
%type <treeptr> UnaryExpr
%type <treeptr> MultExpr
%type <treeptr> AddExpr
%type <treeptr> RelOp
%type <treeptr> RelExpr
%type <treeptr> EqExpr
%type <treeptr> CondAndExpr
%type <treeptr> CondOrExpr
%type <treeptr> ConcatExprs
%type <treeptr> ConcatExpr
%type <treeptr> Expr
%type <treeptr> AssignOp

%%

/* Rules */

/* -- Source File/Package -- */

SourceSpace: SourceFile { root = $1; }
;
SourceFile: SourceFile UseDecl {$$ = allocTree(SOURCE_FILE, "source_file", 2, $1, $2);}
    | SourceFile StructDecl    {$$ = allocTree(SOURCE_FILE, "source_file", 2, $1, $2);}
    | SourceFile FunctionDecl  {$$ = allocTree(SOURCE_FILE, "source_file", 2, $1, $2);}
    | ModDecl                  {$$ = allocTree(SOURCE_FILE, "source_file", 1, $1);}
;
ModDecl: MODSPACE COLON ModName SEMICOLON {$$ = allocTree(MOD_DECL, "mod_decl", 2, $1, $3);}
;
UseDecl: USE ModName SEMICOLON {$$ = allocTree(USE_DECL, "use_decl", 1, $2);}
    | USE ModName COLON LBRACE ImportList RBRACE SEMICOLON
    {$$ = allocTree(USE_DECL, "use_decl", 2, $2, $5);}
;
ImportList: ImportList COMA IDENTIFIER {$$ = allocTree(IMPORT_LIST, "import_list", 2, $1, $3);}
    | IDENTIFIER {$$ = allocTree(IMPORT_LIST, "import_list", 1, $1);}
;


/* -- Structure Definitions -- */

StructDecl: STRUCT IDENTIFIER LBRACE StructBody RBRACE SEMICOLON
    {$$ = allocTree(STRUCT_DECL, "struct_decl", 3, $1, $2, $4);}
;
StructBody: StructParams {$$ = allocTree(STRUCT_PARAMS, "struct_params", 1, $1);}
;
StructParams: StructParams StructParam {$$ = allocTree(STRUCT_PARAMS, "struct_params", 2, $1, $2);}
    | StructParam {$$ = allocTree(STRUCT_PARAMS, "struct_params", 1, $1);}
;
StructParam: IDENTIFIER Type SEMICOLON {$$ = allocTree(STRUCT_PARAM, "struct_param", 2, $1, $2);}


/* -- Function Definitions -- */

FunctionDecl: FunctionHeader FunctionBody
    {$$ = allocTree(FUNCTION_DECL, "function_decl", 2, $1, $2);}
;
FunctionHeader: FUNCTION IDENTIFIER Type LPAREN FormalParamListOpt RPAREN
    {$$ = allocTree(FUNCTION_HEADER, "function_header", 3, $2, $3, $5);}
    | FUNCTION MAINFUNC Type LPAREN FormalParamListOpt RPAREN
    {$$ = allocTree(FUNCTION_HEADER, "function_header", 2, $3, $5);}
;
FormalParamListOpt: FormalParamList
    {$$ = allocTree(FORMAL_PARAM_LIST_OPT, "formal_param_list_opt", 1, $1);}
    | {$$ = NULL;}
;
FormalParamList: FormalParam
    {$$ = allocTree(FORMAL_PARAM_LIST, "formal_param_list", 1, $1);}
    | FormalParamList COMA FormalParam  {$$ = allocTree(FORMAL_PARAM_LIST, "formal_param_list", 2, $1, $3);}
;
FormalParam: IDENTIFIER Type {$$ = allocTree(FORMAL_PARAM, "formal_param", 2, $1, $2);}
    | IDENTIFIER Name        {$$ = allocTree(FORMAL_PARAM, "formal_param", 2, $1, $2);}
    | LBRACKET HEADVAR BAR TAILVAR RBRACKET Type
    {$$ = allocTree(FORMAL_PARAM, "formal_param", 3, $2, $4, $6);}
;
ArgListOpt: ArgList {$$ = allocTree(ARG_LIST_OPT, "arg_list_opt", 1, $1);}
    | LPAREN RPAREN {$$ = NULL;}
;
ArgList: ArgList COMA ArgVal {$$ = allocTree(ARG_LIST, "arg_list", 2, $1, $3);}
    | ArgVal {$$ = allocTree(ARG_LIST, "arg_list", 1, $1);}
;
ArgVal: Expr      {$$ = allocTree(ARG_VAL, "arg_val", 1, $1);}
    | Name        {$$ = allocTree(ARG_VAL, "arg_val", 1, $1);}
    | Name Name   {$$ = allocTree(ARG_VAL, "arg_val", 2, $1, $2);}
    | TuppleConst {$$ = allocTree(ARG_VAL, "arg_val", 1, $1);}
;


/* -- Function Body Definitions -- */

FunctionBody: LBRACE FunctionBodyDecls RBRACE
    {$$ = allocTree(FUNCTION_BODY, "function_body", 1, $2);}
    | LBRACE RBRACE {/* nothing in function */}
;
FunctionBodyDecls: FunctionBodyDecls FunctionBodyDecl
    {$$ = allocTree(FUNCTION_BODY_DECLS, "function_body_decls", 2, $1, $2);}
    | FunctionBodyDecl {$$ = allocTree(FUNCTION_BODY_DECLS, "function_body_decls", 2, $1);}
;
FunctionBodyDecl: Expr SEMICOLON     {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $1);}
    | TuppleType SEMICOLON           {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $1);}
    | LocalNameCall SEMICOLON        {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $1);}
    | LBRACE PatternBlocks RBRACE    {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $2);}
    | RETURN Expr SEMICOLON          {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $2);}
    | RETURN TuppleType SEMICOLON    {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $2);}
    | RETURN LocalNameCall SEMICOLON {$$ = allocTree(FUNCTION_BODY_DECL, "function_body_decl", 1, $2);}
;
LocalNameCall: Name ArgListOpt {$$ = allocTree(LOCAL_NAME_CALL, "local_name_call", 2, $1, $2);}
    | Name SpaceFuncCall       {$$ = allocTree(LOCAL_NAME_CALL, "local_name_call", 2, $1, $2);}
    | LocalNameDecl            {$$ = allocTree(LOCAL_NAME_CALL, "local_name_call", 1, $1);}
    | Name                     {$$ = allocTree(LOCAL_NAME_CALL, "local_name_call", 1, $1);}
;
LocalNameDecl: Name VarAssignment {$$ = allocTree(LOCAL_NAME_DECL, "local_name_decl", 1, $1);}
    | DROPVAL VarAssignment       {$$ = allocTree(LOCAL_NAME_DECL, "local_name_decl", 1, $2);}
    | Name Name StructVarDecl     {$$ = allocTree(LOCAL_NAME_DECL, "local_name_decl", 3, $1, $2, $3);}
;
SpaceFuncCall: COLON LocalNameCall {$$ = allocTree(SPACE_FUNC_CALL, "space_func_call", 1, $2);}
;
PatternBlocks: PatternBlock          {$$ = allocTree(PATTERN_BLOCKS, "pattern_blocks", 1, $1);}
    | PatternBlocks BAR PatternBlock {$$ = allocTree(PATTERN_BLOCKS, "pattern_blocks", 2, $1, $3);}
;
PatternBlock: Expr ARROWOP FunctionBodyDecls
    {$$ = allocTree(PATTERN_BLOCK, "pattern_block", 2, $1, $3);}
;
ModName: IDENTIFIER {$$ = allocTree(MOD_NAME, "mod_name", 1, $1);}
;


/* -- Variable Definitions & Assignments -- */

VarAssignment: AssignOp ConcatExprs {$$ = allocTree(VAR_ASSIGNMENT, "var_assignment", 2, $1, $2);}
    | AssignOp TuppleType           {$$ = allocTree(VAR_ASSIGNMENT, "var_assignment", 2, $1, $2);}
    | AssignOp Expr                 {$$ = allocTree(VAR_ASSIGNMENT, "var_assignment", 2, $1, $2);}
    | AssignOp LocalNameCall        {$$ = allocTree(VAR_ASSIGNMENT, "var_assignment", 2, $1, $2);}
;
StructVarDecl: EQUALTO LBRACKET StructVarParams RBRACKET
    {$$ = allocTree(STRUCT_VAR_DECL, "struct_var_decl", 1, $3);}
;
StructVarParams: StructVarParams COMA Literal {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 2, $1, $3);}
    | StructVarParams COMA IDENTIFIER {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 2, $1, $3);}
    | StructVarParams COMA IDENTIFIER EQUALTO Literal
    {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 2, $1, $3);}
    | StructVarParams COMA IDENTIFIER EQUALTO IDENTIFIER
    {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 2, $1, $3);}
    | Literal    {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 1, $1);}
    | IDENTIFIER {$$ = allocTree(STRUCT_VAR_PARAMS, "struct_var_params", 1, $1);}
;


/* -- Operation and Name Definitions -- */

Name: FieldAccess {$$ = allocTree(NAME, "name", 1, $1);}
;
FieldAccess: Field               {$$ = allocTree(FIELD_ACCESS, "field_access", 1, $1);}
    | FieldAccess DOT IDENTIFIER {$$ = allocTree(FIELD_ACCESS, "field_access", 2, $1, $3);}
;
Field: IDENTIFIER {$$ = allocTree(FIELD, "field", 1, $1);}
;
CondOrExpr: CondAndExpr {$$ = allocTree(COND_OR_EXPR, "cond_or_expr", 1, $1);}
    | CondOrExpr LOGICALOR CondAndExpr {$$ = allocTree(COND_OR_EXPR, "cond_or_expr", 2, $1, $3);}
;
CondAndExpr: EqExpr {$$ = allocTree(COND_AND_EXPR, "cond_and_expr", 1, $1);}
    | CondAndExpr LOGICALAND EqExpr {$$ = allocTree(COND_AND_EXPR, "cond_and_expr", 2, $1, $3);}
;
EqExpr: RelExpr {$$ = allocTree(EQ_EXPR, "eq_expr", 1, $1);}
    | EqExpr ISEQUALTO RelExpr  {$$ = allocTree(EQ_EXPR, "eq_expr", 2, $1, $3);}
    | EqExpr NOTEQUALTO RelExpr {$$ = allocTree(EQ_EXPR, "eq_expr", 2, $1, $3);}
;
RelExpr: AddExpr {$$ = allocTree(REL_EXPR, "rel_expr", 1, $1);}
    | RelExpr RelOp AddExpr {$$ = allocTree(REL_EXPR, "rel_expr", 3, $1, $2, $3);}
;
RelOp: LESSTHANOREQUAL   {$$ = allocTree(REL_OP, "rel_op", 1, $1);}
    | GREATERTHANOREQUAL {$$ = allocTree(REL_OP, "rel_op", 1, $1);}
    | LESSTHAN           {$$ = allocTree(REL_OP, "rel_op", 1, $1);}
    | GREATERTHAN        {$$ = allocTree(REL_OP, "rel_op", 1, $1);}
;
AddExpr: MultExpr {$$ = allocTree(ADD_EXPR, "add_expr", 1, $1);}
    | AddExpr ADD MultExpr      {$$ = allocTree(ADD_EXPR, "add_expr", 1, $1);}
    | AddExpr SUBTRACT MultExpr {$$ = allocTree(ADD_EXPR, "add_expr", 1, $1);}
;
MultExpr: UnaryExpr {$$ = allocTree(MULT_EXPR, "mult_expr", 1, $1);}
    | MultExpr MULTIPLY UnaryExpr {$$ = allocTree(MULT_EXPR, "mult_expr", 2, $1, $3);}
    | MultExpr DIVIDE UnaryExpr   {$$ = allocTree(MULT_EXPR, "mult_expr", 2, $1, $3);}
    | MultExpr MODULO UnaryExpr   {$$ = allocTree(MULT_EXPR, "mult_expr", 2, $1, $3);}
;
UnaryExpr: SUBTRACT UnaryExpr {$$ = allocTree(UNARY_EXPR, "unary_expr", 1, $2);}
    | NOT UnaryExpr {$$ = allocTree(UNARY_EXPR, "unary_expr", 1, $2);}
    | PostFixExpr   {$$ = allocTree(UNARY_EXPR, "unary_expr", 1, $1);}
;
PostFixExpr: Primary {$$ = allocTree(POST_FIX_EXPR, "post_fix_expr", 1, $1);}
;
ConcatExprs: ConcatExprs BAR ConcatExpr {$$ = allocTree(CONCAT_EXPRS, "concat_exprs", 2, $1, $3);}
    | ConcatExpr {$$ = allocTree(CONCAT_EXPRS, "concat_exprs", 1, $1);}
;
ConcatExpr: LITERALSTRING BAR LITERALSTRING {$$ = allocTree(CONCAT_EXPR, "concat_expr", 2, $1, $3);}
    | LITERALSTRING BAR LITERALCHAR {$$ = allocTree(CONCAT_EXPR, "concat_expr", 2, $1, $3);}
    | LITERALCHAR BAR LITERALSTRING {$$ = allocTree(CONCAT_EXPR, "concat_expr", 2, $1, $3);}
    | LITERALCHAR BAR LITERALCHAR   {$$ = allocTree(CONCAT_EXPR, "concat_expr", 2, $1, $3);}
;
Expr: CondOrExpr {$$ = allocTree(EXPR, "expr", 1, $1);}
;
AssignOp: ASSIGNMENT {$$ = allocTree(ASSIGN_OP, "assign_op", 1, $1);}
    | INCREMENT  {$$ = allocTree(ASSIGN_OP, "assign_op", 1, $1);}
    | DECREMENT  {$$ = allocTree(ASSIGN_OP, "assign_op", 1, $1);}
;


/* -- Type Definitions -- */

Primary: Literal         {$$ = allocTree(PRIMARY, "primary", 1, $1);}
    | LPAREN Expr RPAREN {$$ = allocTree(PRIMARY, "primary", 1, $2);}
;
Type: INT         {$$ = allocTree(TYPE, "type", 1, $1);}
    | FLOAT       {$$ = allocTree(TYPE, "type", 1, $1);}
    | BOOLEAN     {$$ = allocTree(TYPE, "type", 1, $1);}
    | STRING      {$$ = allocTree(TYPE, "type", 1, $1);}
    | CHAR        {$$ = allocTree(TYPE, "type", 1, $1);}
    | SYMBOL      {$$ = allocTree(TYPE, "type", 1, $1);}
    | TuppleConst {$$ = allocTree(TYPE, "type", 1, $1);}
    | FUNCTION    {$$ = allocTree(TYPE, "type", 1, $1);}
    | LBRACKET Type RBRACKET    {$$ = allocTree(TYPE, "type", 1, $2);}
;
TuppleType: LBRACE TuppleDecl RBRACE {$$ = allocTree(TUPPLE_TYPE, "tupple_type", 1, $2);}
    | LBRACE RBRACE {/* nothing in function */}
;
TuppleDecl: TuppleDecl COMA Literal {$$ = allocTree(TUPPLE_DECL, "tupple_decl", 2, $1, $3);}
    | TuppleDecl COMA IDENTIFIER    {$$ = allocTree(TUPPLE_DECL, "tupple_decl", 2, $1, $3);}
    | Literal    {$$ = allocTree(TUPPLE_DECL, "tupple_decl", 1, $1);}
    | IDENTIFIER {$$ = allocTree(TUPPLE_DECL, "tupple_decl", 1, $1);}
;
TuppleConst: LPAREN TuppleConstVals RPAREN {$$ = allocTree(TUPPLE_CONST, "tupple_const", 1, $2);}
;
TuppleConstVals: TuppleConstVals COMA Type {$$ = allocTree(TUPPLE_CONST_VALS, "tupple_const_vals", 2, $1, $3);}
    | Type    {$$ = allocTree(TUPPLE_CONST, "tupple_const", 1, $1);}
;
Literal: LITERALINT {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALBOOL   {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALFLOAT  {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALHEX    {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALSTRING {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALCHAR   {$$ = allocTree(LITERAL, "literal", 1, $1);}
    | LITERALSYMBOL {$$ = allocTree(LITERAL, "literal", 1, $1);}
;

%%

/* Auxiliary Routines  */
// N/A
