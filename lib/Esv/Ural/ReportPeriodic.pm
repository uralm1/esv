package Esv::Ural::ReportPeriodic;
use Mojo::Base 'Esv::Ural::ReportBase';

use Carp;
use DateTime;
use Text::CSV;
use Encode;
use Esv::Ural::PeriodicMetricBackend;
use Data::Dumper;

# Esv::Ural::ReportPeriodic->new($controller, type => 'podyom');
# Esv::Ural::ReportPeriodic->new($controller, type => 'podyom', graph => 1/0, table => 1/0);
sub new {
  my ($class, $controller, %args) = @_;
  my $self = $class->SUPER::new($controller);
  croak 'Report type required' unless defined $args{type};

  $self->{period_start_epoch} = 0;
  $self->{period_end_epoch} = 0;
  $self->{dt_start} = undef;
  $self->{offset} = 0; # offset for js epoch time hack
  $self->{show_graph} = $args{graph};
  $self->{show_table} = $args{table};

  $self->{t} = undef;
  $self->{tbd} = undef;

  $controller->stash(mb => Esv::Ural::PeriodicMetricBackend->new($controller->config, $controller->metric_catalog));

  # types
  my $t = {
    podyom => {
      title => 'Поднято I подъём, м<sup>3</sup>/сут.',
      unit => 'Поднято (м3/сут.)',
      gr => [
	{ metric=>'podacha.upr.podyom', formula=>1, name=>'По управлению', color=>'#e53935' },
	{ metric=>'podacha.sgv.podyom', name=>'СГВ', color=>'#ff6384' },
	{ metric=>'podacha.uv.podyom', name=>'ЮВ', color=>'#4bc0c0' },
	{ metric=>'podacha.skv.podyom', name=>'Ковшовый', color=>'#537bc4' },
	{ metric=>'podacha.dema.podyom', name=>'Дёма (I-подъём)', color=>'#9966ff' },
	{ metric=>'podacha.iz.podyom', name=>'Изяк', color=>'#36a2eb' },
	{ metric=>'podacha.sh.podyom', name=>'Шакша', color=>'#00a950' },
	{ metric=>'podacha.kp.kp_itogo.podyom', name=>'Кооп.поляна', color=>'#acc236' },
	{ metric=>'podacha.kp.kp_ikea.podyom', name=>'Икеа', color=>'#ffcd56' },
	{ metric=>'podacha.nag.podyom', name=>'Нагаево', color=>'#ff9f40' },
      ],
    },
    gorod => {
      title => 'Объёмы подачи воды в город, м<sup>3</sup>/сут.',
      unit => 'Подача (м3/сут.)',
      gr => [
	{ metric=>'podacha.upr.gorod', formula=>1, name=>'По управлению', color=>'#e53935' },
	{ metric=>'podacha.sgv.gorod', name=>'СГВ', color=>'#ff6384' },
	{ metric=>'podacha.uv.gorod', name=>'ЮВ', color=>'#4bc0c0' },
	{ metric=>'podacha.skv.gorod', name=>'Ковшовый', color=>'#537bc4' },
	{ metric=>'podacha.dema.podyom', name=>'Дёма (I-подъём)', color=>'#8044b6' },
	{ metric=>'podacha.dema.dema_2p.gorod', name=>'Дёма (II-подъём)', color=>'#9966ff' },
	{ metric=>'podacha.dema.dema_gorod.gorod', name=>'Дёма (из города)', color=>'#ffcd56' },
	{ metric=>'podacha.iz.gorod', name=>'Изяк', color=>'#36a2eb' },
	{ metric=>'podacha.sh.gorod', name=>'Шакша', color=>'#00a950' },
	{ metric=>'podacha.kp.kp_itogo.gorod', name=>'Кооп.поляна', color=>'#acc236' },
	{ metric=>'podacha.nag.gorod', name=>'Нагаево', color=>'#ff9f40' },
      ],
    },
    reka => {
      title => 'Уровень р.Уфа и основные параметры работы Павловского водохранилища',
      unit => 'Приток, сброс (м3/с)',
      gr => [
	{ metric=>'pavl.pritok', name=>'Приток', color=>'#ff6384', point_style=>'rectRot', point_radius=>5, point_hover_radius=>6 },
	{ metric=>'pavl.sbros', name=>'Сброс', color=>'#4bc0c0', point_style=>'rect', point_radius=>5, point_hover_radius=>6 },
	{ metric=>'podacha.reka.uroven', name=>'Уровень реки', fill=>1, color=>'#537bc4', bgcolor=>'#537bc440', border_width=>3, point_style=>'circle', point_radius=>3, point_hover_radius=>4, axis2=>1 },
      ],
      use_point_style => 'true',
      axis2 => 1,
      suggested_min2 => 1.5,
      suggested_max2 => 3,
      unit2 => 'Уровень реки (м)',
    },
    gosk => {
      title => 'Принято сточных вод на механическую очистку, БОС, м<sup>3</sup>/сут.',
      unit => 'м3/сут.',
      type => 'bar',
      gr => [
	{ metric=>'stok.gosk.gosk_meh.och', name=>'ГОСК принято на мехочистку', color=>'#5d4037', bgcolor=>'#5d4037a0', border_width=>2 },
	{ metric=>'stok.gosk.gosk_bos.och', name=>'ГОСК принято на БОС', color=>'#bf360c', bgcolor=>'#bf360ca0', border_width=>2 },
      ],
    },
    dck => {
      title => 'Очищено сточной воды ДЦК, м<sup>3</sup>/сут.',
      unit => 'м3/сут.',
      type => 'bar',
      gr => [
	{ metric=>'stok.dck.och', name=>'Очищено ДЦК', color=>'#5d4037', bgcolor=>'#5d4037b0', border_width=>2 },
      ],
    },
  };
  croak 'Invalid report type' unless exists $t->{$args{type}};
  my $t1 = $t->{$args{type}};
  $self->{report_type} = $args{type};
  $self->{$_} = $t1->{$_} for qw(title unit type gr use_point_style axis2 unit2 suggested_min suggested_max suggested_min2 suggested_max2);

  return $self;
}


