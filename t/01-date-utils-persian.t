#!/usr/bin/perl

package T::Date::Utils::Persian;

use Moo;
use namespace::clean;

with 'Date::Utils::Persian';

package main;

use 5.006;
use Test::More tests => 12;
use strict; use warnings;

my $t = T::Date::Utils::Persian->new;

ok($t->validate_year(1394));
eval { $t->validate_year(-1394); };
like($@, qr/ERROR: Invalid year \[\-1394\]./);

ok($t->validate_month(11));
eval { $t->validate_month(13); };
like($@, qr/ERROR: Invalid month \[13\]./);

ok($t->validate_day(30));
eval { $t->validate_day(32); };
like($@, qr/ERROR: Invalid day \[32\]./);

is($t->persian_to_julian(1394, 1, 1), 2457102.5);
is(join(', ', $t->julian_to_persian(2455538.5)), '1389, 9, 17');

is(sprintf("%04d-%02d-%02d", $t->persian_to_gregorian(1394, 1, 1)), '2015-03-21');
is(join(', ', $t->gregorian_to_persian(2010, 12, 8)), '1389, 9, 17');

is($t->days_in_persian_month_year(1, 1394), 31);
ok(!!$t->is_persian_leap_year(1394) == 0);

done_testing;
