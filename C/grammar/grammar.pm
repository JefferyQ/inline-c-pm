package Inline::C::grammar;

use strict;

$Inline::C::grammar::VERSION = '0.30';

sub grammar {
    <<'END';

code:	part(s) {1}

part:	  comment
	| function_definition
	{
	 my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
	 push @{$thisparser->{data}{functions}}, $function;
	 $thisparser->{data}{function}{$function}{return_type} = 
             $item[1][1];
	 $thisparser->{data}{function}{$function}{arg_types} = 
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
	 $thisparser->{data}{function}{$function}{arg_names} = 
             [map {ref $_ ? $_->[1] : '...'} @{$item[1][2]}];
	}
	| function_declaration
	{
         $return = 1, last unless $thisparser->{data}{AUTOWRAP};
	 my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
         my $dummy = 'arg1';
	 push @{$thisparser->{data}{functions}}, $function;
	 $thisparser->{data}{function}{$function}{return_type} = 
             $item[1][1];
         $thisparser->{data}{function}{$function}{arg_types} = 
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
	 $thisparser->{data}{function}{$function}{arg_names} = 
             [map {ref $_ ? ($_->[1] || $dummy++) : '...'} @{$item[1][2]}];
	}
	| anything_else

comment:  m{\s* // [^\n]* \n }x
	| m{\s* /\* (?:[^*]+|\*(?!/))* \*/  ([ \t]*)? }x

function_definition:
	rtype IDENTIFIER '(' <leftop: arg ',' arg>(s?) ')' '{'
	{[@item[2,1], $item[4]]}

function_declaration:
	rtype IDENTIFIER '(' <leftop: arg_decl ',' arg_decl>(s?) ')' ';'
	{[@item[2,1], $item[4]]}

arg:	  type IDENTIFIER {[@item[1,2]]}
	| '...'

arg_decl: type IDENTIFIER(s?) {[$item[1], $item[2][0] || '']}
	| '...'

# P::RD is stupid in one case: if you "inline" the type or rtype rules, then
# if the first fails to match, it gives up on the whole rule. If you use
# different rules explicitly, as written, it will backtrack to the parent rule
# and then go on to the next -- exactly the behaviour it _should_ have in the
# first place.
type: type2 | type1
type1:  TYPE star(s?)
        {
         $return = $item[1];
         $return .= join '',' ',@{$item[2]} if @{$item[2]};
         return undef unless (defined $thisparser->{data}{typeconv}{valid_types}{$return});
        }
type2: modifier(s) TYPE star(s?)
	{
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return if @{$item[1]};
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}{valid_types}{$return});
	}

rtype: rtype2 | rtype1
rtype1: TYPE star(s?)
        {
         $return = $item[1];
         $return .= join '',' ',@{$item[2]} if @{$item[2]};
         return undef unless (defined $thisparser->{data}{typeconv}{valid_rtypes}{$return});
        }
rtype2: modifier(s) TYPE star(s?)
	{
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return 
           if @{$item[1]} and $item[1][0] ne 'extern';
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}{valid_rtypes}{$return});
	}

modifier: 'unsigned' | 'long' | 'extern' | 'struct'

star: '*'

# IDENTIFIER: /[a-z]\w*/i
IDENTIFIER: /\w+/

TYPE: /\w+/

anything_else: /.*/

END
}

1;
