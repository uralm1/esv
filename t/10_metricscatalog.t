use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::MetricsCatalog;

dies_ok( sub { Esv::Ural::MetricsCatalog->new() }, 'Empty constructor');

my $cfg = eval path('test.conf')->slurp;

my $mc = Esv::Ural::MetricsCatalog->new($cfg);
isa_ok($mc, 'Esv::Ural::MetricsCatalog');

#diag explain $mc->get_metrics;
#diag explain $mc->get_select_groups;

$mc->_test_assign({metrics=>$cfg->{test_metrics}, select_groups=>$cfg->{test_select_groups}});

is_deeply($mc->get_metrics, $cfg->{test_metrics}, 'Metrics inside');
is_deeply($mc->get_select_groups, $cfg->{test_select_groups}, 'Select groups inside');

is($mc->get_metric(''), undef, 'Empty metric');
is($mc->get_metric('unknown.metric'), undef, 'Unknown metric');
dies_ok( sub { $mc->get_select_group(999) }, 'Unknown group id');

ok(@{$mc->get_metrics_transformed(0)->{test}} == 3, 'Transformed measurement test, group 0');
ok(@{$mc->get_metrics_transformed(1)->{test}} == 5, 'Transformed measurement test, group 1');

#diag explain $mc->get_metrics_transformed(1);

done_testing();
