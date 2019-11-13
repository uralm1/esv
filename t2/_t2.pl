#!/usr/bin/perl

use strict;
use warnings;
use v5.12;
use AE;
use AnyEvent::InfluxDB;
use InfluxDB::LineProtocol qw(data2line precision=s);
use Data::Dumper;

my $db = AnyEvent::InfluxDB->new(
  server => 'http://tsdbtest.uwc.local:8086'
);

my $cv = AE::cv;
my $guard = $db->select(database => 'esv_test', epoch => 's',
  q => 'SELECT dest,podyom FROM podacha WHERE time>=1544572800s AND time<=1544659200s',
  on_success => $cv,
  on_error => sub {
    $cv->croak("Query failure: @_");
  }
);
my $res = $cv->recv;
say Dumper $res;
#my $row = $res->[0];
#say "Measurement: $row->{name}";
#say "Values: ";
#for my $v (@{$row->{values} || []}) {
#  say "   $_ = $v->{$_}" for keys %{$v || {}};
#}


