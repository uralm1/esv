package Esv::Controller::Test;
use Mojo::Base 'Mojolicious::Controller';

use AnyEvent;
use AnyEvent::InfluxDB;
#use InfluxDB::LineProtocol qw(data2line precision=s);


sub testquery {
  my $self = shift;
  my $d = $self->param('date');
  unless ($d =~ m/^\d{4}-\d{2}-\d{2}$/) {
    return $self->render(text => 'Error!');
  }

  my $cv = AE::cv;
  my $db = AnyEvent::InfluxDB->new(server=>$self->config('hf_server'));

  my $guard = $db->select(database => $self->config('hf_database'), epoch => 's',
    q => "SELECT dest, dest_spec, rep_spec, podyom, gorod, deltamonth \
FROM podacha WHERE time=\'$d\' LIMIT 20",
    on_success => $cv,
    on_error => sub {
      $cv->croak("Query failure: @_");
    }
  );
  my $query = $cv->recv;
  $self->render(r => $query->[0]); #testquery template
}

1;
