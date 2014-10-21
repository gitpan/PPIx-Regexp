package main;

use strict;
use warnings;

use lib qw{ inc };

use PPI::Document;
use PPIx::Regexp::Test;
use PPIx::Regexp::Constant qw{ MINIMUM_PERL };
use Scalar::Util qw{ refaddr };

my $is_ascii = ord( "\t" ) == 9;	# per perlebcdic

my $have_charnames;

BEGIN {
    eval {
	require charnames;
	charnames->import( qw{ :full } );
	$have_charnames = charnames->can( 'vianame' );
    };
}

tokenize( {}, '-notest' ); # We don't know how to tokenize a hash reference.
equals  ( undef, 'We did not get an object' );
value   ( errstr => [], 'HASH not supported' );

parse   ( {}, '-notest' ); # If we can't tokenize it, we surely can't parse it.
equals  ( undef, 'We did not get an object' );
value   ( errstr => [], 'HASH not supported' );

parse   ( 'fubar' );	# We can't make anything of this.
value   ( failures => [], 1 );
class   ( 'PPIx::Regexp' );
value   ( capture_names => [], undef );
value   ( max_capture_number => [], undef );
value   ( source => [], 'fubar' );

{

    # The navigation tests get done in their own local scope so that all
    # the object references we have held go away when we are done.

    parse   ( '/ ( 1 2(?#comment)) /x' );
    value   ( failures => [], 0 );
    value   ( errstr => [], undef );
    class   ( 'PPIx::Regexp' );
    value   ( elements => [], 3 );

    choose  ( first_element => [] );
    class   ( 'PPIx::Regexp::Token::Structure' );
    content ( '' );

    choose  ( last_element => [] );
    class   ( 'PPIx::Regexp::Token::Modifier' );
    content ( 'x' );

    choose  ( tokens => [] );
    count   ( 13 );
    navigate( 7 );
    class   ( 'PPIx::Regexp::Token::Literal' );
    content ( '2' );

    my $lit1 = choose( find_first => 'Token::Literal' );
    class   ( 'PPIx::Regexp::Token::Literal' );
    content ( '1' );
    true    ( significant => [] );
    false   ( whitespace => [] );
    false   ( comment => [] );

    navigate( next_sibling => [] );
    class   ( 'PPIx::Regexp::Token::Whitespace' );
    content ( ' ' );
    false   ( significant => [] );
    true    ( whitespace => [] );
    false   ( comment => [] );

    my $lit2 = navigate( next_sibling => [] );
    class   ( 'PPIx::Regexp::Token::Literal' );
    content ( '2' );

    navigate( previous_sibling => [] );

    navigate( previous_sibling => [] );
    equals  ( $lit1, 'Two previouses undo two nexts' );

    navigate( snext_sibling => [] );
    equals  ( $lit2, 'A snext gets us the next significant token' );

    navigate( sprevious_sibling => [] );
    equals  ( $lit1, 'An sprevious gets us back' );

    navigate( previous_sibling => [] );
    equals  ( undef, 'Nobody before the first literal' );

    navigate( $lit2, next_sibling => [] );
    class   ( 'PPIx::Regexp::Token::Comment' );
    content ( '(?#comment)' );
    false   ( significant => [] );
    false   ( whitespace => [] );
    true    ( comment => [] );

    navigate( next_sibling => [] );
    equals  ( undef, 'Nobody after second whitespace' );

    navigate( $lit2, snext_sibling => [] );
    equals  ( undef, 'Nobody significant after second literal' );

    navigate( $lit1, sprevious_sibling => [] );
    equals  ( undef, 'Nobody significant before first literal' );

    navigate( $lit1, parent => [] );
    class   ( 'PPIx::Regexp::Structure::Capture' );

    my $top = navigate( top => [] );
    class   ( 'PPIx::Regexp' );
    true    ( ancestor_of => $lit1 );
    true    ( contains    => $lit1 );
    false   ( ancestor_of => undef );

    navigate( $lit1 );
    true    ( descendant_of => $top );
    false   ( descendant_of => $lit2 );
    false   ( ancestor_of   => $lit2 );
    false   ( descendant_of => undef );

    choose  ( find => 'Token::Literal' );
    count   ( 2 );
    navigate( -1 );
    equals  ( $lit2, 'The last literal is the second one' );

    choose  ( find_parents => 'Token::Literal' );
    count   ( 1 );

    my $capt = navigate( 0 );
    class   ( 'PPIx::Regexp::Structure::Capture' );
    value   ( elements => [], 7 );
    value   ( name => [], undef );

    navigate( $capt, first_element => [] );
    class   ( 'PPIx::Regexp::Token::Structure' );
    content ( '(' );

    navigate( $capt, last_element => [] );
    class   ( 'PPIx::Regexp::Token::Structure' );
    content ( ')' );

    navigate( $capt, schildren => [] );
    count   ( 2 );
    navigate( 1 );
    class   ( 'PPIx::Regexp::Token::Literal' );
    content ( '2' );

    choose  ( find => sub {
	    ref $_[1] eq 'PPIx::Regexp::Token::Literal'
		or return 0;
	    $_[1]->content() eq '2'
		or return 0;
	    return 1;
	} );
    count   ( 1 );
    navigate( 0 );
    equals  ( $lit2, 'We found the second literal again' );

    navigate( parent => [], schild => 1 );
    equals  ( $lit2, 'The second significant child is the second literal' );

    navigate( parent => [], schild => -2 );
    equals  ( $lit1, 'The -2nd significant child is the first literal' );

    choose  ( previous_sibling => [] );
    equals  ( undef, 'The top-level object has no previous sibling' );

    choose  ( sprevious_sibling => [] );
    equals  ( undef, 'The top-level object has no significant previous sib' );

    choose  ( next_sibling => [] );
    equals  ( undef, 'The top-level object has no next sibling' );

    choose  ( snext_sibling => [] );
    equals  ( undef, 'The top-level object has no significant next sibling' );

    choose  ( find => [ {} ] );
    equals  ( undef, 'Can not find a hash reference' );

    navigate( $lit2 );
    value   ( nav => [], [ child => [1], child => [0], child => [2] ] );

}

