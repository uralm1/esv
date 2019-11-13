package Esv::Ural::LoaderMetricBackend;
use Mojo::Base 'Esv::Ural::MetricBackend';

use Carp;
use Number::Format;
use Regexp::Common qw(number);
use Mojo::Util qw(xml_escape);

# $db_config = { };
# Esv::Ural::LoaderMetricBackend->new($db_config, $metrics_catalog);
sub new {
  my ($class, $db_config, $metrics_catalog) = @_;
  my $self = $class->SUPER::new($db_config, $metrics_catalog);
  
  $self->{formatter_set} = new Number::Format(-thousands_sep=>'', -decimal_point=>'.');

  return $self;
}


# $r = $obj->get('my.metric')
sub get {
  my ($self, $metric) = @_;

  carp "Loader class get() returns unformatted result";
  return $self->get_raw($metric);
}


# $true_or_undef = $obj->set('my.metric', $db_value, $write)
sub set {
  my ($self, $metric, $db_value, $write) = @_;
  croak 'Metric is required' unless (defined $metric);
  croak 'Operation time is not defined' unless defined $self->{time_from};

  return undef unless defined $db_value;

  my $f = $self->{metrics_catalog}->get_format($metric);
  if (defined $f and defined $f->{form} and defined $f->{form}{type}) {
    my $type = $f->{form}{type};
    if ($type eq 'decimal') { #################
      $db_value =~ s/^\s+|\s+$//g; # trim
      $db_value =~ s/^[<>]//g; # remove signs
      return undef if $db_value eq ''; # reject empty value
      # accept floats too (with sign)
      return undef unless ($db_value =~ /^$RE{num}{real}{-radix=>'[,.]'}{-sep=>'[ ]?'}$/);
      $db_value =~ s/ //g; # remove separators
      $db_value =~ s/,/./; # fix comma
      #$db_value = sprintf('%.2f', $text_value); # round

      $db_value = $self->{formatter_set}->format_number($db_value, $f->{form}{round}, 1);
      $db_value .= '.0' if $f->{form}{round} <= 0; # db value must remain float

    } elsif ($type eq 'int' or $type eq 'sost_lgosk') { #################
      $db_value =~ s/^\s+|\s+$//g; # trim
      return undef if $db_value eq ''; # reject empty value
      # accept floats too (with sign)
      return undef unless ($db_value =~ /^$RE{num}{real}{-radix=>'[,.]'}{-sep=>'[ ]?'}$/);
      $db_value =~ s/ //g; # remove separators
      $db_value =~ s/,/./; # fix comma
      # and ... round to int
      $db_value = int $db_value;

    } elsif ($type eq 'text') { ################
      # pass as is
    } elsif ($type eq 'date') { ################
      $db_value =~ s/^\s+|\s+$//g; # trim
      return undef if $db_value eq ''; # reject empty value
      # YYYY-MM-DD [some shit after]
      if ($db_value =~ m/^(\d{4}-\d{2}-\d{2})/) {
        $db_value = $1;
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
  return $self->set_raw($metric, $db_value, $write);
}


# $true_or_undef = $obj->set_safe('my.metric', $db_value, $write)
sub set_safe {
  my ($self, $metric, $db_value, $write) = @_;
  croak 'Metric is required' unless (defined $metric);

  my $r = $self->get_raw($metric);
  return $self->set($metric, $db_value, $write) unless defined $r;
  0;
}


1;
