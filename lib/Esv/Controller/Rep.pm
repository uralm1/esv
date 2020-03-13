package Esv::Controller::Rep;
use Mojo::Base 'Mojolicious::Controller';

use DateTime;

use Esv::Ural::Report;
use Esv::Ural::ReportPeriodic;

sub preview {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  $self->store_date_param;

  my $type = $self->param('rep') || $self->session('rt');
  my $epoch = $self->get_oper_date;
  return $self->render(text => 'Ошибка #1.') unless $epoch;

  my $name;
  my $url;
  my $filename = 'Предварительный просмотр';
  my $bad_rep;
  my $no_date = 0;
  if (defined $type) {
    if ($type eq 'tehdir') {
      $name = 'Отчёт:&nbsp;Сводка&nbsp;по&nbsp;предприятию';
      $url = $self->url_for('reptehdir')->query(date=>$epoch);
      $filename = DateTime->from_epoch(epoch=>$epoch, time_zone=>$self->stash('utc_tz'))->ymd.
        ' - сводка по предприятию';

    } elsif ($type eq 'temp') {
      $name = 'Отчёт:&nbsp;Температура';
      $url = $self->url_for('reptemp')->query(date=>$epoch);

    } elsif (grep {$type eq $_} qw(podyom gorod reka gosk dck)) {
      my $pstart = $self->validate_date($self->param('pstart'));
      my $pend = $self->validate_date($self->param('pend'));
      unless (defined $pstart && defined $pend) {
        $self->flash(oper => 'Ошибка. Задайте начальную и конечную даты отчёта.');
        $self->redirect_to('repperiod');
        return undef;
      }
      my $d = $pend - $pstart;
      if ($d < 0 || $d > 86400*365*3) {
        $self->flash(oper => 'Ошибка. Неверно задан интервал времени.');
        $self->redirect_to('repperiod');
        return undef;
      }
      $self->session(rds => $pstart);
      $self->session(rde => $pend);

      my $pgraph = $self->param('graph');
      my $ptable = $self->param('table');
      #say "rep: $type, pstart: $pstart, pend: $pend, graph: $pgraph, table: $ptable";

      $name = 'Просмотр&nbsp;отчёта';
      $url = $self->url_for('repper')->query(
        t => $type,
	date => $pstart, date => $pend,
	graph => ($pgraph) ? 1 : 0,
	table => ($ptable) ? 1 : 0
      );
      my $fnh = {
	podyom => 'поднято I подъемы',
	gorod => 'подано в город',
	reka => 'уровень реки Уфа и параметры Павловского водохранилища',
	gosk => 'ГОСК принято на мехочистку и БОС',
	dck => 'ДЦК очищено сточной воды',
      };
      $filename = DateTime->from_epoch(epoch=>$pstart, time_zone=>$self->stash('utc_tz'))->ymd.
        '_'.DateTime->from_epoch(epoch=>$pend, time_zone=>$self->stash('utc_tz'))->ymd.
        ' - отчет '.$fnh->{$type};
      $no_date = 1;
      # csv export
      if ($self->param('csv')) {
        my $r = Esv::Ural::ReportPeriodic->new($self, type => $type, graph => 0, table => 0);
        if ($r->set_period($pstart, $pend)) {
	  my $c = $r->csv;
	  return $self->render(text => 'Ошибка #2') unless defined $c;
	  return $self->render_file(data=>$c, filename=>$filename.'.csv');
        } else {
          return $self->render(text => 'Ошибка интервала');
        }
      }

    } else {
      $bad_rep = 1;
    }
  } else {
    $bad_rep = 1;
  }
  return $self->render(text => 'Ошибка. Неверный отчет.') if $bad_rep;

  $self->session(rt => $type);

  $self->render(repdata => { name => $name, url => $url, filename => $filename}, sidenav_no_date => $no_date);
}


sub tehdir {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  my $r = Esv::Ural::Report->new($self);
  return $self->render(text => 'Ошибка') unless ($r->set_date($self->param('date')));

  $self->render(r => $r);
}

sub temp {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  #my $r = Esv::Ural::ReportTemp->new($self);
  #return $self->render(text => 'Ошибка') unless ($r->get($self->param('date')));

  #$self->render(r => $r->build);
  $self->render();
}


sub period {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});
  $self->store_date_param;

  my $rt = $self->session('rt') || 'podyom';
  $rt = 'podyom' unless grep {$rt eq $_} qw(podyom gorod reka gosk dck);

  my $ps = $self->session('rds');
  my $pe = $self->session('rde');
  unless ($ps && $pe) {
    my $d1 = DateTime->today(time_zone=>$self->stash('utc_tz'));
    $pe = $d1->subtract(days=>1)->epoch;
    $ps = $d1->subtract(days=>7)->truncate(to=>'week')->epoch;
  }

  $self->render(def => {
    type => $rt, 
    pstart => DateTime->from_epoch(epoch=>$ps, time_zone=>$self->stash('utc_tz'))->dmy('.'),
    pend => DateTime->from_epoch(epoch=>$pe, time_zone=>$self->stash('utc_tz'))->dmy('.'),
  });
}


sub per {
  my $self = shift;
  return undef unless $self->authorize({asu=>1,cds=>1});

  my $type = $self->param('t');
  unless (defined $type and grep {$type eq $_} qw(podyom gorod reka gosk dck)) {
    return $self->render(text => 'Ошибка типа');
  }
  my $graph = $self->param('graph') ? 1 : 0;
  my $table = $self->param('table') ? 1 : 0;
  my $adata = $self->every_param('date');
  if (@$adata >= 2) {
    my $r = Esv::Ural::ReportPeriodic->new($self, type => $type, graph => $graph, table => $table);
    if ($r->set_period(@$adata)) {
      $self->render(r => $r);
    } else {
      $self->render(text => 'Ошибка интервала');
    }
  } else {
    $self->render(text => 'Недостаточно параметров');
  }
}


1;
