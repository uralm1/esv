package Esv::Ural::Report;
use Mojo::Base 'Esv::Ural::ReportBase';

use Carp;
use DateTime;
use Esv::Ural::ReportMetricBackend;

# Esv::Ural::Report->new($controller);
sub new {
  my ($class, $controller) = @_;
  my $self = $class->SUPER::new($controller);

  $self->{report_date_epoch} = 0;
  $self->{report_date_dt} = undef;

  $controller->stash(mb => Esv::Ural::ReportMetricBackend->new($controller->config, $controller->metric_catalog));

  return $self;
}


# $r = $obj->set_date($e)
sub set_date {
  my ($self, $e) = @_;
  my $b = undef;
  if ($b = $self->validate_epoch($e)) {
    $self->{report_date_epoch} = $e;
    $self->{report_date_dt} = DateTime->from_epoch(epoch=>$e, locale=>'ru', 
      time_zone=>$self->{c}->stash('utc_tz'));

    $self->{c}->stash('mb')->set_time($e, $e+86400);
  }
  return $b;
}


# 'weekday 10.02.2019' = $obj->report_date;
sub report_date {
  my $self = shift;
  return 'Дата отчета не указана' unless $self->{report_date_dt};
  return ucfirst $self->{report_date_dt}->strftime('%A %d.%m.%Y');
}

# '10.02.2019' = $obj->vneplan_otkl_date;
sub vneplan_otkl_date {
  my $self = shift;
  return 'н/д' unless $self->{report_date_dt};
  return $self->{report_date_dt}->strftime('%d.%m.%Y');
}

# '11.02.2019' = $obj->plan_otkl_date;
sub plan_otkl_date {
  my $self = shift;
  return 'н/д' unless $self->{report_date_dt};
  return $self->{report_date_dt}->clone->add(days=>1)->strftime('%d.%m.%Y');
}


1;
