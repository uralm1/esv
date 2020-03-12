package Esv::Ural::MetricsCatalog;
use Mojo::Base -base;

use Carp;
use Data::Dumper;
use Mojo::mysql;
use Mojo::JSON qw(decode_json);


# $db_config = { m_server => '', m_database => '' };
# Esv::Ural::MetricsCatalog->new($db_config);
sub new {
  my ($class, $db_config) = @_;
  croak "Configuration required" unless defined $db_config;
  my $self = bless {
    db_config => $db_config,
    #
    metrics => undef,
    select_groups => undef,
    formats => undef,
    metrics_transformed => undef,
  }, $class;
  return undef unless( $self->_load && $self->_transform );
  return $self;
}

# internal
sub _load {
  my $self = shift;
  my $e = eval {
    my $mdb = Mojo::mysql->new($self->{db_config}{m_server}.'/'.$self->{db_config}{m_database});
    $self->{metrics} = {};
    my $rec = $mdb->db->query('SELECT id,description,unit,measurement,tags,field,`group`,format,form_label FROM metrics');
    while (my $next = $rec->hash) {
      $self->{metrics}{$next->{id}} = {
	description => $next->{description},
	unit => $next->{unit},
	measurement => $next->{measurement},
	tags => decode_json($next->{tags}),
	field => $next->{field},
	group => $next->{group},
	format => $next->{format},
	form_label => $next->{form_label},
      };
    }
    $rec->finish;
    $self->{select_groups} = {};
    $rec = $mdb->db->query('SELECT id,fieldspec,measpec FROM select_groups');
    while (my $next = $rec->hash) {
      $self->{select_groups}{$next->{id}} = {
	fieldspec => $next->{fieldspec},
	measpec => $next->{measpec},
      };
    }
    $rec->finish;
    $self->{formats} = {};
    $rec = $mdb->db->query('SELECT id,form,report,reportper FROM formats');
    while (my $next = $rec->hash) {
      $self->{formats}{$next->{id}} = {
	form => decode_json($next->{form}),
	report => decode_json($next->{report}),
	reportper => decode_json($next->{reportper}),
      };
    }
    $rec->finish;
  };
  unless (defined $e) {
    carp $@;
    return undef;
  }

  return 1;
}

# internal
sub _test_assign {
  my ($self, $metrics_config) = @_;
  $self->{metrics} = $metrics_config->{metrics};
  $self->{select_groups} = $metrics_config->{select_groups};
  return undef unless( $self->_transform );
  return 1;
}

# internal
sub _transform {
  my $self = shift;

  # transform metrics by measurement
  my $m_by_m = {};
  my $m = $self->{metrics};
  for my $metric_name (keys %$m) {
    my $measurement = $m->{$metric_name}{measurement};
    my $group = $m->{$metric_name}{group};
    $m_by_m->{$group}{$measurement} = [] unless exists $m_by_m->{$group}{$measurement};
    push @{$m_by_m->{$group}{$measurement}},
      { metric => $metric_name,
	tags => $m->{$metric_name}{tags},
        field => $m->{$metric_name}{field},
        group => $m->{$metric_name}{group},
      };
  }
  #say Dumper $m_by_m;
  $self->{metrics_transformed} = $m_by_m;
  return 1;
}

#
# getters
#
sub get_metrics {
  return shift->{metrics};
}

# $m = $obj->get_metric('my.metric')
sub get_metric {
  my ($self, $metric) = @_;
  unless (defined $self->{metrics}{$metric}) {
    carp "Unknown metric $metric";
    return undef;
  }
  return $self->{metrics}{$metric};
}

sub get_select_groups {
  return shift->{select_groups};
}

# $sg = $obj->get_select_group(1)
sub get_select_group {
  my ($self, $group_id) = @_;
  unless (defined $self->{select_groups}{$group_id}) {
    croak 'Undefined select group';
    return undef;
  }
  return $self->{select_groups}{$group_id};
}

# $sg = $obj->get_metrics_transformed(1)
sub get_metrics_transformed {
  my ($self, $group_id) = @_;
  unless (defined $self->{metrics_transformed}{$group_id}) {
    croak 'Undefined select group in transformed metrics';
    return undef;
  }
  return $self->{metrics_transformed}{$group_id};
}

# $m = $obj->get_format('my.metric')
sub get_format {
  my ($self, $metric) = @_;
  my $m = $self->{metrics}{$metric};
  unless (defined $m) {
    carp "Unknown metric $metric";
    return undef;
  }
  my $f = $self->{formats}{$m->{format}};
  unless (defined $f) {
    carp "Unknown format for metric $metric";
    return undef;
  }
  return $f;
}


1;
