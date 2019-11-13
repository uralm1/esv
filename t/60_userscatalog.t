use Mojo::Base -strict;

use Test::More;
use Test::Exception;
#use Test::Mojo;
use Mojo::File 'path';

use Esv::Ural::UsersCatalog;

dies_ok( sub { Esv::Ural::UsersCatalog->new() }, 'Empty constructor');

my $dbcfg = eval path('test.conf')->slurp;

my $_users = {
  'login1' => { role=>'superadmin' },
  'login2' => { role=>'dirtcleaner' },
};

my $uc = Esv::Ural::UsersCatalog->new($dbcfg);
isa_ok($uc, 'Esv::Ural::UsersCatalog');

#diag explain $uc->get_users;

$uc->_test_assign($_users);

is_deeply($uc->get_users, $_users, 'Users inside');

is($uc->get_user(''), undef, 'Empty user');
is($uc->get_user('unknown.login'), undef, 'Unknown user');

is($uc->get_user_role('unknown'), undef, 'User role of unknown user');
is($uc->get_user_role('login1'), 'superadmin', 'User role 1');
is($uc->get_user_role('login2'), 'dirtcleaner', 'User role 2');

done_testing();
