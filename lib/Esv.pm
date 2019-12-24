package Esv;
use Mojo::Base 'Mojolicious';

use DateTime;
use DateTime::TimeZone;
use Esv::Ural::UsersCatalog;
use Esv::Ural::MetricsCatalog;
use Esv::Command::load1;
use Esv::Command::loadsafe1;

our $VERSION = '0.24';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by config file
  my $config = $self->plugin('Config', { default => {
    secrets => ['0ec4740aae29e16f62ba9010ed8c76b932c94812'],
    time_zone => 'local',
  }});
  delete $self->defaults->{config}; # safety - not to pass passwords to stashes

  # Configure the application
  #$self->mode('production');
  #$self->log->level('info');
  $self->secrets($config->{secrets});
  $self->sessions->cookie_name('esv');
  $self->sessions->default_expiration(0);

  $self->plugin('Esv::Plugin::MPagenav');
  $self->plugin('Esv::Plugin::Utils');
  $self->plugin('Esv::Plugin::FormHtml');
  $self->plugin('Esv::Plugin::RenderFile');
  push @{$self->commands->namespaces}, 'Esv::Command';

  $self->defaults(version => $VERSION);
  $self->defaults(local_tz => DateTime::TimeZone->new(name => $self->config('time_zone')));
  $self->defaults(utc_tz => DateTime::TimeZone->new(name => 'UTC'));

  $self->defaults(uc => Esv::Ural::UsersCatalog->new($self->config));
  unless ($self->defaults('uc')) {
    die "Fatal error: Users catalog creation error!";
  }
  $self->log->debug('Users catalog created');

  $self->defaults(mc => Esv::Ural::MetricsCatalog->new($self->config));
  unless ($self->defaults('mc')) {
    die "Fatal error: Metrics catalog creation error!";
  }
  $self->log->debug('Metrics catalog created');

  # Router authentication routine
  $self->hook(before_dispatch => sub {
    my $c = shift;

    my $remote_user;
    my $ah = $c->config('auth_user_header');
    if ($ah) {
      $remote_user = lc($c->req->headers->header($ah));
    } else {
      $remote_user = lc($c->req->env('REMOTE_USER'));
    }
    #FIXME DEBUG FIXME
    #$remote_user = 'cds_tech@uwc.ufanet.ru';
    $remote_user = 'ural';

    unless ($remote_user) {
      $c->render(text => 'Необходима аутентификация', status => 401);
      return undef;
    }
    $c->stash(remote_user => $remote_user);
    $c->stash(remote_user_role => $c->stash('uc')->get_user_role($remote_user));
    unless ($c->stash('remote_user_role')) {
      $c->render(text => 'Неверный пользователь', status => 401);
      return undef;
    }

    return 1;
  });

  # Router
  my $r = $self->routes;

  $r->get('/')->to('index#index');

  $r->get('/disp/plk')->to('disp#plk');
  $r->get('/disp/plk2')->to('disp#plk2');
  $r->get('/disp/plk/oth')->to('disp#plkoth');
  $r->get('/disp/plk/skv')->to('disp#plkskv');
  $r->get('/disp/plk/skv2')->to('disp#plkskv2');
  $r->get('/disp/plk/otkl')->to('disp#plkotkl');
  $r->get('/disp/plk/kt')->to('disp#plkkt');
  $r->get('/disp/plk/kt2')->to('disp#plkkt2');
  
  $r->post('/disp/plk/submit1')->to('disp#plksubmit1');
  $r->post('/disp/plk/submit2')->to('disp#plksubmit2');
  $r->post('/disp/plk/submit3')->to('disp#plksubmit3');

  $r->get('/rep/preview')->to('rep#preview');
  $r->post('/rep/preview')->to('rep#preview');
  $r->get('/rep/tehdir')->to('rep#tehdir');
  $r->get('/rep/gendir')->to('rep#gendir');
  #$r->get('/rep/temp')->to('rep#temp');
  $r->get('/rep/period')->to('rep#period');
  $r->get('/rep/per')->to('rep#per');

  $r->get('/mc')->to('metricscatalog#index');
  $r->get('/settings')->to('settings#index');
  $r->post('/settings')->to('settings#apply');
  $r->get('/asu')->to('index#asu');
  $r->get('/about')->to('index#about');

  # demo request
  # /q?date=2018-12-12
  #$r->get('/q')->to('test#testquery');
}


1;
