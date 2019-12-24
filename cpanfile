requires 'EV';
requires 'Mojolicious', '8.09';
requires 'DateTime';
requires 'DateTime::Format::MySQL';
requires 'Mojo::mysql', '1.04';
requires 'DBI';
requires 'DBD::ODBC';
requires 'Number::Format';
requires 'AnyEvent';
requires 'AnyEvent::InfluxDB';
requires 'InfluxDB::LineProtocol';
requires 'Regexp::Common';
requires 'Encode';
requires 'MIME::Base64';
requires 'Text::CSV';
requires 'Text::CSV_XS';
requires 'HTTP::BrowserDetect', '3.23';
requires 'ExtUtils::MakeMaker::CPANfile';

on 'configure' => sub {
  requires 'ExtUtils::MakeMaker';
  requires 'ExtUtils::MakeMaker::CPANfile';
};

on 'test' => sub {
  requires 'Test::More';
  requires 'Test::Exception';
};
