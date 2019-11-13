#!/usr/bin/perl

use strict;
use warnings;
use v5.12;
use utf8;
use Text::CSV;
use Encode;
#use IO::File;


#my $fh = IO::File->new("> testfile");
#print $fh "bar";
#$fh->close;

my $csv = Text::CSV->new({binary=>1, sep_char=>';', eol=>"\r\n"});

# in-memory files
my $csvstr;
my $fh;
open($fh, '>', \$csvstr) or die "open error $!\n";
my $data = [
  ["aaa", encode('windows-1251', "Второй"), "ccc", "Проверка"],
  [11, 12, 13, 14],
  [21, 22.22, "23,23", "24;24"],
  [31, 32, 33, 34],
];
$csv->say($fh, $_) for (@$data);
close $fh;

say "-------------------------------";
say $csvstr;
say "-------------------------------";
