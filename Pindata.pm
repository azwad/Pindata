use strict;
use warnings;

{ package Pindata;
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
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/\w+\/pins\/\?filter=\w+/){
			$self->get_pinlist;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/all\/\?category=\w+/){
			$self->get_pinlist;
			return $self->{res};
		}elsif ( $url =~ /^http:\/\/pinterest\.com\/\w+\/.+?\//){
			$self->get_pinlist;
			return $self->{res};
		}else{
			print $url."\n";
			die "no mutch";
		}
	}

	sub get_pinlist {
		my $self = shift;
		my $url = $self->{url};
		use URI;
		my $uri = URI->new($url);
		use WWW::Mechanize;
		my $mech = WWW::Mechanize->new();
		$mech->agent_alias( 'Windows Mozilla' );
		eval {$mech->get($uri)};
		if(@_){
			$self->{res}->{err} = @_;
			return $self->{res};
		}
		use Web::Scraper;
		my $scraper = scraper {
			process '//title', 'id' => "TEXT";
			process '//div[@class="pin"]/div[1]/a', 'permalink[]' => '@href';
		};
		my $res = $scraper->scrape($mech->content,$mech->uri);
		$res->{listurl} = $url;
		$self->{res} = $res;
		return $self->{res};
	}
	sub get_pindata {
		my $self = shift;
		my $url = $self->{url};
		use URI;
		my $uri = URI->new($url);
		use WWW::Mechanize;
		my $mech = WWW::Mechanize->new();
		$mech->agent_alias( 'Windows Mozilla' );
		eval { $mech->get($uri)};
		if (@_){
			$self->{res}->{err} = @_;
			return $self->{res};
		}
		use Web::Scraper;
		my $scraper = scraper {
			process 'id("PinnerStats")', 'date' => sub {
				my $i;
				my $m;
				my $t = $_->as_text;
				if ($t =~ /(Pinn|Repinn|Upload)ed\s+(\d+)\s+(\w+)/){
					$i = $2;
					$m = $3;
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
						die 'no mutch';
				}
				use DateTime;
				my $dt_now = DateTime->now( time_zone => 'local' );
				my $pinned_time = $dt_now->subtract( minutes => $post_ago);
				return $pinned_time->strftime('%Y/%m/%d %H:%M');
			};
			process '//div[@class="WhiteContainer clearfix"]',  'paragraph' => scraper {
				process 'id("PinCaption")/text()', 'caption' => 'TEXT';
				process 'id("PinImageHolder")/a/img',   'imgsource' => '@src';
				process 'id("PinImageHolder")/a', 'orgsource' => '@href';
				process '//div[1]/p[1]/a[1]', 'pinner' => 'TEXT';
			};
		};
		my $res = $scraper->scrape($mech->content,$mech->uri);
		$res->{link} = $url;
		$self->{res} = $res;
		return $self->{res};
	}
}
1;

