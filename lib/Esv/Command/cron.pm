package Esv::Command::cron;
use Mojo::Base 'Mojolicious::Command';

use Carp;
use Mojo::IOLoop;
use Mojo::Log;
use Algorithm::Cron;

has description => '* Run builtin internal scheduler';
has usage => "Usage: APPLICATION cron\n";

sub run {
  my $self = shift;
  my $app = $self->app;
  my $log = $app->log;

  binmode(STDOUT, ':utf8');
  #binmode(STDERR, ':utf8');

  my $sh = $app->config('load_schedules');
  if (!$sh || ref($sh) ne 'ARRAY' || !@$sh) {
    $log->info('Config parameter load_schedules is undefined or empty. Scheduler process will exit.');
    return 0;
  }

  $log->info('Internal scheduler process started.');

  # use new special IOLoop
  my $loop = Mojo::IOLoop->new;
  local $SIG{INT} = local $SIG{TERM} = sub { $loop->stop };

  $loop->next_tick(sub { 
    $self->_cron($loop, $sh, $_) for (0 .. $#$sh);
  });

  $loop->start;
  $log->info('Internal scheduler finished.');
}

sub _cron() {
  my ($self, $loop, $sh, $idx) = @_;
  my $log = $self->app->log;
  my $crontab = $sh->[$idx];
  carp 'Bad crontab' unless $crontab;

  my $cron = Algorithm::Cron->new(
    base => 'local',
    crontab => $crontab,
  );
  $log->info("Schedule ($idx: \"$crontab\") active.");

  my $time = time;
  # $cron, $time goes to closure
  my $task;
  $task = sub {
    $time = $cron->next_time($time);
    while ($time - time <= 0) {
      #say "Time diff negative!";
      $time = $cron->next_time($time);
    }
    $loop->timer(($time - time) => sub { 
      $log->info("EVENT from schedule ($idx) started.");
      my $e = eval { $self->app->commands->run('loadsafe1') };
      my $es = (defined $e) ? "code: $e":"with error: $@";
      $log->info("EVENT from schedule ($idx) finished $es.");
      $task->();
    });
  };
  $task->();
}

#-------------------------------------------------

1;
