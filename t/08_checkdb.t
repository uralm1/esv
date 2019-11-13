use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::CheckDB;

dies_ok( sub { Esv::Ural::CheckDB::ping() }, 'Empty ping');

my $cfg = eval path('test.conf')->slurp;

ok(defined Esv::Ural::CheckDB::ping($cfg), 'ping test');

done_testing();
