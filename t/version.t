# This test instantiates tokens directly rather than through the
# tokenizer. It is up to the author of the test to be sure that the
# the contents of each token are consistent with its class. There is
# also the risk that tokens instantiated directly may be set up
# differently than theoretically-equivalent tokens generated by the
# tokenizer, in cases where __PPIX_TOKEN__recognize() is used.
#
# Caveat Auctor.

package main;

use 5.006002;

use strict;
use warnings;

BEGIN {
    eval {
	require Test::More;
	Test::More->VERSION( 0.40 );
	Test::More->import();
	1;
    } or do {
	print "1..0 # skip Test::More 0.40 required\\n";
	exit;
    }
}

use PPIx::Regexp::Constant qw{ MINIMUM_PERL };

sub class ($);
sub method (@);
sub token (@);

plan	tests => 367;

class	'PPIx::Regexp::Token::Assertion';
token	'^';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'$';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\b';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\B';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\A';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\Z';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\G';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\z';
method	perl_version_introduced => '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'\K';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Backreference';
token	'\1';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\g1';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\g{1}';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\g-1';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\g{-1}';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\k<foo>';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	q{\k'foo'};
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?P=foo)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Backtrack';
token	'(*ACCEPT)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::CharClass::POSIX';
token	'[:alpha:]';
method	perl_version_introduced	=> '5.006';		# perl56delta
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::CharClass::Simple';
token	'.';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\w';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\W';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\s';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\S';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\d';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\D';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\p{Latin}';
method	perl_version_introduced	=> '5.006001';		# perl561delta
method	perl_version_removed	=> undef;
token	'\h';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\H';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\v';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\V';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'\N';
method	perl_version_introduced => '5.011';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Code';
token	'{foo}';
method	perl_version_introduced	=> '5.005';	# see ::GroupType::Code
method	perl_version_removed	=> undef;
# The interesting version functionality is on
# PPIx::Regexp::Token::GroupType::Code.

class	'PPIx::Regexp::Token::Comment';
token	'(?#foo)';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'# foo';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Condition';
token	'(1)';
method	perl_version_introduced => '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'(R1)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(R)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(<foo>)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	q{('foo')};
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(R&foo)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(DEFINE)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Control';
token	'\l';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\u';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\L';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\U';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\E';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\Q';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Delimiter';
token	'/';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlsyn

class	'PPIx::Regexp::Token::Greediness';
token	'?';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'+';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

# PPIx::Regexp::Token::GroupType: see the individual subclasses, below.

class	'PPIx::Regexp::Token::GroupType::Assertion';
token	'?=';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'?!';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'?<=';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'?<!';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::BranchReset';
token	'?|';
method	perl_version_introduced	=> '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::Code';
token	'?p';
method	perl_version_introduced	=> '5.005';	# Undocumented that I can find.
						# Deprecated in 5.6.2.
method	perl_version_removed	=> '5.009005';
token	'?';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'??';
method	perl_version_introduced	=> '5.006';	# perl56delta
						# Not in 5.5.4 perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::Modifier';
