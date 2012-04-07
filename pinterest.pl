#!/usr/bin/perl
use strict;
use warnings;
use YAML;
#use lib qw(/home/toshi/perl/lib);
use Pindata;


my $url1 = 'http://pinterest.com/leetmaz/architecture/';
my $url2 = 'http://pinterest.com/maako/beautiful-women/';
my $url3 = 'http://pinterest.com/toshi0104/persons/';

my @urls = ( $url1, $url2, $url3 );

my @pinlist;
foreach  my $url (@urls){
	print "get $url pinlist\n";
	my $pinlist = Pindata->new();
	$pinlist->url($url);
	my $res = $pinlist->get;
	push (@pinlist, @{$res->{permalink}});
}

print Dump(@pinlist);

foreach my $permalink (@pinlist){
	print "get pindata $permalink\n";
	my $pindata = Pindata->new($permalink);
	my $res = $pindata->get;
	print Dump $res;
}


