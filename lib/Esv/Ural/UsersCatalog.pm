package Esv::Ural::UsersCatalog;
use Mojo::Base -base;

use Carp;
use Data::Dumper;
use Mojo::mysql;


# $db_config = { m_server => '', m_database => '' };
# Esv::Ural::UsersCatalog->new($db_config);
sub new {
  my ($class, $db_config) = @_;
  croak "Configuration required" unless defined $db_config;
  my $self = bless {
    db_config => $db_config,
    #
    users => undef,
    time => time + 86400,
  }, $class;
  return undef unless( $self->_load );
  return $self;
}

# internal
sub _load {
  my $self = shift;
  #say 'RELOAD!';
  my $e = eval {
    my $mdb = Mojo::mysql->new($self->{db_config}{m_server}.'/'.$self->{db_config}{m_database});
    $self->{users} = {};
    my $rec = $mdb->db->query('SELECT login,role FROM users');
    while (my $next = $rec->hash) {
      $self->{users}{$next->{login}} = {
	role => $next->{role},
      };
    }
    $rec->finish;
  };
  unless (defined $e) {
    carp $@;
    return undef;
  }

  return 1;
}

# internal
sub _test_assign {
  my ($self, $users_config) = @_;
  $self->{users} = $users_config;
  return 1;
}

#
# getters
#
sub get_users {
  return shift->{users};
}

# $u_or_undef = $obj->get_user('mylogin')
sub get_user {
  my ($self, $login) = @_;

  # expired?
  if ($self->_expired) { 
    # reload $self->{users}
    return undef unless( $self->_load );
    $self->{time} = time + 86400;
  }

  unless (defined $self->{users}{$login}) {
    carp "Unknown user $login";
    return undef;
  }
  return $self->{users}{$login};
}

# $role_or_undef = $obj->get_user_role('mylogin')
sub get_user_role {
  my ($self, $login) = @_;
  my $u = $self->get_user($login);
  return undef unless defined $u;
  return $u->{role};
}


# internal
# check cache expiration
sub _expired {
  return (time > shift->{time}) ? 1 : undef; 
}


1;
