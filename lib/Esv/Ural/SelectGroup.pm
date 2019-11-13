package Esv::Ural::SelectGroup;
use Mojo::Base -base;

use Carp;
use AnyEvent;
use AnyEvent::InfluxDB;
use Data::Dumper;

# $db_config = { hf_server => '', hf_database => '' };
# Esv::Ural::SelectGroup->new($group_id, $db_config, $metrics_catalog);
sub new {
  my ($class, $group_id, $db_config, $metrics_catalog) = @_;
  croak "Group Id required" unless defined $group_id;
  croak "Configuration required" unless defined $db_config;
  croak "Metrics required" unless defined $metrics_catalog;
  #croak "Unsupported Group Id" unless defined $metrics_catalog->get_select_group($group_id);
  # load group configuration
  my $self = {
    fieldspec => $metrics_catalog->get_select_group($group_id)->{fieldspec},
    measpec => $metrics_catalog->get_select_group($group_id)->{measpec},
    metrics_transformed => $metrics_catalog->get_metrics_transformed($group_id),
    db_config => $db_config,
    r => undef,
    time_from => undef,
    time_to => undef,
  };

  croak 'Required specs missing' unless defined $self->{fieldspec} and defined $self->{measpec};

  return bless $self, $class;
}


# $r = $obj->select_new(1544572800, 1544572800 + 86400)
sub select_new {
  my ($self, $time_from, $time_to) = @_;
  croak 'Time_from required' unless defined $time_from;
  $self->{time_from} = $time_from;
  $self->{time_to} = $time_to;
  my $wh = (defined $time_to) ? "time >= ${time_from}s AND time < ${time_to}s" : "time = ${time_from}s";

  my $op = "SELECT $self->{fieldspec} FROM $self->{measpec} WHERE $wh LIMIT 500";
  $self->{r} = undef; # forget old result
  #say "SELECT!!!";
  my $cv = AE::cv;
  my $db = AnyEvent::InfluxDB->new(server => $self->{db_config}{hf_server}, persistent => 0);

  my $guard = $db->select(database => $self->{db_config}{hf_database}, epoch => 's',
    q => $op,
    on_success => $cv,
    on_error => sub {
      $cv->croak("select_new() Query failure: @_");
    }
  );
  my $query = $cv->recv;

  my $r = {};
  my $mm = $self->{metrics_transformed};
  for my $ser (@$query) {
    if (exists $mm->{$ser->{name}}) {
      for my $value (@{$ser->{values}}) {
	for my $met (@{$mm->{$ser->{name}}}) {
  	  if (exists $value->{$met->{field}}) {
            my $all_tags_good = (scalar %{$met->{tags}}) ? 0 : 1;
	  TAGS_CHECK:
            for my $tag (keys %{$met->{tags}}) {
  	      if (exists $value->{$tag} and 
	        ((defined $value->{$tag} and $value->{$tag} eq $met->{tags}->{$tag})) or
	        (!defined $value->{$tag} and $met->{tags}->{$tag} eq '')) {
                $all_tags_good = 1;
	      } else {
                $all_tags_good = 0;
		last TAGS_CHECK;
              }
	    }
	    if ($all_tags_good) {
              if (!defined $r->{$met->{metric}} or 
		(defined $r->{$met->{metric}} and 
	        $r->{$met->{metric}}->{time} < $value->{time})
	      ) {
		$r->{$met->{metric}} = {
		  value => $value->{$met->{field}},
		  time => $value->{time},
		};
	      } #sort by time
	    } #all_tags_good
	  } #if field exists
	} #loop by all metrics in this measurement
      } #loop all values
    } #if measurement found
  } #loop all series

  $self->{r} = $r;
  return $r;
}

# returns cached result
# $r = $obj->select()
# will make a new request if time differ
# $r = $obj->select(1544572800, 1544572800 + 86400)
sub select {
  my ($self, $time_from, $time_to) = @_;

  if (defined $self->{r}) {
    if (defined($time_from) and 
      ($time_from != $self->{time_from} or
      (defined($time_to) and defined($self->{time_to}) and $time_to != $self->{time_to}))) {
      return $self->select_new($time_from, $time_to);
    } else {
      return $self->{r};
    }
  } else {
    return $self->select_new($time_from, $time_to);
  }
}


# $r = $obj->select_arrays(1544572800, 1544572800 + 86400*365, ['metric1', 'metric2'])
sub select_arrays {
  my ($self, $time_from, $time_to, $metric_filt) = @_;
  croak 'Time_from/to required' unless defined $time_from and defined $time_to;
  croak 'Metrics filter required' unless defined $metric_filt;
  my %metric_filt = map { $_ => 1 } @$metric_filt;
  $self->{time_from} = $time_from;
  $self->{time_to} = $time_to;
  my $wh = "time >= ${time_from}s AND time <= ${time_to}s";

  my $op = "SELECT $self->{fieldspec} FROM $self->{measpec} WHERE $wh LIMIT 5000";
  my $cv = AE::cv;
  my $db = AnyEvent::InfluxDB->new(server => $self->{db_config}{hf_server}, persistent => 0);

  my $guard = $db->select(database => $self->{db_config}{hf_database}, epoch => 's',
    q => $op,
    on_success => $cv,
    on_error => sub {
      $cv->croak("select_arrays() Query failure: @_");
    }
  );
  my $query = $cv->recv;

  my $r = {};
  my $mm = $self->{metrics_transformed};
  for my $ser (@$query) {
    if (exists $mm->{$ser->{name}}) {
      for my $value (@{$ser->{values}}) {
	for my $met (@{$mm->{$ser->{name}}}) {
	  #filter
	  my $mname = $met->{metric};
	  if (exists $metric_filt{$mname}) {

	    if (defined $value->{$met->{field}}) {
	      my $all_tags_good = (scalar %{$met->{tags}}) ? 0 : 1;
	    TAGS_CHECK:
	      for my $tag (keys %{$met->{tags}}) {
		if (exists $value->{$tag} and 
		  ((defined $value->{$tag} and $value->{$tag} eq $met->{tags}->{$tag})) or
		  (!defined $value->{$tag} and $met->{tags}->{$tag} eq '')) {
		  $all_tags_good = 1;
		} else {
		  $all_tags_good = 0;
		  last TAGS_CHECK;
		}
	      }
	      if ($all_tags_good) {
		$r->{$mname} = [] unless defined $r->{$mname};
		push @{$r->{$mname}}, {
		  value => $value->{$met->{field}},
		  time => $value->{time},
		};
	      } #all_tags_good
	    } #if field defined
	  } #filter
	} #loop by all metrics in this measurement
      } #loop all values
    } #if measurement found
  } #loop all series

  return $r;
}


1;
