package Esv::Command::load1;
use Mojo::Base 'Mojolicious::Command';

use Data::Dumper;
use DateTime;
use DateTime::Format::MySQL;
use Mojo::Log;
use Mojo::mysql;
use DBI;
use DBD::ODBC;
use Time::HiRes qw(usleep);
use Regexp::Common qw(number);

use Esv::Ural::LoaderMetricBackend;
use Esv::Ural::CheckDB;
use Esv::Ural::LoaderUtil;


has description => 'Load old DB: podacha, zhost, ostcl, otkl, kt';
has usage => "Usage: APPLICATION load1\n";

has loader_name => 'loader1';

sub run {
  my $self = shift;
  my $app = $self->app;
  my $log = Mojo::Log->new;

  binmode(STDOUT, ':utf8');
  #binmode(STDERR, ':utf8');

  $log->info($self->loader_name.' запуск (InfluxDB на '.$app->config('hf_server').')');

  # check influx db
  Esv::Ural::CheckDB::ping($app->config) or die "База InfluxDB недоступна";

  # get current timestamp
  my $current_ts = Esv::Ural::LoaderUtil::get_current_timestamp($app->config, $self->loader_name);

  $log->info("CURRENT TIMESTAMP is: $current_ts");
  my $dt_current_ts = DateTime::Format::MySQL->parse_datetime($current_ts);
  my $dt_today = DateTime->today;
  $dt_current_ts = $dt_today if $dt_current_ts > $dt_today;
  $dt_current_ts->subtract(days => 3);


  my $dbname = 'sheets';
  my $dbh = DBI->connect($app->config('old_server_oper'),
    $app->config('old_server_oper_user'), $app->config('old_server_oper_pass'),
    { odbc_utf8_on => 1 })
    or die "Ошибка подключения к базе данных: $DBI::errstr";

  $dbh->{LongReadLen} = 16000;
  $dbh->{LongTruncOk} = 1;

  $dbh->do("USE $dbname") or die $dbh->errstr;
  $log->info("Успешное подключение к базе данных $dbname");

  my $s = $dbh->prepare("SELECT \
h.dot, h.pod1, h.pod2, h.pod3, h.pod4, h.pod5, h.pod6, h.pod7, h.pod8, h.ikpod9, \
h.gor1, h.gor2, h.gor3, h.gor4, h.gor5, h.gor6, h.gor7, h.gor8, h.ikgor9, \
h.mes1, h.mes2, h.mes3, h.mes4, h.mes5, h.mes6, h.mes7, h.mes8, \
h.zhest_sgv, h.zhest_skv, h.zhest_ugv_max, h.zhest_dem_max, h.zhest_iz, h.zhest_shk_max, h.zhest_kop_max, \
h.zhest_data_dem, h.zhest_data_shk, h.zhest_data_kop, \
h.ostxlorsvobkmin, h.ostxlorsvobk, h.ostxlorsvazkmin, h.ostxlorsvazk, \
s.kolxlorostatochn, h.ostxloru, h.ostxlorsvobdem, h.ostxlorsvobiz, \
h.mes5gen, h.vodasebekv, h.dsobn, \
h.pavl_prit, h.pavl_rest, h.pavl_hlev, h.pavl_llev, \
h.t_avg_skv, h.t_avg_iv, h.t_avg_ugv, h.t_avg_gsk, \
h.uroven, h.head_level, h.mutrek, h.mutsgv, h.mutkov, \
h.ochstok, h.mexotchist, h.skv8, h.g_1_3bl, h.g_1_4bl, \
h.proces, h.proces_vlazh, h.obezvozhosadka, h.obez_vlazh, h.visyshosadka, h.visysh_vlazh, \
h.l_kot_1, h.l_kot_2, h.l_kot_3, h.l_kot_4, h.l_dekt_1, h.l_dekt_2, h.l_dekt_3, h.l_dry_1, h.l_dry_2, \
h.rabskv1, h.rabskv3, h.rabskv5, h.rabskv6, h.rabskv7, h.rabskv8, \
h.disconskv1, h.disconskv3, h.disconskv5, h.disconskv6, h.disconskv7, h.disconskv8, \
h.rezskv1, h.rezskv3, h.rezskv5, h.rezskv6, h.rezskv7, h.rezskv8, \
h.remskv1, h.remskv3, h.remskv5, h.remskv6, h.remskv7, h.remskv8, \
h.remskvotk1, h.remskvotk3, h.remskvotk5, h.remskvotk6, h.remskvotk7, h.remskvotk8, \
h.remskvnasos1, h.remskvnasos3, h.remskvnasos5, h.remskvnasos6, h.remskvnasos7, h.remskvnasos8, \
h.remskvnowater1, h.remskvnowater3, h.remskvnowater5, h.remskvnowater6, h.remskvnowater7, h.remskvnowater8, \
h.remontskvaz1, h.remontskvaz3, h.remontskvaz5, h.remontskvaz6, h.remontskvaz7, h.remontskvaz8, \
h.sgv_kip, h.ugv_kip, h.dem_kip, h.iz_kip, h.shk_kip, h.kp_kip, \
h.sgv_pow, h.ugv_pow, h.dem_pow, h.iz_pow, h.shk_pow, h.kp_pow, \
h.sgv_asu, h.ugv_asu, h.dem_asu, h.iz_asu, h.shk_asu, h.kp_asu, \
CAST(h.rem AS TEXT) AS remtext, h.nopd_ysws1, h.nopd_ysws2, h.nopd_yzws1, h.nopd_yzws2, \
h.ktbot1, h.ktbot2, h.ktbot3, h.ktbot4, h.ktbot5, \
h.ktmin1, h.ktmin2, h.ktmin3, h.ktmin4, h.ktmin5, h.ktmin6, h.ktmin7, h.ktmin8, h.ktmin9, \
h.ktmax1, h.ktmax2, h.ktmax3, h.ktmax4, h.ktmax5, h.ktmax6, h.ktmax7, h.ktmax8, h.ktmax9, h.ktmax10 \
FROM dbo.HarDayTable h \
LEFT JOIN dbo.svodka s ON h.dot = s.dot \
WHERE h.dot > ? ORDER BY h.dot");
  #$s->execute('2018-12-12'); #DEBUG
  $s->execute(DateTime::Format::MySQL->format_datetime($dt_current_ts));

  my $mc = Esv::Ural::MetricsCatalog->new($app->config);
  my $mb = Esv::Ural::LoaderMetricBackend->new($app->config, $mc);

  while (my $hr = $s->fetchrow_hashref) {
    my $dot_dt = DateTime::Format::MySQL->parse_datetime($hr->{dot});
    my $dot = $dot_dt->epoch();
    $log->info('Обрабатывается дата: '.$dot_dt->ymd().' = '.$dot);
    #say 'Now: '.DateTime->now()->epoch();
    $mb->set_time($dot);

    #############################################
    #сгв
    $mb->set('podacha.sgv.podyom', $hr->{pod1});
    $mb->set('podacha.sgv.gorod', $hr->{gor1});
    $mb->set('podacha.sgv.deltamonth', $hr->{mes1});
    $mb->set('zhost.sgv.max', $hr->{zhest_sgv});

    if (my $r_cl = parse_cl($hr->{kolxlorostatochn})) {
      $mb->set('ostcl.sgv.max', $r_cl->{max});
      $mb->set('ostcl.sgv.min', $r_cl->{min}) if exists $r_cl->{min};
    }

    #ковшовый скв
    $mb->set('podacha.skv.podyom', $hr->{pod2});
    $mb->set('podacha.skv.gorod', $hr->{gor2});
    $mb->set('podacha.skv.deltamonth', $hr->{mes2});
    $mb->set('zhost.skv.max', $hr->{zhest_skv});
    $mb->set('ostcl.skv.svob.max', $hr->{ostxlorsvobk});
    $mb->set('ostcl.skv.svob.min', $hr->{ostxlorsvobkmin});
    $mb->set('ostcl.skv.svaz.max', $hr->{ostxlorsvazk});
    $mb->set('ostcl.skv.svaz.min', $hr->{ostxlorsvazkmin});
    
    #юв
    $mb->set('podacha.uv.podyom', $hr->{pod3});
    $mb->set('podacha.uv.gorod', $hr->{gor3});
    $mb->set('podacha.uv.deltamonth', $hr->{mes3});
    $mb->set('zhost.uv.max', $hr->{zhest_ugv_max});
    #$mb->set('zhost.uv.min', $hr->{zhest_ugv_min});

    if (my $r_cl = parse_cl($hr->{ostxloru})) {
      $mb->set('ostcl.uv.max', $r_cl->{max});
      $mb->set('ostcl.uv.min', $r_cl->{min}) if exists $r_cl->{min};
    }

    #дема
    my $f4 = undef;
    $f4 = z($hr->{gor4}) - z($hr->{gor5}) if (defined($hr->{gor4}) && defined($hr->{gor5}));
    $mb->set('podacha.dema.podyom', $f4);
    $mb->set('podacha.dema.dema_1p.podyom', $hr->{pod4});#always NULL
    $mb->set('podacha.dema.dema_2p.gorod', $hr->{gor4});
    $mb->set('podacha.dema.dema_gorod.gorod', $hr->{gor5});
    $mb->set('podacha.dema.deltamonth', $hr->{mes5});
    $mb->set('podacha.dema.gendir.deltamonth', $hr->{mes5gen});
    $mb->set('zhost.dema.max', $hr->{zhest_dem_max});
    $mb->set('zhost.dema.date', $hr->{zhest_data_dem});

    if (my $r_cl = parse_cl($hr->{ostxlorsvobdem})) {
      $mb->set('ostcl.dema.svob.max', $r_cl->{max});
      $mb->set('ostcl.dema.svob.min', $r_cl->{min}) if exists $r_cl->{min};
    }

    #изяк
    $mb->set('podacha.iz.podyom', $hr->{pod6});
    $mb->set('podacha.iz.gorod', $hr->{gor6});
    $mb->set('podacha.iz.deltamonth', $hr->{mes6});
    $mb->set('zhost.iz.max', $hr->{zhest_iz});

    if (my $r_cl = parse_cl($hr->{ostxlorsvobiz})) {
      $mb->set('ostcl.iz.svob.max', $r_cl->{max});
      $mb->set('ostcl.iz.svob.min', $r_cl->{min}) if exists $r_cl->{min};
    }

    #шакша
    $mb->set('podacha.sh.podyom', $hr->{pod7});
    $mb->set('podacha.sh.gorod', $hr->{gor7});
    $mb->set('podacha.sh.deltamonth', $hr->{mes7});
    $mb->set('zhost.sh.max', $hr->{zhest_shk_max});
    $mb->set('zhost.sh.date', $hr->{zhest_data_shk});

    #коопер.поляна
    $mb->set('podacha.kp.kp_itogo.podyom', $hr->{pod8});
    $mb->set('podacha.kp.kp_itogo.gorod', $hr->{gor8});
    $mb->set('podacha.kp.kp_ikea.podyom', $hr->{ikpod9});
    $mb->set('podacha.kp.kp_ikea.gorod', $hr->{ikgor9});
    $mb->set('podacha.kp.deltamonth', $hr->{mes8});
    $mb->set('zhost.kp.max', $hr->{zhest_kop_max});
    $mb->set('zhost.kp.date', $hr->{zhest_data_kop});

    # прочие
    $mb->set('podacha.sgv.mutnost', $hr->{mutsgv});#varchar!
    $mb->set('podacha.skv.sob_nuzhdy', $hr->{vodasebekv});#varchar!
    $mb->set('podacha.skv.mutnost', $hr->{mutkov});#varchar!
    $mb->set('podacha.reka.uroven', $hr->{uroven});#varchar!
    $mb->set('podacha.reka.pr_ogolov', $hr->{head_level});
    $mb->set('podacha.reka.mutnost', $hr->{mutrek});#varchar!

    $mb->set('pavl.pritok', $hr->{pavl_prit});
    $mb->set('pavl.sbros', $hr->{pavl_rest});
    $mb->set('pavl.v_uroven', $hr->{pavl_hlev});
    $mb->set('pavl.n_uroven', $hr->{pavl_llev});

    $mb->set('temp.skv1.dayavg', $hr->{t_avg_skv});
    $mb->set('temp.iv2.dayavg', $hr->{t_avg_iv});
    $mb->set('temp.uv2.dayavg', $hr->{t_avg_ugv});
    $mb->set('temp.gosk.dayavg', $hr->{t_avg_gsk});

    ##очистные
    $mb->set('stok.dck.och', $hr->{ochstok});#varchar!
    $mb->set('stok.gosk.gosk_meh.och', $hr->{mexotchist});#varchar!
    $mb->set('stok.gosk.gosk_bos.och', $hr->{skv8});
    $mb->set('stok.gosk.gosk_3bl.och', $hr->{g_1_3bl});
    $mb->set('stok.gosk.gosk_4bl.och', $hr->{g_1_4bl});

    $mb->set('stok.lgosk.pererab.osadok', $hr->{proces});
    $mb->set('stok.lgosk.pererab.vlazh', $hr->{proces_vlazh});
    $mb->set('stok.lgosk.obezv.osadok', $hr->{obezvozhosadka});
    $mb->set('stok.lgosk.obezv.vlazh', $hr->{obez_vlazh});
    $mb->set('stok.lgosk.vysush.osadok', $hr->{visyshosadka});
    $mb->set('stok.lgosk.vysush.vlazh', $hr->{visysh_vlazh});

    $mb->set('stok.lgosk.kotel1.sost', $hr->{l_kot_1});
    $mb->set('stok.lgosk.kotel2.sost', $hr->{l_kot_2});
    $mb->set('stok.lgosk.kotel3.sost', $hr->{l_kot_3});
    $mb->set('stok.lgosk.kotel4.sost', $hr->{l_kot_4});
    $mb->set('stok.lgosk.decanter1.sost', $hr->{l_dekt_1});
    $mb->set('stok.lgosk.decanter2.sost', $hr->{l_dekt_2});
    $mb->set('stok.lgosk.decanter3.sost', $hr->{l_dekt_3});
    $mb->set('stok.lgosk.sushka1.sost', $hr->{l_dry_1});
    $mb->set('stok.lgosk.sushka2.sost', $hr->{l_dry_2});

    # скважины
    ##СГВ
    $mb->set('skvag.sgv.num_rab', $hr->{rabskv1});
    $mb->set('skvag.sgv.num_otkl', $hr->{disconskv1});
    $mb->set('skvag.sgv.num_res', $hr->{rezskv1});
    $mb->set('skvag.sgv.rem_all.num_rem', $hr->{remskv1});
    $mb->set('skvag.sgv.rem_otkach.num_rem', $hr->{remskvotk1});
    $mb->set('skvag.sgv.rem_nasos.num_rem', $hr->{remskvnasos1});
    $mb->set('skvag.sgv.rem_bezvod.num_rem', $hr->{remskvnowater1});
    $mb->set('skvag.sgv.rem_skvag.num_rem', $hr->{remontskvaz1});
    $mb->set('skvag.sgv.rem_kipa.num_rem', $hr->{sgv_kip});
    $mb->set('skvag.sgv.rem_elec.num_rem', $hr->{sgv_pow});
    $mb->set('skvag.sgv.rem_asu.num_rem', $hr->{sgv_asu});
    ##ЮВ
    $mb->set('skvag.uv.num_rab', $hr->{rabskv3});
    $mb->set('skvag.uv.num_otkl', $hr->{disconskv3});
    $mb->set('skvag.uv.num_res', $hr->{rezskv3});
    $mb->set('skvag.uv.rem_all.num_rem', $hr->{remskv3});
    $mb->set('skvag.uv.rem_otkach.num_rem', $hr->{remskvotk3});
    $mb->set('skvag.uv.rem_nasos.num_rem', $hr->{remskvnasos3});
    $mb->set('skvag.uv.rem_bezvod.num_rem', $hr->{remskvnowater3});
    $mb->set('skvag.uv.rem_skvag.num_rem', $hr->{remontskvaz3});
    $mb->set('skvag.uv.rem_kipa.num_rem', $hr->{ugv_kip});
    $mb->set('skvag.uv.rem_elec.num_rem', $hr->{ugv_pow});
    $mb->set('skvag.uv.rem_asu.num_rem', $hr->{ugv_asu});
    ##Дёма
    $mb->set('skvag.dema.num_rab', $hr->{rabskv5});
    $mb->set('skvag.dema.num_otkl', $hr->{disconskv5});
    $mb->set('skvag.dema.num_res', $hr->{rezskv5});
    $mb->set('skvag.dema.rem_all.num_rem', $hr->{remskv5});
    $mb->set('skvag.dema.rem_otkach.num_rem', $hr->{remskvotk5});
    $mb->set('skvag.dema.rem_nasos.num_rem', $hr->{remskvnasos5});
    $mb->set('skvag.dema.rem_bezvod.num_rem', $hr->{remskvnowater5});
    $mb->set('skvag.dema.rem_skvag.num_rem', $hr->{remontskvaz5});
    $mb->set('skvag.dema.rem_kipa.num_rem', $hr->{dem_kip});
    $mb->set('skvag.dema.rem_elec.num_rem', $hr->{dem_pow});
    $mb->set('skvag.dema.rem_asu.num_rem', $hr->{dem_asu});
    ##Изяк
    $mb->set('skvag.iz.num_rab', $hr->{rabskv6});
    $mb->set('skvag.iz.num_otkl', $hr->{disconskv6});
    $mb->set('skvag.iz.num_res', $hr->{rezskv6});
    $mb->set('skvag.iz.rem_all.num_rem', $hr->{remskv6});
    $mb->set('skvag.iz.rem_otkach.num_rem', $hr->{remskvotk6});
    $mb->set('skvag.iz.rem_nasos.num_rem', $hr->{remskvnasos6});
    $mb->set('skvag.iz.rem_bezvod.num_rem', $hr->{remskvnowater6});
    $mb->set('skvag.iz.rem_skvag.num_rem', $hr->{remontskvaz6});
    $mb->set('skvag.iz.rem_kipa.num_rem', $hr->{iz_kip});
    $mb->set('skvag.iz.rem_elec.num_rem', $hr->{iz_pow});
    $mb->set('skvag.iz.rem_asu.num_rem', $hr->{iz_asu});
    ##Шакша
    $mb->set('skvag.sh.num_rab', $hr->{rabskv7});
    $mb->set('skvag.sh.num_otkl', $hr->{disconskv7});
    $mb->set('skvag.sh.num_res', $hr->{rezskv7});
    $mb->set('skvag.sh.rem_all.num_rem', $hr->{remskv7});
    $mb->set('skvag.sh.rem_otkach.num_rem', $hr->{remskvotk7});
    $mb->set('skvag.sh.rem_nasos.num_rem', $hr->{remskvnasos7});
    $mb->set('skvag.sh.rem_bezvod.num_rem', $hr->{remskvnowater7});
    $mb->set('skvag.sh.rem_skvag.num_rem', $hr->{remontskvaz7});
    $mb->set('skvag.sh.rem_kipa.num_rem', $hr->{shk_kip});
    $mb->set('skvag.sh.rem_elec.num_rem', $hr->{shk_pow});
    $mb->set('skvag.sh.rem_asu.num_rem', $hr->{shk_asu});
    ##Кооперативная поляна
    $mb->set('skvag.kp.num_rab', $hr->{rabskv8});
    $mb->set('skvag.kp.num_otkl', $hr->{disconskv8});
    $mb->set('skvag.kp.num_res', $hr->{rezskv8});
    $mb->set('skvag.kp.rem_all.num_rem', $hr->{remskv8});
    $mb->set('skvag.kp.rem_otkach.num_rem', $hr->{remskvotk8});
    $mb->set('skvag.kp.rem_nasos.num_rem', $hr->{remskvnasos8});
    $mb->set('skvag.kp.rem_bezvod.num_rem', $hr->{remskvnowater8});
    $mb->set('skvag.kp.rem_skvag.num_rem', $hr->{remontskvaz8});
    $mb->set('skvag.kp.rem_kipa.num_rem', $hr->{kp_kip});
    $mb->set('skvag.kp.rem_elec.num_rem', $hr->{kp_pow});
    $mb->set('skvag.kp.rem_asu.num_rem', $hr->{kp_asu});


    # отключения
    ##плановые отключения
    $mb->set('otkl.plan', $hr->{remtext});

    ##внеплановые отключения
    $mb->set('otkl.usvs.uvk.num_vneplan', $hr->{nopd_ysws1});
    $mb->set('otkl.usvs.zayav.num_vneplan', $hr->{nopd_ysws2});
    $mb->set('otkl.uzvs.uvk.num_vneplan', $hr->{nopd_yzws1});
    $mb->set('otkl.uzvs.zayav.num_vneplan', $hr->{nopd_yzws2});

    # контрольные точки
    ##справочные
    $mb->set('kt.sgv_2p.sprav', $hr->{ktbot1});
    $mb->set('kt.sgv_3p.sprav', $hr->{ktbot2});
    $mb->set('kt.gors.sprav', $hr->{ktbot3});
    $mb->set('kt.cds.sprav', $hr->{ktbot4});
    $mb->set('kt.plk.sprav', $hr->{ktbot5});
    
    ##фактические
    $mb->set('kt.sgv_2p.fact.min', $hr->{ktmin1});
    $mb->set('kt.sgv_2p.fact.max', $hr->{ktmax1});
    $mb->set('kt.sgv_3p.fact.min', $hr->{ktmin2});
    $mb->set('kt.sgv_3p.fact.max', $hr->{ktmax2});
    $mb->set('kt.gors.fact.min', $hr->{ktmin3});
    $mb->set('kt.gors.fact.max', $hr->{ktmax3});
    $mb->set('kt.cds.fact.min', $hr->{ktmin4});
    $mb->set('kt.cds.fact.max', $hr->{ktmax4});
    $mb->set('kt.plk.fact.min', $hr->{ktmin5});
    $mb->set('kt.plk.fact.max', $hr->{ktmax5});
    $mb->set('kt.dram.fact.min', $hr->{ktmin6});
    $mb->set('kt.dram.fact.max', $hr->{ktmax6});
    $mb->set('kt.oktrvk.fact.min', $hr->{ktmin7});
    $mb->set('kt.oktrvk.fact.max', $hr->{ktmax7});
    $mb->set('kt.telc.fact.min', $hr->{ktmin8});
    $mb->set('kt.telc.fact.max', $hr->{ktmax8});
    $mb->set('kt.dynamo.fact.min', $hr->{ktmin9});
    $mb->set('kt.dynamo.fact.max', $hr->{ktmax9});
    ##птицефабрика
    $mb->set('kt.ptfab.podacha', $hr->{ktmax10});


    #############################################
    # write
    #say Dumper $mb->{lw}->dump;
    my $r = $mb->write;
    if (defined $r) {
      $log->info('Успешная запись в InfluxDB') if $r > 0;
      # update service record
      Esv::Ural::LoaderUtil::set_current_timestamp($app->config, $self->loader_name,
        DateTime::Format::MySQL->format_datetime($dot_dt));

      usleep(150000);
    } else {
      die "Ошибка записи в InfluxDB время $dot";
    }
  }
  $log->info("Обработано: ".$s->rows." строк");
  $s->finish;

  $dbh->disconnect;

  $log->info($self->loader_name.' синхронизация закончена');
  exit 0;
}


#-------------------------------------------------
sub z {
  shift || 0.0;
}


sub parse_cl {
  my $s = shift;
  if ($s) {
    if ($s =~ m/\s*(\d+(?:[,.]\d+)?)(?:\s*-\s*(\d+(?:[,.]\d+))?)?/) {
      my $r;
      my ($first, $second) = ($1, $2);
      if ($first) {
        $first =~ s/,/./;
	if ($second) {
          $second =~ s/,/./;
	  #say "parse min: $first, max: $second";
	  return { min => $first, max => $second };
	} else {
	  #say "parse max: $first";
	  return { max => $first };
	}
      }
    }
  }
  return undef;
}


1;
