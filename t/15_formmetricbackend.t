use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::FormMetricBackend;

dies_ok( sub { Esv::Ural::FormMetricBackend->new() }, 'Empty constructor');

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
  'podacha.nag.gorod' => { measurement=>'podacha', tags=>{dest=>'nag'}, field=>'gorod', group=>0, format=>2 },
};
my $mc = Esv::Ural::MetricsCatalog->new($dbcfg);
$mc->_test_assign({ metrics=>$_metrics, 'select_groups'=>$_select_groups});

my $mb = Esv::Ural::FormMetricBackend->new($dbcfg, $mc);
isa_ok($mb, 'Esv::Ural::FormMetricBackend');

my $t = 1544572800; #12-12-2018
$mb->set_time($t);
is($mb->get('unknown.metric'), '', 'get() unknown metric');
is($mb->get_raw('podacha.upr.podyom'), '327927.39', 'podacha.upr.podyom - raw');
is($mb->get('podacha.upr.podyom'), '327 927,39', 'podacha.upr.podyom - formatted');
is($mb->get('zhost.skv.max'), '5,1', 'zhost.skv.max');

is($mb->get('zhost.skv.max', 'zhost.skv.min'), '5,1', 'zhost.skv.max-zhost.skv.min');
is($mb->get('podacha.upr.podyom','podacha.upr.gorod'), '345 534,87-327 927,39', 'podacha.upr.podyom-podacha.upr.gorod');

dies_ok( sub { $mb->set() }, 'set() without metric');
ok(!defined $mb->set('unknown.metric'), 'set() returns undef without data');

ok(!defined($mb->set('podacha.nag.gorod', 'asd12345,67890')), 'set bad value returns undef');
is($mb->set('podacha.nag.gorod', '12345,67890', 1), '12345,68', 'set(podacha.nag.gorod, 12345,67890) returns 12345,68');
$mb->invalidate;
is($mb->get_raw('podacha.nag.gorod'), 12345.68, 'check value 12345.68 is set');


done_testing();
