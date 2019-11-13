use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use InfluxDB::LineProtocol qw(data2line precision=s);
use Esv::Ural::LineWrite;

dies_ok( sub { Esv::Ural::LineWrite->new() }, 'Empty constructor');

my $cfg = eval path('test.conf')->slurp;

my $lw = Esv::Ural::LineWrite->new($cfg);
isa_ok($lw, 'Esv::Ural::LineWrite');

$lw->line('testme1');
$lw->line('testme2');
#diag explain $lw->dump;
is_deeply($lw->dump, ['testme1','testme2'], 'line() twice');
$lw->line_new('testme3');
is_deeply($lw->dump, ['testme3'], 'line_new() after');

my $t = 1544572800; # 2018-12-12
my $l = data2line('test', {met1=>1234.5}, {met2=>'nag'}, $t);
is($l, "test,met2=nag met1=1234.5 $t", 'data2line() test');

$lw->line_new($l);
ok($lw->write, 'write() method returned true');
ok(scalar @{$lw->dump} == 0, 'buffer is empty after successful write');

done_testing();
