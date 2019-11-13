use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;
use Esv::Ural::MetricBackend;
use Esv::Ural::SelectGroup;

dies_ok( sub { Esv::Ural::SelectGroup->new() }, 'Empty constructor');
dies_ok( sub { Esv::Ural::SelectGroup->new(999, {}) }, 'Invalid GroupID');

my $cfg = eval path('test.conf')->slurp;

my $mc = Esv::Ural::MetricsCatalog->new($cfg);
$mc->_test_assign({ metrics=>$cfg->{test_metrics}, 'select_groups'=>$cfg->{test_select_groups}});

# prepare data
my $mb = Esv::Ural::MetricBackend->new($cfg, $mc);
my $tmb = 1544572800;  #2018-12-12
$mb->set_time($tmb);
$mb->set_raw('test2.met1', 327927.39);
$mb->set_raw('test2.met2', 107204.61);
$tmb = 1544659200; #2018-12-13
$mb->set_time($tmb);
$mb->set_raw('test2.met1', 337584.65);
$mb->set_raw('test2.met2', 2674.36);
$mb->write;

# test
my $g = Esv::Ural::SelectGroup->new(1, $cfg, $mc);
isa_ok($g, 'Esv::Ural::SelectGroup');

my $t = 1544572800; # 2018-12-12
my $r1 = $g->select_new($t);
my $r2 = $g->select($t);
my $r3 = $g->select();
my $r4 = $g->select(1544659200); # 2018-12-13
my $r5 = $g->select($t, 1544745600); # 12 to 14 not including
diag explain $r5;

is($r1->{'test2.met1'}->{value}, 327927.39, 'test2.met1(2018-12-12) == 327927.39');
is($r1->{'test2.met2'}->{value}, 107204.61, 'test2.met2(2018-12-12) == 107204.61');
is($r4->{'test2.met1'}->{value}, 337584.65, 'test2.met1(2018-12-13) == 337584.65');
is($r4->{'test2.met2'}->{value}, 2674.36, 'test2.met2(2018-12-13) == 2674.36');
is($r4->{'test2.met3'}->{value}, undef, 'test2.met3(2018-12-13) is empty');
is($r5->{'test2.met1'}->{value}, 337584.65, 'test2.met1(2018-12-12..2018-12-14) == 337584.65');
is($r5->{'test2.met1'}->{time}, 1544659200, 'test2.met1(2018-12-12..2018-12-14) time == 2018-12-13');

my $a = $g->select_arrays(1544572800, 1544745600, ['test2.met1']);
diag explain $a;
ok(@{$a->{'test2.met1'}} == 2, 'select_arrays() for test2.met1');

done_testing();