SKIP: {

    # The cache tests get done in their own scope to ensure the objects
    # are destroyed.

    my $num_tests = 8;
    my $doc = PPI::Document->new( \'m/foo/smx' )
	or skip( 'Failed to create PPI::Document', $num_tests );
    my $m = $doc->find_first( 'PPI::Token::Regexp::Match' )
	or skip( 'Failed to find PPI::Token::Regexp::Match', $num_tests );

    my $o1 = PPIx::Regexp->new_from_cache( $m );
    my $o2 = PPIx::Regexp->new_from_cache( $m );

    equals( $o1, $o2, 'new_from_cache() same object' );

    cache_count( 1 );

    PPIx::Regexp->flush_cache( 42 );	# Anything not a PPIx::Regexp

    cache_count( 1 );			# Nothing happens

    my $o9 = PPIx::Regexp->new_from_cache( '/foo/' );

    cache_count( 1 );			# Not cached.

    $o9->flush_cache();

    cache_count( 1 );			# Not flushed, either.

    PPIx::Regexp->flush_cache();

    cache_count();

    $o1 = PPIx::Regexp->new_from_cache( $m );

    cache_count( 1 );

    $o1->flush_cache();

    cache_count();

}

SKIP: {

    # More cache tests, in their own scope not only to ensure object
    # destruction, but so $DISABLE_CACHE can be localized.

    local $PPIx::Regexp::DISABLE_CACHE = 1;

    my $num_tests = 2;
    my $doc = PPI::Document->new( \'m/foo/smx' )
	or skip( 'Failed to create PPI::Document', $num_tests );
    my $m = $doc->find_first( 'PPI::Token::Regexp::Match' )
	or skip( 'Failed to find PPI::Token::Regexp::Match', $num_tests );

    my $o1 = PPIx::Regexp->new_from_cache( $m );
    my $o2 = PPIx::Regexp->new_from_cache( $m );

    different( $o1, $o2, 'new_from_cache() same object, cache disabled' );

    cache_count();	# Should still be nothing in cache.

}

