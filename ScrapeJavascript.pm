package ScrapeJavascript;
use strict;
use warnings;
use Mojo::ByteStream 'b';
use feature 'say';
sub scrape_javascript {
	my $url = shift;
	my $script_dir = "/home/toshi/perl/lib";
	my $jsfile = "$script_dir/scrape.js";
	open my $fh, '<', $jsfile or die;
	my $script ='';
	while (<$fh>) {
		my $line = b($_)->decode;
		$line =~ s/(var url = ')(.+?)(')/$1$url$3/;
		$script .= $line;
	}
	close $fh;
	open my $outfh, '>', $jsfile or die;
	print $outfh b($script)->encode;
	close $outfh;
	my $newfile = $url;
	if ($newfile =~ m|(.+/)(.+?\.html)|){
		$newfile =~ s|(.+/)(.+?\.html)|$2|;
	}else{
		$newfile = "temp.html";
	}
	$newfile = "$script_dir/$newfile";
	system("phantomjs $jsfile > $newfile");
	open my $resfh, '<', $newfile or die;
	my $content = '';
	while (<$resfh>){
		my $line = b($_)->decode;
		$content .= $line;
	}
	close $resfh;
	unlink $newfile;
	return $content;
} 

1;
