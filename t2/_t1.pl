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
# ping
$cv->begin;
my $guard0 = $db->ping(on_success => sub {
    say "Ping successful: @_";
    $cv->end;
  }, #or on_success=>$cv
  on_error => sub {
    $cv->end;
    $cv->croak("Ping failure: @_");
  }
);

# write
my $ld = data2line('temperature', { external=>997 });
$cv->begin;
my $guard1 = $db->write(database => 'mydb', precision => 's',
  data => [ $ld ],
  on_success => sub {
    say "Write successful";
    $cv->end;
  },
  on_error => sub {
    $cv->end;
    $cv->croak("Write failure: @_");
  }
);
$cv->recv;

#query
my $cv2 = AE::cv;
my $guard2 = $db->select(database => 'mydb', epoch => 's',
  q => 'SELECT external FROM temperature',
  on_success => $cv2,
  on_error => sub {
    $cv2->croak("Query failure: @_");
  }
);
my $res = $cv2->recv;
#say Dumper $res;
my $row = $res->[0];
say "Measurement: $row->{name}";
say "Values: ";
for my $v (@{$row->{values} || []}) {
  say "   $_ = $v->{$_}" for keys %{$v || {}};
}


