#!/usr/bin/perl
use strict;
use warnings;
use YAML;
#use lib qw(/home/toshi/perl/lib);
use Pindata;


my @urls = (
#						'http://pinterest.com/leetmaz/architecture/',
#						'http://pinterest.com/maako/beautiful-women/',
#						'http://pinterest.com/toshi0104/persons/',
						'http://pinterest.com/toshi0104/pins/?filter=likes',
#						'http://pinterest.com/angelacg/photography/',
#						'http://pinterest.com/johnrmath/art-photography-i-like/',
						'http://pinterest.com/vsharmanov/beauty-in-b-w/',
						);


#my @urls = ( $url1, $url2, $url3 );

my @pinlist;
foreach  my $url (@urls){
	print "get $url pinlist\n";
	my $pinlist = Pindata->new();
	$pinlist->url($url);
	my $res = $pinlist->get;
	print "on error : " . $res->{err} ."\n";
	push (@pinlist, @{$res->{permalink}}) if $res->{permalink};
}


print Dump(@pinlist);

foreach my $permalink (@pinlist){
	print "get pindata $permalink\n";
	my $pindata = Pindata->new($permalink);
	my $res = $pindata->get;
	print Dump $res;
}


