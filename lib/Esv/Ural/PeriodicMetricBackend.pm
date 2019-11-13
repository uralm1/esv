package Esv::Ural::PeriodicMetricBackend;
use Mojo::Base -base;

use Carp;
use Esv::Ural::SelectGroup;
use Data::Dumper;


# $db_config = { hf_server => '', hf_database => '' };
# Esv::Ural::PeriodicMetricBackend->new($db_config, $metrics_catalog);
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
  };
  return bless $self, $class;
}

# $obj->set_time(1544572800, 1544572800 + 86400*365)
sub set_time {
  my ($self, $time_from, $time_to) = @_;
  croak 'Time_from/to required' unless defined $time_from and defined $time_to;

  $self->{time_from} = $time_from;
  $self->{time_to} = $time_to;
  return $self;
}

# we don't need it though
# $r = $obj->invalidate()
sub invalidate {
  my $self = shift;
  delete $self->{sgroups}{$_} for keys %{$self->{sgroups}};
  return $self;
}


# $r = $obj->get_raw(['my.metric1', 'my.metric2'])
# $r is hashref: $r->{'my.metric1'} = [ {value=>$v, time=>$t}, {} etc ]
sub get_raw {
  my ($self, $metrics_arr) = @_;
  croak 'Metrics array is required' unless defined $metrics_arr;
  croak 'Operation period is not defined' unless defined $self->{time_from} and defined $self->{time_to};

  my %ghash;
  for (@$metrics_arr) {
    my $mcfg = $self->{metrics_catalog}->get_metric($_);
    return undef unless $mcfg;

    my $group_id = $mcfg->{group};
    push @{$ghash{$group_id}}, $_;
  }

  my $r = {};
  for (keys %ghash) {
    unless (defined $self->{sgroups}{$_}) {
      $self->{sgroups}{$_} = Esv::Ural::SelectGroup->new($_, 
	$self->{db_config},
	$self->{metrics_catalog},
      );
    }

    my $r1 = $self->{sgroups}{$_}->select_arrays($self->{time_from}, $self->{time_to}, $ghash{$_});
    for my $m (keys %$r1) {
      $r->{$m} = $r1->{$m};
    }
  }

  #say Dumper $r;
  return $r;
}


1;
