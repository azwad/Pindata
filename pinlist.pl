#!/usr/bin/perl
use strict;
use warnings;
use YAML;
use Pindata;
#use lib qw(/home/toshi/perl/lib);
#use HashDump;

my @urls = (
						'http://pinterest.com/popular/',
						'http://pinterest.com/all/animals/',
						'http://pinterest.com/maako/beautiful-women/',
						'http://pinterest.com/toshi0104/persons/',
						'http://pinterest.com/toshi0104/likes/',
						'http://pinterest.com/angelacg/photography/',
#						'http://pinterest.com/source/liquige.tumblr.com/'
						);


my @pinlist;
foreach  my $url (@urls){
	print "get $url pinlist\n";
	my $pinlist = Pindata->new();
	$pinlist->url($url);
	my $res = $pinlist->get;
	print "on error : " . $res->{err} ."\n" if $res->{err};
	push (@pinlist, @{$res->{permalink}}) if $res->{permalink};
}

#my $pinlist = \@pinlist;

#HashDump->load($pinlist);


foreach my $permalink (@pinlist){
	print "get pindata $permalink\n";
	my $pindata = Pindata->new($permalink);
	my $res = $pindata->get;
	print Dump $res;
}


