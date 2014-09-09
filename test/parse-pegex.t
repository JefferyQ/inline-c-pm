use strict;
use lib (-e 't' ? 't' : 'test'), 'inc';
use TestML;
use TestInlineCBridge;

TestML->new(
    testml => do { local $/; <DATA> },
    bridge => 'TestInlineCBridge',
)->run;

__DATA__
%TestML 0.1.0
# local $TODO = 'Rigorous function definition and declaration tests not yet passing.';

*code.parse_pegex.dump == *code.parse_recdescent.dump

=== Basic def
--- code
void foo(int a, int b) {
    a + b;
}

=== Basic decl
--- code
void foo(int a, int b);

=== Basic decl, no identifiers
--- code
void foo(int,int);

=== char* param
--- code
void foo(char* ch) {
}

=== char* param decl
--- code
void foo(char* ch);

=== char * decl
--- code
void foo(char *);


=== char *param
--- code
void foo(char *ch) {
}

=== char** param
--- code
void foo( char** ch ) {
}

=== char* rv, char* param
--- code
char* foo(char* ch) {
  return ch;
}

=== const char*
--- code
const char* foo(const char* ch) {
  return ch;
}

=== char* const param
--- code
char* const foo(char * const ch ) {
  return ch;
}

=== const char* const param
--- code
const char* const foo(const char* const ch) {
  return ch;
}

=== const char* const no-id decl
--- code
const char * const foo( const char * const);

=== long int
--- code
long int foo( long int a ) {
  return a + a;
}

=== long long
--- code
long long foo ( long long a ) {
  return a + a;
}

=== long long int
--- code
long long int foo ( long long int a ) {
  return a + a;
}

=== unsigned long long int
--- code
unsigned long long int foo ( unsigned long long int abc ) {
  return abc + abc;
}

=== unsigned long long int decl no-id
--- code
unsigned long long int foo( unsigned long long int );

=== unsigned long long decl no-id
--- code
unsigned long long foo(unsigned long long);

=== unsigned int
--- code
unsigned int _foo ( unsigned int abcd ) {
  return abcd + abcd;
}

=== unsigned long
--- code
unsigned long _bar1( unsigned long abcd ) {
  return abcd + abcd;
}

=== unsigned
--- code
unsigned baz2(unsigned abcd) {
  return abcd+abcd;
}

=== unsigned decl no-id
--- code
unsigned baz2(unsigned);

=== Issue/27
--- code
void _dump_ptr(long d1, long d2, int use_long_output) {
    printf("hello, world! %d %d %d\n", d1, d2, use_long_output);
}
