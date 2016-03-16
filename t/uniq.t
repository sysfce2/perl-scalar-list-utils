#!./perl

use strict;
use warnings;

use Test::More tests => 9;
use List::Util qw( uniq uniqnum );

is_deeply( [ uniq ],
           [],
           'uniq of empty list' );

is_deeply( [ uniq qw( abc ) ],
           [qw( abc )],
           'uniq of singleton list' );

is_deeply( [ uniq qw( x x x ) ],
           [qw( x )],
           'uniq of repeated-element list' );

is_deeply( [ uniq qw( a b a c ) ],
           [qw( a b c )],
           'uniq removes subsequent duplicates' );

is_deeply( [ uniq qw( 1 1.0 1E0 ) ],
           [qw( 1 1.0 1E0 )],
           'uniq compares strings' );

is_deeply( [ uniqnum qw( 1 1.0 1E0 2 3 ) ],
           [ 1, 2, 3 ],
           'uniqnum compares numbers' );

{
    package Stringify;

    use overload '""' => sub { return $_[0]->{str} };

    sub new { bless { str => $_[1] }, $_[0] }

    package main;

  my @strs = map { Stringify->new( $_ ) } qw( foo foo bar );

  is_deeply( [ uniq @strs ],
             [ $strs[0], $strs[2] ],
             'uniq respects stringify overload' );
}

{
    package DestroyNotifier;

    use overload '""' => sub { "SAME" };

    sub new { bless { var => $_[1] }, $_[0] }

    sub DESTROY { ${ $_[0]->{var} }++ }

    package main;

    my @destroyed = (0) x 3;
    my @notifiers = map { DestroyNotifier->new( \$destroyed[$_] ) } 0 .. 2;

    my @uniq = uniq @notifiers;
    undef @notifiers;

    is_deeply( \@destroyed, [ 0, 1, 1 ],
               'values filtered by uniq() are destroyed' );

    undef @uniq;
    is_deeply( \@destroyed, [ 1, 1, 1 ],
               'all values destroyed' );
}