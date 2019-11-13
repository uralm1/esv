package Esv::Ural::MetricBackend;
use Mojo::Base -base;

use Carp;
use Esv::Ural::SelectGroup;
use Data::Dumper;
use InfluxDB::LineProtocol qw(data2line precision=s);
use Esv::Ural::LineWrite;


# $db_config = { hf_server => '', hf_database => '' };
# Esv::Ural::MetricBackend->new($db_config, $metrics_catalog);
sub new {
  my ($class, $db_config, $metrics_catalog) = @_;
  croak "Configuration required" unless defined $db_config;
  croak "Metrics required" unless defined $metrics_catalog;
  my $self = {
    time_from => undef,
    time_to => undef,
    sgroups => {},
    db_config => $db_config,
    metrics_catalog => $metrics_catalog,
    lw => undef,
  };
  return bless $self, $class;
}

# $obj->set_time(1544572800)
# $obj->set_time(1544572800, 1544572800 + 86400)
sub set_time {
  my ($self, $time_from, $time_to) = @_;
  croak 'Time_from required' unless defined $time_from;

  $self->{time_from} = $time_from;
  $self->{time_to} = $time_to; # can be undefined
  return $self;
}

# $r = $obj->invalidate()
sub invalidate {
  my $self = shift;
  delete $self->{sgroups}{$_} for keys %{$self->{sgroups}};
  $self->{lw} = undef;
  return $self;
}

# $r = $obj->get_raw('my.metric')
sub get_raw {
  my ($self, $metric) = @_;
  croak 'Metric is required' unless defined $metric;
  croak 'Operation time is not defined' unless defined $self->{time_from};

  my $mcfg = $self->{metrics_catalog}->get_metric($metric);
  return undef unless $mcfg;

  my $group_id = $mcfg->{group};
  unless (defined $self->{sgroups}{$group_id}) {
    $self->{sgroups}{$group_id} = Esv::Ural::SelectGroup->new($group_id, 
      $self->{db_config},
      $self->{metrics_catalog},
    );
  }

  my $r = $self->{sgroups}{$group_id}->select($self->{time_from}, $self->{time_to});
  #say Dumper $r;
  unless (exists $r->{$metric}) {
    #carp "Empty result for metric $metric";
    return undef;
  }
  return $r->{$metric}{value};
}

# $r = $obj->get('my.metric')
sub get {
  my ($self, $metric) = @_;

  carp "Base class get() returns unformatted result";
  return $self->get_raw($metric);
}


# $b = $obj->set_raw('my.metric', $value, $write)
sub set_raw {
  my ($self, $metric, $value, $write) = @_;
  croak 'Metric and data are required' unless (defined $metric and defined $value);
  croak 'Operation time is not defined' unless defined $self->{time_from};

  my $mcfg = $self->{metrics_catalog}->get_metric($metric);
  unless ($mcfg) {
    croak("Unknown metric $metric for set");
    return undef;
  }

  unless (defined $self->{lw}) {
    $self->{lw} = Esv::Ural::LineWrite->new($self->{db_config});
  }

  my %tags = %{$mcfg->{tags}}; # do shallow copy
  for (keys %tags) {
    # don't specify empty tags on write
    delete $tags{$_} if $tags{$_} eq '';
  }

  $self->{lw}->line(data2line($mcfg->{measurement}, 
    {$mcfg->{field}=>$value}, 
    \%tags, 
    $self->{time_from}
  ));

  return $self->{lw}->write if $write;
  return 1;
}


# $ret_val_or_undef = $obj->set('my.metric', $value, $write)
sub set {
  my ($self, $metric, $value, $write) = @_;

  carp "Base class set() is the same as set_raw() and doesn't parse anything";
  my $b = $self->set_raw($metric, $value, $write);
  return ($b) ? $value : undef;
}


# $b = $obj->write
sub write {
  my $self = shift;
  unless (defined $self->{lw}) {
    #carp 'Write is called without any data. No write is performed.';
    return 0;
  }
  return $self->{lw}->write;
}


1;
