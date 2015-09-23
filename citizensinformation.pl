#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use File::Find;
use File::stat;
#use Time::localtime;
use Cwd;

use POSIX qw/strftime/;

sub dofile {
	my $file = $File::Find::name;

	return unless -f $file;
	my $base = $file;
	$base =~ s!/tmp/!http://!;
	$base =~ s!index.html$!!;
	my $outfile = $base;
	$outfile =~ s!http://www.citizensinformation.ie/!!;
	$outfile =~ s!/!_!g;
	return if ($outfile eq '');

	my $stat = stat($file) or die "File $file can't be read: $!";
	my $ftime = stat($file)->mtime;

	my $accessed = strftime "%a, %d %b %Y %H:%M:%S %z", localtime $ftime;

	open(INPUT, "<$file") or die "$!\n";
	open(OUTPUT, ">/tmp/citinf/$outfile") or die "$!\n";

	my $reading = 0;
	my $output = '';
	my $edited = '';

	while (<INPUT>) {
		if (/<!-- start of Document -->/) {
			$reading = 1;
			next;
		}
		if (m!<div id="lastupdated" class="extra"><em><strong>Page edited:</strong>([^<]*)</em></div></div>!) {
			$reading = 0;
			print OUTPUT $output;
		}
		if ($reading == 1) {
			$output .= $_;
		}
		next if ($reading == 0);
		
	}

}

find(\&dofile, cwd);


print "\n\n" . time();