token	'?:';
method	perl_version_introduced	=> MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'?i:';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'?i-x:';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::NamedCapture';
token	'?<foo>';
method	perl_version_introduced	=> '5.009005';
method	perl_version_removed	=> undef;
token	q{?'foo'};
method	perl_version_introduced	=> '5.009005';
method	perl_version_removed	=> undef;
token	'?P<foo>';
method	perl_version_introduced	=> '5.009005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::Subexpression';
token	'?>';
method	perl_version_introduced	=> '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::GroupType::Switch';
token	'?';
method	perl_version_introduced => '5.005';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Interpolation';
token	'$foo';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Literal';
token	'a';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\t';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\n';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\r';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\a';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\e';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\033';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\o{61}';
method	perl_version_introduced	=> '5.013003';
method	perl_version_removed	=> undef;
token	'\x1B';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\c[';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'\N{LATIN SMALL LETTER P}';
method	perl_version_introduced => '5.006';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Modifier';
token	'i';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	's';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'm';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'x';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'g';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlop
method	perl_version_removed	=> undef;
token	'o';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlop
method	perl_version_removed	=> undef;
token	'e';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlop
method	perl_version_removed	=> undef;
token	'c';
method	perl_version_introduced => '5.004';		# 5.4.5 perlop
method	perl_version_removed	=> undef;
token	'p';
method	perl_version_introduced => '5.009005';	# 5.9.5 perlop ( & !  5.9.4 )
method	perl_version_removed	=> undef;
token	'r';
method	perl_version_introduced => '5.013002';	# perl5132delta
method	perl_version_removed	=> undef;
token	'(?i)';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'(?i-x)';
method	perl_version_introduced => '5.005';	# 5.5.4 perldelta, perlre
method	perl_version_removed	=> undef;
token	'pi';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'pir';
method	perl_version_introduced => '5.013002';
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Operator';
token	'|';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'^';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'-';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

class	'PPIx::Regexp::Token::Quantifier';
token	'*';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'+';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'?';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

# TODO the quantifier {m,n} gets covered, if at all, under
# PPIx::Regexp::Token::Structure.

class	'PPIx::Regexp::Token::Recursion';
token	'(?1)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?+1)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?-1)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?R)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?&foo)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;
token	'(?P>foo)';
method	perl_version_introduced => '5.009005';
method	perl_version_removed	=> undef;

# PPIx::Regexp::Token::Reference is the parent of
# PPIx::Regexp::Token::Backreference, PPIx::Regexp::Token::Condition,
# and PPIX::Regexp::Token::Recursion. It has no separate tests.

class	'PPIx::Regexp::Token::Structure';
token	'(';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	')';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'{';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'}',	is_quantifier => 1;
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'[';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	']';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;
token	'm';
method	perl_version_introduced => MINIMUM_PERL;
method	perl_version_removed	=> undef;
token	'qr';
method	perl_version_introduced => '5.005';
method	perl_version_removed	=> undef;
# TODO if the quantifier {m,n} gets forms that are only legal for
# certain Perls, things may get sticky, but at the token level '}' is
# the one marked as a quantifier, so here's the starting point.

class	'PPIx::Regexp::Token::Whitespace';
token	' ';
method	perl_version_introduced => MINIMUM_PERL;	# 5.3.7 perlre
method	perl_version_removed	=> undef;

my $context;

BEGIN {
    $context = {};
}
sub class ($) {
    my ( $class ) = @_;
    $context->{class} = undef;
    my $title = "require $class";
    if ( eval "require $class; 1" ) {
	$context->{class} = $class;
	@_ = ( $title );
	goto &pass;
    } else {
	@_ = ( "$title: $@" );
	goto &fail;
    }
}

sub method (@) {
    my ( $method, @args ) = @_;

    SKIP: {
	defined $context->{object}
	    or skip 'No object defined', 1;

	my $want = pop @args;
	my $argtxt = @args ? ' ' . join( ', ', map { "'$_'" } @args
	    ) . ' ' : '';
	my $title;
	if ( defined $want ) {
	    $title = "$method($argtxt) is '$want'";
	} else {
	    $title = "$method($argtxt) is undef";
	}
	my $got;
	eval {
	    $got = $context->{object}->$method( @args );
	    1;
	} or do {
	    $title .= ": $@";
	    chomp $title;
	    @_ = ( $title );
	    goto &fail;
	};
	@_ = ( $got, $want, $title );
	goto &is;

    }
}

sub token (@) {
    my ( $content, %args ) = @_;

    SKIP: {
	defined $context->{class}
	    or skip 'No class defined', 1;

	my $title = "Instantiate $context->{class} with '$content'";
	$context->{object} = undef;
	if ( eval {
		my $obj = $context->{class}->_new( $content );
		$obj->can( '__PPIX_TOKEN__post_make' )
		    and $obj->__PPIX_TOKEN__post_make();
		$context->{object} = $obj;
	    } ) {
	    while ( my ( $name, $val ) = each %args ) {
		$context->{object}{$name} = $val;
	    }
	    @_ = ( $title );
	    goto &pass;
	} else {
	    $title .= ": $@";
	    chomp $title;
	    @_ = ( $title );
	    goto &fail;
	}
    }
}

1;

__END__

# ex: set textwidth=72 :
