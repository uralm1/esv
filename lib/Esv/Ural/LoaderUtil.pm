package Esv::Ural::LoaderUtil;
use Mojo::Base -base;

use Mojo::mysql;
#use Data::Dumper;

# $mysql_time = Esv::Ural::LoaderUtil::get_current_timestamp($db_config, 'loader_name');
sub get_current_timestamp {
  my ($db_cfg, $loader_name) = @_;

  my $current_ts;
  my $sdb = _getdb($db_cfg)->db;
  my $rs = $sdb->query('SELECT timestamp FROM loaders_timestamp WHERE loader = ?', $loader_name);
  if (my $rsh = $rs->hash) {
    $current_ts = $rsh->{timestamp} || '1900-01-01 00:00:00';
  } else {
    $current_ts = '1900-01-01 00:00:00';
    $sdb->query('INSERT INTO loaders_timestamp (loader, timestamp) VALUES (?, \'1900-01-01 00:00:00\')', $loader_name);
  }
  $rs->finish;
  return $current_ts;
}


# Esv::Ural::LoaderUtil::set_current_timestamp($db_config, 'loader_name', $mysql_datetime);
sub set_current_timestamp {
  my ($db_cfg, $loader_name, $ts) = @_;

  my $sdb = _getdb($db_cfg)->db;
  $sdb->query('UPDATE loaders_timestamp SET timestamp = ? WHERE loader = ?',
    $ts, $loader_name);
}


# internal
sub _getdb {
  my $db_cfg = shift;
  state $sdb = Mojo::mysql->new($db_cfg->{m_server}.'/'.$db_cfg->{m_database});
}


1;
