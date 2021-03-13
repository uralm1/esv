package Esv::Ural::ReportBase;
use Mojo::Base -base;

use Carp;
use DateTime;

# Esv::Ural::ReportBase->new($controller);
sub new {
  my ($class, $controller) = @_;
  my $self = {
    c => $controller,
    creation_date => DateTime->now(time_zone=>$controller->local_tz)->strftime('%H:%M %d.%m.%Y'),
    creation_user => $controller->stash('remote_user'),
  };

  return bless $self, $class;
}


# internal
# $obj->validate_epoch($e)
sub validate_epoch {
  my ($self, $e) = @_;
  ($e and $e =~ m/^\d{1,10}$/ and $e >= 0);
}


# getters
# '12:30 10.02.2019' = $obj->creation_date;
sub creation_date {
  return shift->{creation_date};
}

# $username = $obj->creation_user;
sub creation_user {
  return shift->{creation_user};
}


1;
