package Esv::Ural::ReportMetricBackend;
use Mojo::Base 'Esv::Ural::MetricBackend';

use Carp;
use Number::Format;
use Regexp::Common qw(number);
use Mojo::Util qw(xml_escape);

# $db_config = { };
# Esv::Ural::ReportMetricBackend->new($db_config, $metrics_catalog);
sub new {
  my ($class, $db_config, $metrics_catalog) = @_;
  my $self = $class->SUPER::new($db_config, $metrics_catalog);
  
  $self->{formatter} = new Number::Format(-thousands_sep=>' ', -decimal_point=>',');

  return $self;
}

# internal
sub _format {
  my ($self, $metric, $value) = @_;
  my $f = $self->{metrics_catalog}->get_format($metric);
  if (defined $f and defined $f->{report} and defined $f->{report}{type}) {
    my $type = $f->{report}{type};
    if ($type eq 'decimal') { ##################
      return $self->{formatter}->format_number($value, $f->{report}{round}, 1);
    } elsif ($type eq 'int') { #################
      return int $value;
    } elsif ($type eq 'text') { ################
      ### <br>
      $value = xml_escape $value; # important!
      $value =~ s/$/<br>/mg;
      return $value;
    } elsif ($type eq 'sost_lgosk') { ##########
      if ($value == 0) {
	return 'работа';
      } elsif ($value == 1) {
	return 'ТО';
      } elsif ($value == 2) {
	return 'резерв';
      } elsif ($value == 3) {
	return 'ремонт';
      } else {
	return 'неизвестно';
      }
    } elsif ($type eq 'date') { ################
      if ($value =~ m/^(\d{4})-(\d{2})-(\d{2})$/) {
	return "$3.$2.$1";
      } else {
        carp "Bad date format for metric $metric";
        return 'неизвестно';
      }
    } else { ###############################
      carp "Unsupported REPORT format type for metric $metric";
      return $value;
    }
  } else {
    carp "Invalid REPORT format type for metric $metric";
    return $value;
  }
}

# $r = $obj->get('my.metric')
# $r = $obj->get('my.metric.max', 'my.metric.min')
sub get {
  my ($self, $metric, $metric2_min) = @_;
  my $v1 = $self->get_raw($metric);
  if (defined $metric2_min) {
    # two argument mode
    my $v2 = $self->get_raw($metric2_min);
    if (defined $v1) {
      if (defined $v2 and $v2 ne $v1) {
	# both v1 and v2
        return $self->_format($metric, $v2).'-'.$self->_format($metric, $v1);
      } else {
	# only v1 or same
        return $self->_format($metric, $v1);
      }
    } elsif (defined $v2) {
      # only v2
      return $self->_format($metric, $v2);
    } else {
      return 'н/д';
    }
  } else {
    # one argument mode
    return 'н/д' unless defined $v1;
    return $self->_format($metric, $v1);
  }
}


# one argument variant of get() that doesn't print 'н/д'
# $r = $obj->get_nond('my.metric')
sub get_nond {
  my ($self, $metric) = @_;
  my $v = $self->get_raw($metric);
  return '' unless defined $v;
  return $self->_format($metric, $v);
}


# $r = $obj->get_formula('my.metric')
sub get_formula {
  my ($self, $metric) = @_;
  my $v = $self->get_raw($metric);
  my $f = $self->{metrics_catalog}->get_format($metric);
  if (defined $f and defined $f->{report} and defined $f->{report}{type}) {
    my $type = $f->{report}{type};
    if ($type eq 'decimal') {
      return (defined $v and $v =~ /^$RE{num}{decimal}$/) ? $v : 0.0;
    } elsif ($type eq 'int') {
      return (defined $v and $v =~ /^$RE{num}{int}$/) ? $v : 0;
    } else {
      croak "Unsupported report format type for formulas";
      return 0;
    }
  } else {
    carp "Invalid report format type for metric $metric";
    return 0;
  }
}


# $b = $obj->set_raw('my.metric', $float_value)
sub set_raw {
  #my ($self, $metric, $value) = @_;
  croak "Function set_raw() is unsupported by the report class";
}

# $b = $obj->write
sub write {
  #my $self = shift;
  croak "Function write() is unsupported by the report class";
}


1;
