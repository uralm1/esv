package Esv::Ural::LineWrite;
use Mojo::Base -base;

use Carp;
use AnyEvent;
use AnyEvent::InfluxDB;
#use Data::Dumper;

# $db_config = { hf_server => '', hf_database => '' };
# Esv::Ural::LineWrite->new($db_config);
sub new {
  my ($class, $db_config) = @_;
  croak "Configuration required" unless defined $db_config;
  my $self = {
    db_config => $db_config,
    ld => [],
  };

  return bless $self, $class;
}

# $obj->reset
sub reset {
  my $self = shift;
  $self->{ld} = undef;
  $self->{ld} = [];
  return $self;
}

# reset buffer and store line
# my $line = line protocol data
# $obj->line_new($line)
sub line_new {
  my ($self, $line) = @_;
  
  $self->reset;
  return $self->line($line);
}

# my $line = line protocol data
# $obj->line($line)
sub line {
  my ($self, $line) = @_;
  croak 'Data required' unless defined $line;
  
  utf8::encode($line);
  push @{$self->{ld}}, $line;
  return 1;
}

# $arr = $obj->dump
sub dump {
  return shift->{ld};
}

# $b = $obj->write
sub write {
  my $self = shift;
  my $db = AnyEvent::InfluxDB->new(server => $self->{db_config}{hf_server}, persistent => 0);
  my $cv = AE::cv;
  my $guard = $db->write(database => $self->{db_config}{hf_database}, precision => 's',
    data => $self->{ld},
    on_success => sub {
      $cv->send(1);
    },
    on_error => sub {
      carp("Error writing to InfluxDB: @_");
      $cv->send(undef);
    }
  );
  my $r = $cv->recv;

  $self->reset if $r;
  return $r;
}


1;
