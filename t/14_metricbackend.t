use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::MetricBackend;

dies_ok( sub { Esv::Ural::MetricBackend->new() }, 'Empty constructor');

my $dbcfg = eval path('test.conf')->slurp;

my $_select_groups = {
  0 => { fieldspec => 'dest, dest_spec, rep_spec, podyom, gorod, deltamonth, sob_nuzhdy',
    measpec => 'podacha',
  },
  1 => { fieldspec => 'dest, max, min',
    measpec => 'zhost',
  },
  2 => { fieldspec => 'plan',
    measpec => 'otkl',
  },
};
my $_metrics = {
  'podacha.upr.podyom' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'podyom', group=>0 },
  'podacha.upr.gorod' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'gorod', group=>0 },
  'podacha.upr.deltamonth' => { measurement=>'podacha', tags=>{dest=>'upr'}, field=>'deltamonth', group=>0 },
  'podacha.dema.podyom' => { measurement=>'podacha', tags=>{dest=>'dema', dest_spec=>'',rep_spec=>''}, field=>'podyom', group=>0 },
  'podacha.dema.gorod' => { measurement=>'podacha', tags=>{dest=>'dema', dest_spec=>'',rep_spec=>''}, field=>'gorod', group=>0 },
  'zhost.skv.max' => { measurement=>'zhost', tags=>{dest=>'skv'}, field=>'max', group=>1 },
  'zhost.skv.min' => { measurement=>'zhost', tags=>{dest=>'skv'}, field=>'min', group=>1 },
  'podacha.nag.gorod' => { measurement=>'podacha', tags=>{dest=>'nag'}, field=>'gorod', group=>0, format=>2 },
  'otkl.plan' => { measurement=>'otkl', tags=>{}, field=>'plan', group=>2, format=>4 },
};
my $mc = Esv::Ural::MetricsCatalog->new($dbcfg);
$mc->_test_assign({ metrics=>$_metrics, 'select_groups'=>$_select_groups});

my $mb = Esv::Ural::MetricBackend->new($dbcfg, $mc);
isa_ok($mb, 'Esv::Ural::MetricBackend');

dies_ok( sub { $mb->get_raw() }, 'get_raw() without metric');
dies_ok( sub { $mb->get_raw('test') }, 'get_raw() without time');

my $t = 1544572800;
$mb->set_time($t);
is($mb->get_raw('unknown.metric'), undef, 'get_raw() unknown metric');
is($mb->get_raw('podacha.upr.podyom'), 327927.39, 'podacha.upr.podyom');
is($mb->get_raw('zhost.skv.max'), 5.1, 'zhost.skv.max');

$mb->invalidate;
is($mb->get_raw('podacha.upr.podyom'), 327927.39, 'podacha.upr.podyom 2');
is($mb->get('podacha.upr.podyom'), 327927.39, 'podacha.upr.podyom via get()');
is($mb->get('zhost.skv.max'), 5.1, 'zhost.skv.max via get()');

dies_ok( sub { $mb->set_raw() }, 'set_raw() without metric');
dies_ok( sub { $mb->set_raw('unknown.metric') }, 'set_raw() without data');

ok($mb->set_raw('podacha.nag.gorod', 543.21, 1), 'set_raw(podacha.nag.gorod, 543.21, 1) returned true');
$mb->invalidate;
is($mb->get_raw('podacha.nag.gorod'), '543.21', 'check value 543.21 is set');

ok($mb->set_raw('podacha.nag.gorod', 123.45), 'set_raw(podacha.nag.gorod, 123.45) returned true');
ok($mb->write, 'write() returned true');
$mb->invalidate;
is($mb->get_raw('podacha.nag.gorod'), '123.45', 'check value 123.45 is set');

is($mb->set('podacha.nag.gorod', '12345.678', 1), '12345.678', 'set(podacha.nag.gorod, 12345.678) returns 12345.678 and warns');
$mb->invalidate;
is($mb->get_raw('podacha.nag.gorod'), 12345.678, 'check value 12345.678 is set');

ok($mb->set_raw('otkl.plan', "Урал", 1), 'set_raw(otkl.plan, multibyte string) returned true');
$mb->invalidate;
is($mb->get_raw('otkl.plan'), "Урал", 'check multibyte value is written');

done_testing();
