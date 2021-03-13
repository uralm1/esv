package Esv::Plugin::Utils;
use Mojo::Base 'Mojolicious::Plugin';

use DateTime;
use DateTime::TimeZone;
use Number::Format;
use Esv::Ural::UsersCatalog;
use Esv::Ural::MetricsCatalog;

sub register {
  my ( $self, $app, $args ) = @_;
  $args ||= {};

  # users catalog singleton object
  $app->helper(users_catalog => sub {
    state $uc = Esv::Ural::UsersCatalog->new(shift->config) or
      die "Fatal error: Users catalog creation error!";
  });

  # local timezone singleton object
  $app->helper(local_tz => sub {
    state $local_tz = DateTime::TimeZone->new(name => shift->config('time_zone'));
  });

  # utc timezone singleton object
  $app->helper(utc_tz => sub {
    state $utc_tz = DateTime::TimeZone->new(name => 'UTC');
  });

  # return undef unless $self->authorize({ asu=>1, cds=>1 });
  $app->helper(authorize => sub {
    my ($c, $roles_href) = @_;

    my $role = $c->stash('remote_user_role');
    return 1 if ($role && $roles_href->{$role});
    $c->app->log->warn("Access is forbidden for role: $role, user: ".$c->stash('remote_user'));
    $c->render(text => 'Доступ запрещен', status => 401);
    return undef;
  });

  # $self->authorize($self->allow_all_roles);
  $app->helper(allow_all_roles => sub {
    { asu=>1, cds=>1, gendir=>0, tehdir=>0 };
  });

  $app->helper(current_date_frm => sub {
    my $c = shift;
    return DateTime->now(locale=>'ru', time_zone=>$c->local_tz)->strftime('%A %d.%m.%Y');
  });

  # $dmy = get_oper_date(1) => '12.11.2018'
  # $epoch = get_oper_date
  $app->helper(get_oper_date => sub {
    my ($c, $code) = @_;
    my $oper_epoch = $c->session('dot0');
    unless ($oper_epoch) {
      # set yesterday date as operation date
      $oper_epoch = DateTime->today(time_zone=>$c->utc_tz)->subtract(days=>1)->epoch;
      $c->session(dot0 => $oper_epoch);
    }
    return ($code) ? DateTime->from_epoch(epoch=>$oper_epoch, time_zone=>$c->utc_tz)->dmy('.') : $oper_epoch;
  });

  # get and store operation date from parameter 'date', DD.MM.YYYY format
  # store_date_param()
  $app->helper(store_date_param => sub {
    my $c = shift;
    my $e = $c->validate_date($c->param('date'));
    if (defined $e) {
      #$c->app->log->debug("Date is ok: $d $e");
      $c->session(dot0 => $e);
    }
  });

  # $epoch or undef = validate_date('DD.MM.YYYY')
  $app->helper(validate_date => sub {
    my ($c, $d) = @_;
    if ($d && $d =~ m/^(\d{2})\.(\d{2})\.(\d{4})$/) {
      if ($1>=1 && $1<=31 && $2>=1 && $2<=12 && $3>=1970 && $3<=2025) {
	return eval { DateTime->new(year=>$3, month=>$2, day=>$1, time_zone=>$c->utc_tz)->epoch; };
      }
    }
    return undef;
  });

  # metric catalog singleton object
  # $mc = metric_catalog()
  $app->helper(metric_catalog => sub {
    state $mc = Esv::Ural::MetricsCatalog->new(shift->config) or
      die "Fatal error: Metrics catalog creation error!";
  });

  # $mc = metric_backend
  $app->helper(metric_backend => sub {
    return shift->stash('mb');
  });

  # $formatted_val = get('my.metric')
  $app->helper(get => sub {
    my ($c, $metric, $metric2_min) = @_;
    return $c->stash('mb')->get($metric, $metric2_min);
  });

  # $formatted_val = get_nond('my.metric')
  $app->helper(get_nond => sub {
    my ($c, $metric) = @_;
    return $c->stash('mb')->get_nond($metric);
  });

  # $value_for_calculations = get_formula('my.metric')
  $app->helper(get_formula => sub {
    my ($c, $metric) = @_;
    return $c->stash('mb')->get_formula($metric);
  });

  # $text_formatted = float_text($value)
  $app->helper(float_text => sub {
    my ($c, $v) = @_;
    # $c supposed to be a report controller
    return $c->stash('mb')->{formatter}->format_number($v, 0, 1);
  });
}

1;
__END__