# $r = $obj->set_period($e1, $e2)
sub set_period {
  my ($self, $e1, $e2) = @_;
  if ($self->validate_epoch($e1) && $self->validate_epoch($e2)) {
    if ($e1 < $e2) {
      $self->{period_start_epoch} = $e1;
      $self->{period_end_epoch} = $e2;
    } else {
      $self->{period_start_epoch} = $e2;
      $self->{period_end_epoch} = $e1;
    }
    return undef if ($self->{period_end_epoch} - $self->{period_start_epoch} > 86400*365*5);

    $self->{dt_start} = DateTime->from_epoch(epoch=>$self->{period_start_epoch}, locale=>'ru',
      time_zone=>$self->{c}->utc_tz);
    # offset for js epoch time hack
    $self->{offset} = $self->{c}->local_tz->offset_for_datetime($self->{dt_start});
    #say "offset: $off";

    $self->{c}->stash('mb')->set_time($self->{period_start_epoch}, $self->{period_end_epoch});
    return 1;
  } else {
    return undef;
  }
}


# $b = $obj->show_graph
sub show_graph {
  shift->{show_graph};
}

# $b = $obj->show_table
sub show_table {
  shift->{show_table};
}

# $n = $obj->title;
sub title {
  return shift->{title};
}

# $html = $obj->unit;
# $text = $obj->unit(1);
sub unit {
  my ($self, $t) = @_;
  return $self->{unit2} if defined $t and $t == 2;
  my $h = $self->{unit};
  #$h =~ s/<.*?>//g if defined $t and $t == 1;
  return $h;
}


# [] = $obj->metrics_list;
sub metrics_list {
  my $self = shift;
  return [ map { $_->{metric} } @{$self->{gr}} ];
}

# [] = $obj->metrics_list_no_formula;
sub metrics_list_no_formula {
  my $self = shift;
  my @r;
  for (@{$self->{gr}}) {
    push @r, $_->{metric} unless $_->{formula};
  }
  return \@r;
}

# [] = $obj->names_list;
sub names_list {
  my $self = shift;
  return [ map { $_->{name} } @{$self->{gr}} ];
}


