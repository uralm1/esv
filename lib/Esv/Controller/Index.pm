package Esv::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::mysql;
use AnyEvent;
use AnyEvent::InfluxDB;
use Esv::Ural::Changelog;
use Esv::Ural::CheckDB;

# Just main redirector
sub index {
  my $self = shift;
  return undef unless $self->authorize($self->allow_all_roles);

  my %role_redir = (
    cds => 'dispplk2',
    #tehdir => '',
    #gendir => '',
    asu => 'asu',
  );
  my $redir = $role_redir{$self->stash('remote_user_role') || ''};
  return $self->render(text => 'Данная роль не поддерживается', status => 401) unless $redir;

  $self->app->log->info('Redirected role: '.$self->stash('remote_user_role').', user: '.$self->stash('remote_user').' => '.$redir);
  $self->redirect_to($redir);
}


sub asu {
  my $self = shift;
  return undef unless $self->authorize({asu=>1});

  $self->render;
}


sub about {
  my $self = shift;
  return undef unless $self->authorize($self->allow_all_roles);

  my $msg_online = '<span style="color:#4caf50;font-weight:bold">РАБОТАЕТ</span>';
  my $msg_offline = '<span style="color:#ff0000;font-weight:bold">НЕДОСТУПНО</span>';
  # 1.influx database
  my $i1;
  $i1 = $self->config('hf_database');
  my $u1 = Mojo::URL->new($self->config('hf_server'));
  $i1 .= ' на '.$u1->host;
  my $ping_res = ' (InfluxDB) - '.$msg_offline;
  if (my $r = Esv::Ural::CheckDB::ping($self->config)) { $ping_res = " (InfluxDB $r) - ".$msg_online};
  $i1 .= $ping_res;

  # 2.mysql database
  my $i2;
  $i2 = $self->config('m_database');
  my $u2 = Mojo::URL->new($self->config('m_server'));
  $i2 .= ' на '.$u2->host;
  $i2 .= ' ('.$u2->scheme.')';
  $ping_res = $msg_offline;
  my $e = eval {
    my $mdb = Mojo::mysql->new($self->config('m_server').'/'.$self->config('m_database'));
    $ping_res = $msg_online if $mdb->db->ping;
  };
  $i2 .= ' - '.$ping_res;

  my $hist;
  if (my $changelog = Esv::Ural::Changelog->new($self->app->config, $self->stash('version'), 50)) {
    $hist = $changelog->get_changelog_html;
  } else {
    $hist = 'Информация отсутствует.';
  }
  $self->render(
    influx_info => $i1,
    mysql_info => $i2,
    hist => $hist,
  );
}

1;
