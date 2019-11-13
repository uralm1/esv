package Esv::Ural::CheckDB;
use Mojo::Base -base;

use Carp;
use AnyEvent;
use AnyEvent::InfluxDB;
#use Data::Dumper;

# $db_config = { hf_server => '', hf_database => '' };
# $version_or_undef = Esv::Ural::CheckDB::ping($db_config);
sub ping {
  my $db_config = shift;
  croak "Configuration required" unless defined $db_config;

  my $db = AnyEvent::InfluxDB->new(server => $db_config->{hf_server});
  my $r;
  for (1 .. 3) {
    $r = _ping_blocking_try($db, $_);
    last if defined $r;
  }
  return $r;
}

# internal
# my $r = _ping_blocking_try($db)
sub _ping_blocking_try {
  my $db = shift;
  my $try = shift || '';
  my $cv = AE::cv;
  my $guard = $db->ping(
    wait_for_leader => 2,
    on_success => $cv,
    on_error => sub {
      carp("Ping InfluxDB error (try $try): @_");
      $cv->send(undef);
    }
  );
  return $cv->recv;
}


1;
