use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::PeriodicMetricBackend;

dies_ok( sub { Esv::Ural::PeriodicMetricBackend->new() }, 'Empty constructor');

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

my $pmb = Esv::Ural::PeriodicMetricBackend->new($dbcfg, $mc);
isa_ok($pmb, 'Esv::Ural::PeriodicMetricBackend');

dies_ok( sub { $pmb->get_raw() }, 'get_raw() without metrics');
dies_ok( sub { $pmb->get_raw(['test']) }, 'get_raw() without time');

#$pmb->set_time(1037232000, 1037750401);
$pmb->set_time(1540944000, 1541808001);
my $r = $pmb->get_raw(['podacha.dema.podyom', 'podacha.dema.gorod', 'zhost.skv.max']);
diag explain $r;
ok(@{$r->{'podacha.dema.podyom'}} > 0, 'podacha.dema.podyom in result array');
ok(@{$r->{'zhost.skv.max'}} > 0, 'zhost.skv.max in result array');

done_testing();
