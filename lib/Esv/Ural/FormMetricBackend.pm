package Esv::Ural::FormMetricBackend;
use Mojo::Base 'Esv::Ural::MetricBackend';

use Carp;
use Number::Format;
use Regexp::Common qw(number);
use Mojo::Util qw(xml_escape);

# $db_config = { };
# Esv::Ural::FormMetricBackend->new($db_config, $metrics_catalog);
sub new {
  my ($class, $db_config, $metrics_catalog) = @_;
  my $self = $class->SUPER::new($db_config, $metrics_catalog);
  
  $self->{formatter_get} = new Number::Format(-thousands_sep=>' ', -decimal_point=>',');
  $self->{formatter_set} = new Number::Format(-thousands_sep=>'', -decimal_point=>'.');

  return $self;
}


# internal
sub _format {
  my ($self, $metric, $value) = @_;
  my $f = $self->{metrics_catalog}->get_format($metric);
  if (defined $f and defined $f->{form} and defined $f->{form}{type}) {
    my $type = $f->{form}{type};
    if ($type eq 'decimal') { #############
      return $self->{formatter_get}->format_number($value, $f->{form}{round}, 1);

    } elsif ($type eq 'int') { ############
      return int $value;

    } elsif ($type eq 'text') { ###########
      $value = xml_escape $value; # important!
      return $value;

    } elsif ($type eq 'sost_lgosk') { #####
      return int $value;

    } elsif ($type eq 'date') { ###########
      if ($value =~ m/^(\d{4})-(\d{2})-(\d{2})$/) {
	return "$3.$2.$1";
      } else {
        carp "Bad date format for metric $metric";
        return '';
      }

    } else { ###########################
      carp "Unsupported FORM format type for metric $metric";
      return $value;
    }
  } else {
    carp "Invalid FORM format type for metric $metric";
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
      #return $self->_format($metric, $v2);
      return ''; # max is required in forms
    } else {
      return '';
    }
  } else {
    # one argument mode
    return '' unless defined $v1;
    return $self->_format($metric, $v1);
  }
}


# Sets value entered in text form.  On parsing error returns undef.
# $ret_val_or_undef = $obj->set('my.metric', $text_value, $write)
sub set {
  my ($self, $metric, $text_value, $write) = @_;
  croak 'Metric is required' unless (defined $metric);
  croak 'Operation time is not defined' unless defined $self->{time_from};

  return undef unless defined $text_value;

  my $ret_text_value = $text_value;
  my $f = $self->{metrics_catalog}->get_format($metric);
  if (defined $f and defined $f->{form} and defined $f->{form}{type}) {
    my $type = $f->{form}{type};
    if ($type eq 'decimal') { #################
      $text_value =~ s/^\s+|\s+$//g; # trim
      $text_value = 0 if $text_value eq ''; # accept empty value as 0
      return undef unless ($text_value =~ /^$RE{num}{decimal}{-radix=>'[,.]'}{-sep=>'[ ]?'}$/);
      $text_value =~ s/ //g; # remove separators
      $text_value =~ s/,/./; # fix comma
      #$text_value = sprintf('%.2f', $text_value); # round

      $text_value = $self->{formatter_set}->format_number($text_value, $f->{form}{round}, 1);
      $ret_text_value = $text_value;
      $text_value .= '.0' if $f->{form}{round} <= 0; # db value must remain float
      $ret_text_value =~ s/\./,/; # fix dot back to comma in ret value

    } elsif ($type eq 'int') { #################
      $text_value =~ s/^\s+|\s+$//g; # trim
      $text_value = 0 if $text_value eq ''; # accept empty value as 0
      return undef unless ($text_value =~ /^$RE{num}{int}{-sep=>'[ ]?'}{-sign=>''}$/);
      $text_value =~ s/ //g; # remove separators

      $text_value = int $text_value;
      $ret_text_value = $text_value;

    } elsif ($type eq 'text') { ################
      # pass as is
    } elsif ($type eq 'sost_lgosk') { ##########
      $text_value = 0 unless ($text_value =~ /^\d+$/);
      $text_value = 0 if ($text_value < 0 || $text_value > 3);

      $text_value = int $text_value;
      $ret_text_value = $text_value;

    } elsif ($type eq 'date') { ################
      $text_value =~ s/^\s+|\s+$//g; # trim
      if ($text_value =~ m/^(\d{2})\.(\d{2})\.(\d{4})$/) {
        if ($1>=1 && $1<=31 && $2>=1 && $2<=12 && $3>=1970 && $3<=2025) {
	  my $e = eval { DateTime->new(year=>$3, month=>$2, day=>$1)->ymd() };
          if (defined $e) {
            $ret_text_value = $text_value;
            $text_value = $e;
	  } else {
	    return undef;
	  }
	} else {
	  return undef;
	}
      } else {
	return undef;
      }

    } else { ########################
      croak "Unsupported FORM format type for metric $metric";
    }
  } else {
    croak "Invalid FORM format type for metric $metric";
  }

  # write
  return $ret_text_value if $self->set_raw($metric, $text_value, $write);
  return undef;
}


1;
