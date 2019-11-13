use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::LoaderMetricBackend;

dies_ok( sub { Esv::Ural::LoaderMetricBackend->new() }, 'Empty constructor');

my $cfg = eval path('test.conf')->slurp;

my $mc = Esv::Ural::MetricsCatalog->new($cfg);
$mc->_test_assign({ metrics=>$cfg->{test_metrics}, 'select_groups'=>$cfg->{test_select_groups}});

my $mb = Esv::Ural::LoaderMetricBackend->new($cfg, $mc);
isa_ok($mb, 'Esv::Ural::LoaderMetricBackend');

my $t = 1544572800; #12-12-2018
$mb->set_time($t);

is($mb->get('unknown.metric'), undef, 'get() unknown metric');

isnt($mb->set('test1.met1', '327927,3912', 1), undef, 'set test1.met1 to 327927,3912');

is($mb->get_raw('test1.met1'), '327927.39', 'test1.met1 - raw');
is($mb->get('test1.met1'), '327927.39', 'test1.met1 - via get() - should warn');

isnt($mb->set_raw('test1.met1', '0.0', 1), undef, 'set_raw test1.met1');
$mb->invalidate;
isnt($mb->set_safe('test1.met1', '123.45', 1), undef, 'setsafe test1.met1 to 123.45');
isnt($mb->set_safe('test1.met2', '123.45', 1), undef, 'setsafe test1.met2 to 123.45');
say "test1.met1 = ".$mb->get_raw('test1.met1');
say "test1.met2 = ".$mb->get_raw('test1.met2');

done_testing();