# 'с 17.03.2019 по 24.03.2019' = $obj->report_period
sub report_period {
  my $self = shift;

  my $dt_end = DateTime->from_epoch(epoch=>$self->{period_end_epoch}, locale=>'ru',
      time_zone=>$self->{c}->utc_tz);
  my ($dy, $dm, $dd) = $dt_end->subtract_datetime($self->{dt_start})->add(days=>1)->in_units('years','months','days');
  my $t;
  if ($dy == 0) {
    if ($dm == 0) {
      $t = _human_days(days => $dd);
    } else {
      $dm++ if $dd != 0;
      $t = _human_days(months => $dm);
    }
  } else {
    if ($dm == 0 && $dd == 0) {
      $t = _human_days(years => $dy);
    } else {
      $dm++ if $dd != 0;
      $t = _human_days(years => $dy).' и '._human_days(months => $dm);
    }
  }

  return 'с '.$self->{dt_start}->strftime('%d.%m.%Y').' по '.$dt_end->strftime('%d.%m.%Y').', за '.$t;
}


# internal
# $t = _human_days(days/months/years => $val)
sub _human_days {
  my (%a) = @_;
  my $n = [
    ['день', 'дня', 'дней'],
    ['месяц', 'месяца', 'месяцев'],
    ['год', 'года', 'лет'],
  ];
  my $ni;
  if (defined($_ = $a{days})) {
    $ni = $n->[0];
  } elsif (defined($_ = $a{months})) {
    $ni = $n->[1];
  } elsif (defined($_ = $a{years})) {
    $ni = $n->[2];
  } else {
    croak 'Parameter required';
    return;
  }
  return "$_ $ni->[0]" if /([^1]1|^1)$/;
  return "$_ $ni->[1]" if /([^1][234]|^[234])$/;
  return "$_ $ni->[2]";
}


# internal
#my $t = $obj->load_data
sub load_data {
  my $self = shift;
  # use cached data if available
  unless ($self->{t}) {
    my $tmet = $self->{c}->stash('mb')->get_raw($self->metrics_list_no_formula);
    $self->{t} = $tmet;

    # prepare by-date table
    my %rsd;
    while (my ($metric, $a) = each %$tmet) {
      for (@$a) {
	my $t = $_->{time};
	#normalize time
	$t = int($t/86400)*86400;

	if (exists $rsd{$t}) {
	  $rsd{$t}->{$metric} = $_->{value};
	} else {
	  $rsd{$t} = { $metric, $_->{value} };
	}
      }
    }
    $self->{tbd} = \%rsd;

    # calculate some info
    for my $t (sort keys %rsd) {
      my $a = $rsd{$t};
      if ($self->{report_type} eq 'podyom') {
	# podacha.upr.podyom
	my $sum = 0;
	for (qw(podacha.sgv.podyom podacha.uv.podyom podacha.skv.podyom podacha.dema.podyom podacha.iz.podyom podacha.sh.podyom podacha.kp.kp_itogo.podyom podacha.nag.podyom)) {
	  $sum += $a->{$_} if defined $a->{$_};
	}
	#say "time = $t, sum = $sum";
	$a->{'podacha.upr.podyom'} = $sum;
	push @{$tmet->{'podacha.upr.podyom'}}, { time=>$t, value=>$sum };

      } elsif ($self->{report_type} eq 'gorod') {
        # podacha.upr.gorod
	my $sum = 0;
	for (qw(podacha.sgv.gorod podacha.uv.gorod podacha.skv.gorod podacha.dema.podyom podacha.iz.gorod podacha.sh.gorod podacha.kp.kp_itogo.gorod podacha.nag.gorod)) {
	  $sum += $a->{$_} if defined $a->{$_};
	}
	#say "time = $t, sum = $sum";
	$a->{'podacha.upr.gorod'} = $sum;
	push @{$tmet->{'podacha.upr.gorod'}}, { time=>$t, value=>$sum };
      }
    }
    #say Dumper $self->{t};
    #say Dumper $self->{tbd};
  } # unless cached

  return $self->{t};
}


