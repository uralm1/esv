package Esv::Controller::Disp;
use Mojo::Base 'Mojolicious::Controller';

use Carp;
use DateTime;
use Number::Format;
use Regexp::Common qw(number);

use Esv::Ural::FormMetricBackend;

sub plk {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plk');
}


sub plk2 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plk2',
    fullscreen => 1);
}


sub plkoth {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkoth');
}


sub plkskv {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkskv');
}


sub plkskv2 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkskv2',
    fullscreen => 1);
}


sub plkotkl {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkotkl');
}


sub plkkt {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkkt');
}


sub plkkt2 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  my $ep = $self->get_oper_date;
  $self->stash('mb')->set_time($ep, $ep+86400);

  $self->render(template => 'disp/plkkt2');
}


# floats, ints, date
sub plksubmit1 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  my $id = $self->param('id');
  my $v = $self->param('v');

  $self->app->log->debug("submit1 id: $id, v: $v");

  return $self->render(json => {msg=>'#101'}, status => 500) unless defined $id;
  $id = $self->id2metric($id);
  $self->app->log->debug("metric: $id");

  return $self->render(json => {msg=>'#102'}, status => 500) 
    unless ($self->metric_catalog->get_metric($id));

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  $self->stash('mb')->set_time($self->get_oper_date);
  $v = $self->stash('mb')->set($id, $v, 1);

  return $self->render(json => {msg=>'#103'}, status => 500) unless defined $v;
  return $self->render(json => {msg=>'успешно', v=>$v}, status => 200);
}


# float max min
sub plksubmit2 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  my $id = $self->param('id');
  my $v = $self->param('v');

  $self->app->log->debug("submit2 id: $id, v: $v");

  return $self->render(json => {msg=>'#101'}, status => 500) unless defined $id;
  $id = $self->id2metric($id);
  my ($m_max, $m_min) = split(/&/, $id);
  $self->app->log->debug("metric max: $m_max, min: $m_min");

  return $self->render(json => {msg=>'#102'}, status => 500) 
    unless ($self->metric_catalog->get_metric($m_max) && $self->metric_catalog->get_metric($m_min));
  #say "$m_max, $m_min";

  my ($v_min, $v_max) = split(/-/, $v);
  $v_max = $v_min unless defined $v_max;
  #say "$v_max, $v_min";

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  $self->stash('mb')->set_time($self->get_oper_date);
  $v_max = $self->stash('mb')->set($m_max, $v_max);
  $v_min = $self->stash('mb')->set($m_min, $v_min);

  return $self->render(json => {msg=>'#103'}, status => 500) unless (defined $v_max and defined $v_min);

  return $self->render(json => {msg=>'#104'}, status => 500) 
    unless ($self->stash('mb')->write);
  
  return $self->render(json => {msg=>'успешно', v=>"$v_min-$v_max"}, status => 200);
}


# big textarrea
sub plksubmit3 {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  my $id = $self->param('id');
  my $v = $self->param('v'); #always defined, can be empty

  $self->app->log->debug("submit3 id: $id, v length: ".length $v);

  return $self->render(json => {msg=>'#101'}, status => 500) unless defined $id;
  $id = $self->id2metric($id);
  $self->app->log->debug("metric: $id");

  return $self->render(json => {msg=>'#102'}, status => 500) 
    unless ($self->metric_catalog->get_metric($id));

  $self->stash(mb => Esv::Ural::FormMetricBackend->new($self->config, $self->metric_catalog));
  $self->stash('mb')->set_time($self->get_oper_date);
  $v = $self->stash('mb')->set($id, $v, 1);

  return $self->render(json => {msg=>'#103'}, status => 500) unless defined $v;
  # do not send v
  return $self->render(json => {msg=>'успешно'}, status => 200);
}


1;
