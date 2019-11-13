package Esv::Ural::Changelog;
use Mojo::Base -base;

use Carp;
use Mojo::mysql;


# $db_config = { m_server => '', m_database => '' };
# Esv::Ural::Changelog->new($db_config, $APP::VERSION);
# Esv::Ural::Changelog->new($db_config, $APP::VERSION, 10);
sub new {
  my ($class, $db_config, $version, $limit) = @_;
  croak "Configuration required" unless defined $db_config and defined $version;
  my $self = bless {
    db_config => $db_config,
    version => $version,
    #
    changelog => '',
  }, $class;
  return undef unless( $self->_load($limit || 5) );
  return $self;
}

# internal
sub _load {
  my ($self, $limit) = @_;
  if ($self->{version} =~ m/^\D*(\d+)\.(\d+)\D*$/) {
    my ($major, $minor) = ($1, $2);
   
    my $e = eval {
      my $mdb = Mojo::mysql->new($self->{db_config}{m_server}.'/'.$self->{db_config}{m_database});
      my $rec = $mdb->db->query("SELECT CONCAT_WS('.', ver_major, ver_minor) AS ver, \
DATE_FORMAT(date, '%e.%m.%Y') AS date, changelog \
FROM changelog \
WHERE (ver_major = ? AND ver_minor <= ?) OR ver_major < ? \
ORDER BY ver_major DESC, ver_minor DESC LIMIT ?",
        $major, $minor, $major, $limit);
      while (my $next = $rec->hash) {
	my $d = $next->{date} ? ", $next->{date}" : '';
        $self->{changelog} .= "<p><b>Версия $next->{ver}$d</b></p><p>$next->{changelog}</p>";
      }
      $rec->finish;
    };
    unless (defined $e) {
      carp $@;
      return undef;
    }
    return 1;
  } else {
    carp "Invalid program version";
    return undef;
  }
}

#
# getters
#
sub get_changelog_html {
  return shift->{changelog};
}

sub get_version {
  return shift->{version};
}


1;