# $js = $obj->js_datasets;
sub js_datasets {
  my $self = shift;

  $self->load_data;

  my $r = '';
  my $offset = $self->{offset};
  for my $el (@{$self->{gr}}) {
    my $ser = "{label:\'$el->{name}\',borderColor:\'$el->{color}\',";
    $ser .= "borderWidth:$el->{border_width},hoverBorderWidth:$el->{border_width}," if defined $el->{border_width};
    $ser .= "backgroundColor:\'" . ((defined $el->{bgcolor}) ? $el->{bgcolor}:$el->{color}) . "\',";
    $ser .= 'fill:' . (($el->{fill}) ? 'true':'false') . ',';
    $ser .= "yAxisID:\'" . (($el->{axis2}) ? 'y-axis-2':'y-axis-1') . "\',";
    $ser .= "pointStyle:\'$el->{point_style}\'," if defined $el->{point_style};
    my $ar = $self->{t}{$el->{metric}};
    if (defined $ar && scalar @$ar < 40) {
      $ser .= "pointRadius:$el->{point_radius}," if defined $el->{point_radius};
      $ser .= "pointHoverRadius:$el->{point_hover_radius}," if defined $el->{point_hover_radius};
    } else {
      $ser .= "pointRadius:0,pointHoverRadius:0," if !defined $self->{type} || $self->{type} eq 'line';
    }
    $ser .= 'data:[';

    for (@$ar) {
      my $t = ($_->{time} - $offset)*1000; # this is hack
      $ser .= "{t:new Date($t),y:$_->{value}},";
    }
    $ser .= "]},\n";
    $r .= $ser;
  }

  return $r;
}

# 'line'/'bar' = $obj->js_type;
sub js_type {
  return shift->{type} || 'line';
}

# 'true'/'false' = $obj->js_use_point_style;
sub js_use_point_style {
  my $p = shift->{use_point_style};
  return (defined $p and $p) ? 'true' : 'false';
}

# 1/undef = $obj->js_axis2;
sub js_axis2 {
  return shift->{axis2};
}

# 'suggestedMin: 1,suggestedMax:2' or undef = $obj->js_suggested(1/2);
sub js_suggested {
  my ($self, $t) = @_;
  my @a;
  if ($t == 1) {
    push(@a, 'suggestedMin:'.$self->{suggested_min}) if defined $self->{suggested_min};
    push(@a, 'suggestedMax:'.$self->{suggested_max}) if defined $self->{suggested_max};
  } elsif ($t == 2) {
    push(@a, 'suggestedMin:'.$self->{suggested_min2}) if defined $self->{suggested_min2};
    push(@a, 'suggestedMax:'.$self->{suggested_max2}) if defined $self->{suggested_max2};
  }
  return join ',', @a;
}


# {time => {m1=>v1, m2=>v2...}} = $obj->data_table;
sub data_table {
  my $self = shift;

  $self->load_data;
  return $self->{tbd};
}


# $obj->every_day(sub() { $current_epoch = shift; });
sub every_day {
  my ($self, $s) = @_;
  my $c = $self->{period_start_epoch};
  my $end = $self->{period_end_epoch};

  while ($c <= $end) {
    $s->($c);
    $c += 86400;
  }
}


# my $csv_in_string or undef = $obj->csv;
sub csv {
  my $self = shift;

  my $csv = Text::CSV->new({binary=>1, sep_char=>';', eol=>"\r\n"});
  my $csvstr;
  my $fh;
  return undef unless (open($fh, '>', \$csvstr));

  my $hdrb = [ encode('windows-1251', 'Дата') ];
  push @$hdrb, encode('windows-1251', $_) for (@{$self->names_list});
  $csv->say($fh, $hdrb);
  my $t = $self->data_table;

  my $tabcb = sub {
    my $e = shift;
    my $dt = DateTime->from_epoch(epoch=>$e, locale=>'ru', time_zone=>$self->{c}->utc_tz);

    my @a;
    push @a, $dt->strftime('%d.%m.%Y');
    for (@{$self->metrics_list}) {
      my $v = $t->{$e}{$_};
      $v =~ s/\./,/g if defined $v;
      push @a, $v;
    }
    $csv->say($fh, \@a);
  };
  $self->every_day($tabcb);
  close $fh;

  return $csvstr;
}


1;
