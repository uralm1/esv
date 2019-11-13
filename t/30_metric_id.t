use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Esv');

my $id1 = $t->app->metric2id('my.super.metric');
my $id2 = $t->app->metric2id('aAaAzZ.ZzAaAa.1234');
my $id3 = $t->app->metric2id('a');

diag $id1;
diag $id2;
diag $id3;

is ($t->app->id2metric($id1), 'my.super.metric', 'First encode-decode');
is ($t->app->id2metric($id2), 'aAaAzZ.ZzAaAa.1234', 'Second encode-decode');
is ($t->app->id2metric($id3), 'a', 'Third encode-decode');

done_testing();
