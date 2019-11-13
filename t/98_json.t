use Mojo::Base -strict;

use Test::More skip_all=>'demo test skipped';
use Test::Exception;
#use Test::Mojo;

use Mojo::JSON qw(decode_json encode_json);

say encode_json { round => 1 };
say encode_json { dest=>'kp', dest_spec=>'kp_itogo' };

done_testing();
