use strict;
use warnings;

#use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::CPANfile;

my $inst_dir = '/opt/esv';

WriteMakefile(
  NAME => 'Esv',
  AUTHOR => 'Ural Khasanov <uralm@uwc.ufanet.ru>',
  DISTNAME => 'esv',
  VERSION_FROM   => 'lib/Esv.pm',
  #PREREQ_PM => {
  #  'Mojolicious' => '8.09',
  #  'DateTime' => 0,
  #  'DateTime::Format::MySQL' => 0,
  #  'Mojo::mysql' => 0,
  #  'DBI' => 0,
  #  'DBD::ODBC' => 0,
  #  'Number::Format' => 0,
  #  'AnyEvent' => 0,
  #  'AnyEvent::InfluxDB' => 0,
  #  'InfluxDB::LineProtocol' => 0,
  #  'Regexp::Common' => 0,
  #  'Encode' => 0,
  #  'MIME::Base64' => 0,
  #  'Text::CSV' => 0,
  #  'HTTP::BrowserDetect' => '3.23',
  #},
  test => {TESTS => 't/*.t'},
  PREFIX => $inst_dir,
  LIB => "$inst_dir/lib",
  #PMLIBDIRS => ['lib'],
  #PM => {
  #  'lib/Esv.pm' => '$(INST_LIB)/Esv.pm',
  #},
  INSTALLSCRIPT => "$inst_dir/script",
  INSTALLSITESCRIPT => "$inst_dir/script",
  EXE_FILES => ['script/esv', 'script/start_server', 'script/check_db_hosts', 'script/load1', 'script/loadsafe1'],
  MAN1PODS => {},
  MAN3PODS => {},
);

package MY;
sub install {
  my $inherited = shift->SUPER::install(@_);
  return $inherited.<<"MAKE_FRAG";
install::
	\$(NOECHO) \$(ECHO) "** Installing configuration, public and templates files..."
	\$(NOECHO) install -m 0644 esv.conf_empty \$(DESTDIR)$inst_dir/esv.conf
	\$(NOECHO) for d in \$\$(find public -type d); do install -m 0755 -d \$(DESTDIR)$inst_dir/\"\$\$d\"; done
	\$(NOECHO) for f in \$\$(find public -type f); do install -m 0644 -D \"\$\$f\" \$(DESTDIR)$inst_dir/\"\$\$f\"; done
	\$(NOECHO) for d in \$\$(find templates -type d); do install -m 0755 -d \$(DESTDIR)$inst_dir/\"\$\$d\"; done
	\$(NOECHO) for f in \$\$(find templates -type f); do install -m 0644 -D \"\$\$f\" \$(DESTDIR)$inst_dir/\"\$\$f\"; done
	\$(NOECHO) if [ \"\$\$(id -u)\" != \"0\" ]; then install -m 0755 -d \$(DESTDIR)$inst_dir/run; else install -o esv -g esv -m 0755 -d \$(DESTDIR)$inst_dir/run; fi
	\$(NOECHO) if [ \"\$\$(id -u)\" != \"0\" ]; then install -m 0755 -d \$(DESTDIR)$inst_dir/log; else install -o esv -g esv -m 0755 -d \$(DESTDIR)$inst_dir/log; fi

MAKE_FRAG
}

sub postamble {
  return <<'MAKE_FRAG';
all::
	$(NOECHO) $(ECHO) "** Checking..."
	$(NOECHO) if grep -q -e "^\s*\$$remote_user = ['|\"]" lib/Esv.pm ; then echo "WARNING! DEBUG ENTRY AUTHORIZATION CODE in Esv.pm IS NOT DISABLED!!!"; fi

MAKE_FRAG
}

