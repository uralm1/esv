use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::ReportMetricBackend;

dies_ok( sub { Esv::Ural::ReportMetricBackend->new() }, 'Empty constructor');

my $dbcfg = eval path('test.conf')->slurp;

my $_select_groups = {
  0 => { fieldspec => 'dest, dest_spec, rep_spec, podyom, gorod, deltamonth, sob_nuzhdy',
    measpec => 'podacha',
  },
  1 => { fieldspec => 'dest, max, min',
    measpec => 'zhost',
  },
};
my $_metrics = {
  'podacha.upr.podyom' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'podyom', group=>0, format=>2 },
  'podacha.upr.gorod' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'gorod', group=>0, format=>2 },
  'podacha.upr.deltamonth' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'deltamonth', group=>0, format=>2 },
  'podacha.dema.podyom' => { measurement=>'podacha', tags=>{dest=>'dema', dest_spec=>'',rep_spec=>''}, field=>'podyom', group=>0, format=>2 },
  'podacha.dema.gorod' => { measurement=>'podacha', tags=>{dest=>'dema', dest_spec=>'',rep_spec=>''}, field=>'gorod', group=>0, format=>2 },
  'zhost.skv.max' => { measurement=>'zhost', tags=>{dest=>'skv'}, field=>'max', group=>1, format=>1 },
  'zhost.skv.min' => { measurement=>'zhost', tags=>{dest=>'skv'}, field=>'min', group=>1, format=>1 },
};
my $mc = Esv::Ural::MetricsCatalog->new($dbcfg);
$mc->_test_assign({ metrics=>$_metrics, 'select_groups'=>$_select_groups});

my $mb = Esv::Ural::ReportMetricBackend->new($dbcfg, $mc);
isa_ok($mb, 'Esv::Ural::ReportMetricBackend');

my $t = 1544572800;
$mb->set_time($t);
is($mb->get('unknown.metric'), 'н/д', 'get() unknown metric');
is($mb->get('podacha.upr.podyom'), '327 927,39', 'podacha.upr.podyom');
is($mb->get('zhost.skv.max'), '5,1', 'zhost.skv.max');

is($mb->get('zhost.skv.max', 'zhost.skv.min'), '5,1', 'zhost.skv.max-zhost.skv.min');
is($mb->get('podacha.upr.podyom','podacha.upr.gorod'), '345 534,87-327 927,39', 'podacha.upr.podyom-podacha.upr.gorod');

dies_ok( sub { $mb->set_raw() }, 'set_raw() is unsupported');
dies_ok( sub { $mb->write }, 'write() is unsupported');


done_testing();
