#! /usr/bin/perl
use strict;
use warnings;
use Mojo::ByteStream 'b';
use feature 'say';

my $url = shift @ARGV or die;

my $jsfile = "scrape.js";
open my $fh, '<', $jsfile or die;
my $script ='';
while (<$fh>) {
	my $line = b($_)->decode;
#	say $_;
	$line =~ s/(var url = ')(.+?)(')/$1$url$3/;
	$script .= $line;
}
close $fh;
open my $outfh, '>', $jsfile or die;
print $outfh b($script)->encode;
close $outfh;
if ($url =~ m|(.+/)(.+?\.html)|){
	$url =~ s|(.+/)(.+?\.html)|$2|;
}else{
	$url = "temp.html";
}
my $newfile = $url;
#open my $newfh, '>', $newfile or die;
#print $newfh $res;

my $res = system("phantomjs $jsfile > $newfile");


