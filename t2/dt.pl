#!/usr/bin/perl

use strict;
use warnings;
use v5.12;
use DateTime;
use DateTime::TimeZone;

my $tz = DateTime::TimeZone->new(name => 'UTC');
my $dt = DateTime->from_epoch(epoch=>1037232000, locale=>'ru', time_zone=>$tz);

say $dt->strftime('%A %d.%m.%Y %H:%M');
