package Esv::Controller::Settings;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;
  return undef unless $self->authorize($self->allow_all_roles);

  my %role_redir = (
    asu => 'settings/index_asu',
    cds => 'settings/index_cds',
  );
  my $redir = $role_redir{$self->stash('remote_user_role') || ''};
  $redir = 'settings/index' unless $redir;

  $self->app->log->info('Redirected settings for role: '.$self->stash('remote_user_role').', user: '.$self->stash('remote_user').' => '.$redir);
  $self->render(template => $redir);
}


sub apply {
  my $self = shift;
  return undef unless $self->authorize($self->allow_all_roles);

  #FIXME multiple roles support
  #say "POST SETTINGS";

  my $v = $self->validation;
  #say "has_data: ".(($v->has_data)?'true':'false');
  return $self->redirect_to('settings') unless ($v->has_data);

  $v->optional('reset-features');

  if ($v->param('reset-features')) {
    #say "resetting features ads";
    $self->cookie("feature$_" => 0, {expires=>1}) for (1..10);
  }

  #say "has_error: ".(($v->has_error)?'true':'false');
  if ($v->has_error) {
    $self->flash(oper => 'Неверные данные');
  } else {
    $self->flash(oper => 'Сохранено');
  }
  $self->redirect_to('settings');
}


1;
