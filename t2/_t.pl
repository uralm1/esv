#!/usr/bin/perl

use strict;
use warnings;
use v5.12;
use InfluxDB::HTTP;
use InfluxDB::LineProtocol qw(data2line precision=s);
use Data::Dumper;

my $if = InfluxDB::HTTP->new(host=>'tsdbtest.uwc.local', timeout=>60);

my $ping_result = $if->ping();
print "$ping_result\n";
say $ping_result->version if ($ping_result);

my $ld = data2line('temperature', { external=>999 });
my $write = $if->write($ld, database=>'mydb', precision=>'s');
if ($write) {
  say "Write successful";
} else {
  say "Error occured on write: ".$write->error;
}


my $query = $if->query('SELECT external FROM temperature', database=>'mydb', epoch=>'s');
if ($query) {
  my $d = $query->data;
  my $r0 = $d->{results}[0]; #0-statement results
  #say Dumper $r0;
  my $s0 = $r0->{series}[0]; #0-serie
  my $vs = $s0->{values};
  say Dumper $s0;
  say '-----------------------------';
  say $s0->{name};
  foreach my $v (@$vs) {
    print "$_, " foreach @$v;
    print "\n";
  }
  say '-----------------------------';
} else {
  say "Error occured on query: ".$query->error;
}


