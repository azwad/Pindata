package Pindata;
use strict;
use warnings;

	sub new {
		my $proto = shift;
		my $class = ref $proto || $proto;
		my $self = {};
		bless $self, $class;
		$self->{url} = shift;
		return $self;
	}

	sub url {
		my $self = shift;
		if ( @_ ){
			$self->{url} = shift;
		}
		return $self->{url};
	}

	sub get {
		my $self = shift;
		my $url;
		if ( $self->{url} ){
			$url = $self->{url};
		}else{
			$url = $self->url(shift);
		}
		if( $url =~ /^http:\/\/pinterest\.com\/pin\/\d+/){
			$self->get_pindata;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/\w+\/(pins|likes)\//){
			$self->get_pinlist;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/(popular|all|gifts|videos)\//){
			$self->get_pinlist;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/all\/\w+\//){
			$self->get_pinlist;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/source\/.+?\//){
			$self->{res}->{err} = "need login";
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/\w+\/.+?\//){
			$self->get_pinlist;
			return $self->{res};
		}else{
			print $url."\n";
			$self->{res}->{err} = "no mutch";
			return $self->{res};
		}
	}

	sub get_pinlist {
		my $self = shift;
		my $url = $self->{url};
		use ScrapeJavascript;
		my $content = ScrapeJavascript::scrape_javascript($url);		
		if ($content eq ''){
			$self->{res}->{err} = "no content";
			return $self->{res};
		}
		use Web::Scraper;
				my $scraper = scraper {
			process '//title', 'id' => "TEXT";
			process '//div[@class="pinHolder"]/a', 'permalink[]' => '@href';
		};
		my $res = $scraper->scrape($content,$url);
		$res->{listurl} = $url;
		$self->{res} = $res;
		return $self->{res};
	}

	sub get_pindata {
		my $self = shift;
		my $url = $self->{url};
		use ScrapeJavascript;
		my $content = ScrapeJavascript::scrape_javascript($url);
		if ($content eq "") {
			$self->{res}->{err} = "no data";
			return $self->{res};
		}		
		use Web::Scraper;
		my $scraper = scraper {
			process '//span[@class="commentDescriptionTimeAgo"]', 'date' => sub {
				my $i;
				my $m;
				my $t = $_->as_text;
				if ($t =~ /.+?(\d+)\s+(\w+)/){
					$i = $1;
					$m = $2;
				}
				my $post_ago;
				if ($m =~ /minute/) {
					$post_ago = $i;
				}elsif ($m =~ /hour/) {
					$post_ago = $i*60;
				}elsif ($m =~ /day/) {
					$post_ago = $i*1440;
				}elsif ($m =~ /week/) {
					$post_ago = $i*10080;
				}elsif ($m =~ /month/) {
					$post_ago = $i*43200;
				}elsif ($m =~ /year/) {
					$post_ago = $i*525600;
				}else{
					$post_ago =	undef;
				}
				use DateTime;
				my $dt_now = DateTime->now( time_zone => 'local' );
				my $pinned_time;
				if (defined $post_ago){
					$pinned_time = $dt_now->subtract( minutes => $post_ago);
				}else{
					$pinned_time = $dt_now;
				}
				return $pinned_time->strftime('%Y/%m/%d %H:%M');
			};
			process '//head', 'paragraph' => scraper {
				process '//meta[@property="og:description"]', 'caption' => '@content';
				process '//meta[@property="og:image"]',  'imgsource' => '@content';
				process '//meta[@property="og:see_also"]', 'orgsource' => '@content';
				process '//meta[@property="twitter:creator"]', 'pinner' => '@content';
			};
		};
		my $res = $scraper->scrape($content,$url);
		$res->{link} = $url;
		$self->{res} = $res;
		return $self->{res};
	}

1;

