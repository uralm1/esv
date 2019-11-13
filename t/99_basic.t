use Mojo::Base -strict;

use Test::More skip_all=>'demo test skipped';
use Test::Mojo;

my $t = Test::Mojo->new('Esv');
$t->get_ok('/')->status_is(200); #->content_like(qr/Mojolicious/i);

done_testing();