tokenize( '/\\n\\04\\xff\\x{0c}\\N{LATIN SMALL LETTER E}\\N{U+61}/' );
count   ( 10 );
choose  ( 2 );
value   ( ordinal => [], ord "\n" );
choose  ( 3 );
value   ( ordinal => [], ord "\04" );
choose  ( 4 );
value   ( ordinal => [], ord "\xff" );
choose  ( 5 );
value   ( ordinal => [], ord "\x{0c}" );
SKIP: {
    $have_charnames
	or skip( "unable to load charnames::vianame", 1 );
    choose  ( 6 );
    value   ( ordinal => [], ord 'e' );
}
choose  ( 7 );
value   ( ordinal => [], ord 'a' );

tokenize( 's/\\b/\\b/' );
count   ( 7 );
choose  ( 4 );
value   ( ordinal => [], ord "\b" );

tokenize( '//smx' );
count   ( 4 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::Modifier' );
content ( 'smx' );
true    ( asserts => 's' );
true    ( asserts => 'm' );
true    ( asserts => 'x' );
false   ( negates => 'i' );

tokenize( '//r' );
count   ( 4 );
choose  ( 3 );
content ( 'r' );
true    ( asserts => 'r' );
value   ( match_semantics => [], undef );
value   ( perl_version_introduced => [], 5.013002 );

tokenize( '/(?^:foo)/' );
count   ( 10 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::GroupType::Modifier' );
content ( '?^:' );
true    ( asserts => 'd' );
false   ( asserts => 'l' );
false   ( asserts => 'u' );
true    ( negates => 'i' );
true    ( negates => 's' );
true    ( negates => 'm' );
true    ( negates => 'x' );
value	( match_semantics => [], 'd' );
value   ( perl_version_introduced => [], 5.013006 );

tokenize( '/(?^l:foo)/' );
count   ( 10 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::GroupType::Modifier' );
content ( '?^l:' );
false   ( asserts => 'd' );
true    ( asserts => 'l' );
false   ( asserts => 'u' );
value   ( match_semantics => [], 'l' );
value   ( perl_version_introduced => [], 5.013006 );

tokenize( 'qr/foo{3}/' );
count   ( 10 );
choose  ( 7 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
true    ( is_quantifier => [] );

tokenize( 'qr/foo{3,}/' );
count   ( 11 );
choose  ( 8 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
true    ( is_quantifier => [] );

tokenize( 'qr/foo{3,5}/' );
count   ( 12 );
choose  ( 9 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
true    ( is_quantifier => [] );

tokenize( 'qr/foo{,3}/' );
count   ( 11 );
choose  ( 8 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );

tokenize( '/{}/' );
count   ( 6 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );

tokenize( '/x{}/' );
count   ( 7 );
choose  ( 4 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '}' );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );

tokenize( '/{2}/' );
count   ( 7 );
choose  ( 4 );
content ( '}' );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );

tokenize( '/\\1?\\g{-1}*\\k<foo>{1,3}+/' );
count   ( 15 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\1' );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
value   ( perl_version_introduced => [], MINIMUM_PERL );
choose  ( 4 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g{-1}' );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( 6 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\k<foo>' );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/\\\\d{3,5}+.*?/' );
count   ( 15 );
choose  ( 9 );
class   ( 'PPIx::Regexp::Token::Greediness' );
content ( '+' );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( 12 );
class   ( 'PPIx::Regexp::Token::Greediness' );
content ( '?' );
value   ( perl_version_introduced => [], MINIMUM_PERL );

tokenize( '/(?<foo>bar)/' );
count   ( 10 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::GroupType::NamedCapture' );
content ( '?<foo>' );
value   ( name => [], 'foo' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/(?\'for\'bar)/' );
count   ( 10 );
choose  ( 3 );
value   ( name => [], 'for' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/(?P<fur>bar)/' );
count   ( 10 );
choose  ( 3 );
value   ( name => [], 'fur' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/(*PRUNE:foo)x/' );
count   ( 6 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Backtrack' );
content ( '(*PRUNE:foo)' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( 's/\\bfoo\\Kbar/baz/' );
count   ( 16 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Assertion' );
content ( '\\b' );
value   ( perl_version_introduced => [], MINIMUM_PERL );
choose  ( 6 );
class   ( 'PPIx::Regexp::Token::Assertion' );
content ( '\\K' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/(*PRUNE:foo)x/' );
count   ( 6 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Backtrack' );
content ( '(*PRUNE:foo)' );
value   ( perl_version_introduced => [], '5.009005' );

tokenize( '/(?|(foo))/' );
count   ( 12 );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::GroupType::BranchReset' );
content ( '?|' );
value   ( perl_version_introduced => [], '5.009005' );

parse   ( '/[a-z]/' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( regular_expression => [] );
true    ( interpolates => [] );
choose  ( find_first => 'PPIx::Regexp::Structure::CharClass' );
class   ( 'PPIx::Regexp::Structure::CharClass' );
false   ( negated => [] );

parse   ( 'm\'[^a-z]\'' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( regular_expression => [] );
false   ( interpolates => [] );
choose  ( find_first => 'PPIx::Regexp::Structure::CharClass' );
class   ( 'PPIx::Regexp::Structure::CharClass' );
true    ( negated => [] );

parse   ( '/(?|(?<baz>foo(wah))|(bar))(hoo)/' );
value   ( failures => [], 0 );
value   ( max_capture_number => [], 3 );
value   ( capture_names => [], [ 'baz' ] );
value   ( perl_version_introduced => [], '5.009005' );
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::BranchReset' );
count   ( 3 );
choose  ( child => 1, child => 0, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 0, type => 0 );
class   ( 'PPIx::Regexp::Token::GroupType::BranchReset' );
content ( '?|' );
choose  ( child => 1, child => 0, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Structure::NamedCapture' );
count   ( 4 );
value   ( number => [], 1 );
value   ( name => [], 'baz' );
choose  ( child => 1, child => 0, child => 0, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 0, child => 0, type => 0 );
class   ( 'PPIx::Regexp::Token::GroupType::NamedCapture' );
content ( '?<baz>' );
choose  ( child => 1, child => 0, child => 0, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );
choose  ( child => 1, child => 0, child => 0, child => 3 );
class   ( 'PPIx::Regexp::Structure::Capture' );
count   ( 3 );
value   ( number => [], 2 );
choose  ( child => 1, child => 0, child => 0, child => 3, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 0, child => 0, child => 3, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, child => 0, child => 0, child => 3, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );
choose  ( child => 1, child => 0, child => 1 );
class   ( 'PPIx::Regexp::Token::Operator' );
content ( '|' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( child => 1, child => 0, child => 2 );
class   ( 'PPIx::Regexp::Structure::Capture' );
count   ( 3 );
value   ( number => [], 1 );
choose  ( child => 1, child => 0, child => 2, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 0, child => 2, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, child => 0, child => 2, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Structure::Capture' );
count   ( 3 );
value   ( number => [], 3 );
choose  ( child => 1, child => 1, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 1, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, child => 1, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );

parse   ( 's/(foo)/${1}bar/g' );
class   ( 'PPIx::Regexp' );
value   ( failures => [], 0 );
value   ( max_capture_number => [], 1 );
value   ( capture_names => [], [] );
value   ( perl_version_introduced => [], MINIMUM_PERL );
count   ( 4 );
choose  ( type => 0 );
content ( 's' );
choose  ( regular_expression => [] );
content ( '/(foo)/' );
choose  ( replacement => [] );
content ( '${1}bar/' );
choose  ( modifier => [] );
content ( 'g' );

tokenize( '/((((((((((x))))))))))\\10/' );
count   ( 26 );
choose  ( 23 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\10' );

parse   ( '/((((((((((x))))))))))\\10/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 2 );
choose  ( child => 1, start => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, finish => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\10' );

tokenize( '/(((((((((x)))))))))\\10/' );
count   ( 24 );
choose  ( 21 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\10' );

parse   ( '/(((((((((x)))))))))\\10/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 2 );
choose  ( child => 1, start => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, finish => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( '\\10' );

parse   ( '/\\1/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\1' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/\\g1/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g1' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/(x)\\g-1/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 2 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Capture' );
count   ( 1 );
choose  ( child => 1, child => 0, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
choose  ( child => 1, child => 0, type => 0 );
class   ( undef );
content ( undef );
choose  ( child => 1, child => 0, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ')' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'x' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g-1' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], -1 );

parse   ( '/\\g{1}/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g{1}' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/(x)\\g{-1}/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 2 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Capture' );
count   ( 1 );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'x' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g{-1}' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], -1 );

parse   ( '/\\g{foo}/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\g{foo}' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/\\k<foo>/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\k<foo>' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/\\k\'foo\'/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '\\k\'foo\'' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/(?P=foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Backreference' );
content ( '(?P=foo)' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/(?1)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?1)' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/(x)(?-1)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 2 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Capture' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?-1)' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], -1 );

parse   ( '/(x)(?+1)(y)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 3 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Capture' );
choose  ( child => 1, child => 1 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?+1)' );
value   ( absolute => [], 2 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], '+1' );
choose  ( child => 1, child => 2 );
class   ( 'PPIx::Regexp::Structure::Capture' );

parse   ( '/(?R)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?R)' );
value   ( absolute => [], 0 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 0 );

parse   ( '/(?&foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?&foo)' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/(?P>foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Token::Recursion' );
content ( '(?P>foo)' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'foo' );
value   ( number => [], undef );

parse   ( '/(?(1)foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(1)' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/(?(R1)foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(R1)' );
value   ( absolute => [], 1 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 1 );

parse   ( '/(?(<bar>)foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(<bar>)' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'bar' );
value   ( number => [], undef );

parse   ( '/(?(\'bar\')foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(\'bar\')' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'bar' );
value   ( number => [], undef );

parse   ( '/(?(R&bar)foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(R&bar)' );
value   ( absolute => [], undef );
true    ( is_named => [] );
value   ( name => [], 'bar' );
value   ( number => [], undef );

parse   ( '/(?(DEFINE)foo)/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Switch' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.009005' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Condition' );
content ( '(DEFINE)' );
value   ( absolute => [], 0 );
false   ( is_named => [] );
value   ( name => [], undef );
value   ( number => [], 0 );

tokenize( '/(?p{ code })/' );
count   ( 8 );
choose  ( 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
value   ( perl_version_removed => [], undef );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::GroupType::Code' );
content ( '?p' );
value   ( perl_version_removed => [], '5.009005' );

parse   ( '/(?p{ code })/' );
value   ( failures => [], 0);
class   ( 'PPIx::Regexp' );
value   ( perl_version_removed => [], '5.009005' );
count   ( 3 );
choose  ( child => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
value   ( perl_version_removed => [], undef );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
value   ( perl_version_removed => [], '5.009005' );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::Code' );
count   ( 1 );
value   ( perl_version_removed => [], '5.009005' );
choose  ( child => 1, child => 0, start => [] );
count   ( 1 );
choose  ( child => 1, child => 0, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '(' );
value   ( perl_version_removed => [], undef );
choose  ( child => 1, child => 0, type => [] );
count   ( 1 );
choose  ( child => 1, child => 0, type => 0 );
class   ( 'PPIx::Regexp::Token::GroupType::Code' );
content ( '?p' );
value   ( perl_version_removed => [], '5.009005' );

parse   ( 'qr{foo}smx' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
choose  ( regular_expression => [] );
class   ( 'PPIx::Regexp::Structure::Regexp' );
value   ( delimiters => [], '{}' );
choose  ( top => [] );
class   ( 'PPIx::Regexp' );
value   ( delimiters => [], '{}' );
value   ( delimiters => 1, undef );

parse   ( 's<foo>[bar]smx' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
choose  ( regular_expression => [] );
class   ( 'PPIx::Regexp::Structure::Regexp' );
value   ( delimiters => [], '<>' );
choose  ( top => [], replacement => [] );
class   ( 'PPIx::Regexp::Structure::Replacement' );
value   ( delimiters => [], '[]' );
choose  ( top => [] );
class   ( 'PPIx::Regexp' );
value   ( delimiters => 0, '<>' );
value   ( delimiters => 1, '[]' );

parse   ( 's/foo/bar/smx' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
value   ( delimiters => 0, '//' );
value   ( delimiters => 1, '//' );

tokenize( '/foo/', encoding => 'utf8' );
value   ( failures => [], 0 );
count   ( 7 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'f' );

tokenize( 'm/\\N\\n/' );
count   ( 6 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
content ( '\\N' );
value   ( perl_version_introduced => [], '5.011' );
value   ( perl_version_removed => [], undef );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( '\\n' );
value   ( perl_version_introduced => [], MINIMUM_PERL );
value   ( perl_version_removed => [], undef );

tokenize( '/\\p{ Match = lo-ose }/' );
count   ( 5 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
content ( '\\p{ Match = lo-ose }' );
value   ( perl_version_introduced => [], '5.006001' );
value   ( perl_version_removed => [], undef );

parse   ( 'm{)}smx' );
value   ( failures => [], 1 );
class   ( 'PPIx::Regexp' );
value   ( delimiters => 0, '{}' );

parse   ( 's/(\\d+)/roman($1)/ge' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
count   ( 4 );
value   ( perl_version_introduced => [], '5.000' );
value   ( perl_version_removed => [], undef );
choose  ( child => 2, child => 0 );
class   ( 'PPIx::Regexp::Token::Code' );
content ( 'roman($1)' );
value   ( perl_version_introduced => [], '5.000' );
value   ( perl_version_removed => [], undef );

tokenize( '/${foo}bar/' );
count   ( 8 );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Interpolation' );
content ( '${foo}' );
ppi     ( '$foo' );

{
    parse   ( 's/x/$1/e' );
    choose  ( child => 2, child => 0 );
    class   ( 'PPIx::Regexp::Token::Code' );
    content ( '$1' );
    value   ( ppi => [], PPI::Document->new( \'$1' ) );
    my $doc1 = result();
    value   ( ppi => [], PPI::Document->new( \'$1' ) );
    my $doc2 = result();
    cmp_ok( refaddr( $doc1 ), '==', refaddr( $doc2 ),
	'Ensure we get back the same object from both calls to ppi()' );
}

##tokenize( '/[[:lower:]]/' );
##count   ( 7 );
##choose  ( 3 );
##class   ( 'PPIx::Regexp::Token::CharClass::POSIX' );
##content ( '[:lower:]' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##true    ( is_case_sensitive => [] );
##
##parse   ( '/[[:lower:]]/' );
##value   ( failures => [], 0 );
##class   ( 'PPIx::Regexp' );
##count   ( 3 );
##choose  ( child => 1 );
##class   ( 'PPIx::Regexp::Structure::Regexp' );
##count   ( 1 );
##choose  ( child => 1, child => 0 );
##class   ( 'PPIx::Regexp::Structure::CharClass' );
##count   ( 1 );
##choose  ( child => 1, child => 0, child => 0 );
##class   ( 'PPIx::Regexp::Token::CharClass::POSIX' );
##content ( '[:lower:]' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##true    ( is_case_sensitive => [] );
##
##tokenize( '/[[:alpha:]]/' );
##count   ( 7 );
##choose  ( 3 );
##class   ( 'PPIx::Regexp::Token::CharClass::POSIX' );
##content ( '[:alpha:]' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##false   ( is_case_sensitive => [] );
##
##parse   ( '/[[:alpha:]]/' );
##value   ( failures => [], 0 );
##class   ( 'PPIx::Regexp' );
##count   ( 3 );
##choose  ( child => 1 );
##class   ( 'PPIx::Regexp::Structure::Regexp' );
##count   ( 1 );
##choose  ( child => 1, child => 0 );
##class   ( 'PPIx::Regexp::Structure::CharClass' );
##count   ( 1 );
##choose  ( child => 1, child => 0, child => 0 );
##class   ( 'PPIx::Regexp::Token::CharClass::POSIX' );
##content ( '[:alpha:]' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##false   ( is_case_sensitive => [] );
##
##tokenize( '/\\p{Lower}/' );
##count   ( 5 );
##choose  ( 2 );
##class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
##content ( '\\p{Lower}' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##true    ( is_case_sensitive => [] );
##
##parse   ( '/\\p{Lower}/' );
##value   ( failures => [], 0 );
##class   ( 'PPIx::Regexp' );
##count   ( 3 );
##choose  ( child => 1 );
##class   ( 'PPIx::Regexp::Structure::Regexp' );
##count   ( 1 );
##choose  ( child => 1, child => 0 );
##class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
##content ( '\\p{Lower}' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##true    ( is_case_sensitive => [] );
##
##tokenize( '/\\p{Alpha}/' );
##count   ( 5 );
##choose  ( 2 );
##class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
##content ( '\\p{Alpha}' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##false   ( is_case_sensitive => [] );
##
##parse   ( '/\\p{Alpha}/' );
##value   ( failures => [], 0 );
##class   ( 'PPIx::Regexp' );
##count   ( 3 );
##choose  ( child => 1 );
##class   ( 'PPIx::Regexp::Structure::Regexp' );
##count   ( 1 );
##choose  ( child => 1, start => [] );
##count   ( 1 );
##choose  ( child => 1, child => 0 );
##class   ( 'PPIx::Regexp::Token::CharClass::Simple' );
##content ( '\\p{Alpha}' );
##true    ( significant => [] );
##true    ( can_be_quantified => [] );
##false   ( is_quantifier => [] );
##false   ( is_case_sensitive => [] );

parse   ( '/ . /' );
false   ( modifier_asserted => 'u' );
false   ( modifier_asserted => 'x' );

parse   ( '/ . /', default_modifiers => [ 'smxu' ] );
true    ( modifier_asserted => 'u' );
false   ( modifier_asserted => 'l' );
true    ( modifier_asserted => 'x' );

parse   ( '/ . /', default_modifiers => [ 'smxu', '-u' ] );
false   ( modifier_asserted => 'u' );
false   ( modifier_asserted => 'l' );
true    ( modifier_asserted => 'x' );

SKIP: {
    $is_ascii
	or skip(
	'Non-ASCII machines will have different ordinal values',
	10,
    );

    tokenize( '/foo/', '--notokens' );
    dump_result( ordinal => 1, tokens => 1,
	<<'EOD', q<Tokenization of '/foo/'> );
PPIx::Regexp::Token::Structure	''
PPIx::Regexp::Token::Delimiter	'/'
PPIx::Regexp::Token::Literal	'f'	0x66
PPIx::Regexp::Token::Literal	'o'	0x6f
PPIx::Regexp::Token::Literal	'o'	0x6f
PPIx::Regexp::Token::Delimiter	'/'
PPIx::Regexp::Token::Modifier	''
EOD

    parse   ( '/(foo[a-z\\d])/x' );
    dump_result( verbose => 1,
	<<'EOD', q<Verbose parse of '/(foo[a-z\\d])/x'> );
PPIx::Regexp	failures=0
  PPIx::Regexp::Token::Structure	''	significant
  PPIx::Regexp::Structure::Regexp	/ ... /
    PPIx::Regexp::Structure::Capture	( ... )	number=1	name undef	can_be_quantified
      PPIx::Regexp::Token::Literal	'f'	0x66	significant	can_be_quantified
      PPIx::Regexp::Token::Literal	'o'	0x6f	significant	can_be_quantified
      PPIx::Regexp::Token::Literal	'o'	0x6f	significant	can_be_quantified
      PPIx::Regexp::Structure::CharClass	[ ... ]	can_be_quantified
        PPIx::Regexp::Node::Range
          PPIx::Regexp::Token::Literal	'a'	0x61	significant	can_be_quantified
          PPIx::Regexp::Token::Operator	'-'	significant	can_be_quantified
          PPIx::Regexp::Token::Literal	'z'	0x7a	significant	can_be_quantified
        PPIx::Regexp::Token::CharClass::Simple	'\\d'	significant	can_be_quantified
  PPIx::Regexp::Token::Modifier	'x'	significant	x
EOD

    parse   ( '/(?<foo>\\d+)/' );
    dump_result( perl_version => 1,
	<<'EOD', q<Perl versions in '/(?<foo>\\d+)/'> );
PPIx::Regexp	failures=0	5.009005 <= $]
  PPIx::Regexp::Token::Structure	''	5.000 <= $]
  PPIx::Regexp::Structure::Regexp	/ ... /	5.009005 <= $]
    PPIx::Regexp::Structure::NamedCapture	(?<foo> ... )	5.009005 <= $]
      PPIx::Regexp::Token::CharClass::Simple	'\\d'	5.000 <= $]
      PPIx::Regexp::Token::Quantifier	'+'	5.000 <= $]
  PPIx::Regexp::Token::Modifier	''	5.000 <= $]
EOD

    tokenize( '/[a-z]/', '--notokens' );
    dump_result( test => 1, verbose => 1, tokens => 1,
	<<'EOD', q<Test tokenization of '/[a-z]/'> );
tokenize( '/[a-z]/' );
count   ( 9 );
choose  ( 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 1 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 2 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '[' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 3 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'a' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 4 );
class   ( 'PPIx::Regexp::Token::Operator' );
content ( '-' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 5 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'z' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 6 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ']' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 7 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( 8 );
class   ( 'PPIx::Regexp::Token::Modifier' );
content ( '' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
EOD

    parse   ( '/[a-z]/' );
    dump_result( test => 1, verbose => 1,
	<<'EOD', q<Test of '/[a-z]/'> );
parse   ( '/[a-z]/' );
value   ( failures => [], 0 );
class   ( 'PPIx::Regexp' );
count   ( 3 );
choose  ( child => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( child => 1 );
class   ( 'PPIx::Regexp::Structure::Regexp' );
count   ( 1 );
choose  ( child => 1, start => [] );
count   ( 1 );
choose  ( child => 1, start => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, type => [] );
count   ( 0 );
choose  ( child => 1, finish => [] );
count   ( 1 );
choose  ( child => 1, finish => 0 );
class   ( 'PPIx::Regexp::Token::Delimiter' );
content ( '/' );
choose  ( child => 1, child => 0 );
class   ( 'PPIx::Regexp::Structure::CharClass' );
count   ( 1 );
choose  ( child => 1, child => 0, start => [] );
count   ( 1 );
choose  ( child => 1, child => 0, start => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( '[' );
choose  ( child => 1, child => 0, type => [] );
count   ( 0 );
choose  ( child => 1, child => 0, finish => [] );
count   ( 1 );
choose  ( child => 1, child => 0, finish => 0 );
class   ( 'PPIx::Regexp::Token::Structure' );
content ( ']' );
choose  ( child => 1, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Node::Range' );
count   ( 3 );
choose  ( child => 1, child => 0, child => 0, child => 0 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'a' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( child => 1, child => 0, child => 0, child => 1 );
class   ( 'PPIx::Regexp::Token::Operator' );
content ( '-' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( child => 1, child => 0, child => 0, child => 2 );
class   ( 'PPIx::Regexp::Token::Literal' );
content ( 'z' );
true    ( significant => [] );
true    ( can_be_quantified => [] );
false   ( is_quantifier => [] );
choose  ( child => 2 );
class   ( 'PPIx::Regexp::Token::Modifier' );
content ( '' );
true    ( significant => [] );
false   ( can_be_quantified => [] );
false   ( is_quantifier => [] );
EOD

}

finis   ();

done_testing;

1;

# ex: set textwidth=72 :
