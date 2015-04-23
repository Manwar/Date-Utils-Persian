#!perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;

BEGIN { use_ok('Date::Utils::Persian') || print "Bail out!"; }

diag( "Testing Date::Utils::Persian $Date::Utils::Persian::VERSION, Perl $], $^X" );
