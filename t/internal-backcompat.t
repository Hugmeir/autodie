#!/usr/bin/perl -w
use strict;
use warnings;
use Fatal;
use Test::More 'no_plan';

# Tests to determine if Fatal's internal interfaces remain backwards
# compatible.

# fill_protos.  This hasn't been changed since the original Fatal,
# and so should always be the same.

my %protos = (
    '$'     => [ [ 1, '$_[0]' ] ],
    '$$'    => [ [ 2, '$_[0]', '$_[1]' ] ],
    '$$@'   => [ [ 3, '$_[0]', '$_[1]', '@_[2..$#_]' ] ],
    '\$'    => [ [ 1, '${$_[0]}' ] ],
    '\%'    => [ [ 1, '%{$_[0]}' ] ],
    '\%;$*' => [ [ 1, '%{$_[0]}' ], [ 2, '%{$_[0]}', '$_[1]' ],
                 [ 3, '%{$_[0]}', '$_[1]', '$_[2]' ] ],
);

while (my ($proto, $code) = each %protos) {
    is_deeply( [ Fatal::fill_protos($proto) ], $code, $proto);
}

# TODO: write_invocation

# one_invocation tests.

no warnings 'qw';

my @one_invocation_calls = (
        # Core  # Call          # Name  # Void   # Args
    [
        [ 1,    'CORE::open',   'open', 0,      qw($_[0] $_[1] @_[2..$#_]) ],
        q{return CORE::open($_[0], $_[1], @_[2..$#_]) || croak "Can't open(@_): $!"},
    ],
    [
        [ 1,    'CORE::open',   'open', 1,      qw($_[0] $_[1] @_[2..$#_]) ],
        q{return (defined wantarray)?CORE::open($_[0], $_[1], @_[2..$#_]):
                   CORE::open($_[0], $_[1], @_[2..$#_]) || croak "Can't open(@_): $!"},
    ],
);

foreach my $test (@one_invocation_calls) {
    is(Fatal::one_invocation( @{ $test->[0] } ), $test->[1], 'one_inovcation');
}

# TODO: _make_fatal
