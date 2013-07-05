package Plagger::Plugin::CustomFeed::Pinterest;
use strict;
use warnings;
use base qw( Plagger::Plugin );
use lib qw(/home/toshi/perl/lib);
use Pindata;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'subscription.load' => \&load,
    );
}

sub load {
    my($self, $context) = @_;
		my $feed = Plagger::Feed->new;
		$feed->title("Pinterest");
		$feed->aggregator(sub { $self->aggregate($context) });
		$context->subscription->add($feed);
}

sub aggregate {
		my ($self, $context) = @_;
		my $urls = $self->conf->{urls};
		my @pinlist;
		foreach my $url (@$urls) {
			my $pinlist = Pindata->new();
			$context->log(info => "get pinlist $url");
			my $result = $pinlist->get($url);
			$context->log(info => $result->{err}) if $result->{err};
			push (@pinlist, @{$result->{permalink}}) if $result->{permalink};
		};

		my $feed  = Plagger::Feed->new;
		$feed->link('http://pinterest.com');
		$feed->type('Pinterest');
  	$feed->id('Pinterest');
		
		foreach my $pinurl (@pinlist){
			$context->log(info => "get pindata to feed: $pinurl");
			my $entry = $self->create_entry($context, $pinurl);
			$feed->add_entry($entry);
		}
		$context->update->add($feed);
}

sub create_entry {
			my ($self, $context, $pinurl) = @_;
			my $pindata = Pindata->new();
			my $res = $pindata->get($pinurl);

			my $link = $res->{link};
			my $title = $res->{paragraph}->{caption};
			my $pinner = $res->{paragraph}->{pinner};
			my $orgsource = $res->{paragraph}->{orgsource};
			my $imgsource = $res->{paragraph}->{imgsource};
			my $date = $res->{date};
			my $body;

			my $entry = Plagger::Entry->new;

			$entry->title($title);
			$entry->link($link);
			$entry->date($date);

			if ($self->conf->{enclosure}) {
				my $enclosure = Plagger::Enclosure->new;
				$enclosure->url($imgsource);
				$enclosure->auto_set_type;
				$entry->add_enclosure($enclosure);
				$body = "<a href=\"$link\">$title</a>";
			}else{
				$body = "<a href=\"$link\"><img src=\"$imgsource\"/></a><br/><a href =\"$orgsource\">$title</a>"
			}
			$entry->body($body);
      return $entry;
}
1;

__END__

=head1 NAME

Plagger::Plugin::CustomFeed::Pinterest

=head1 SYNOPSIS

  - module: CustomFeed::Pintrest
    config:
     urls: 
       - 'http://pinterest.com/leetmaz/architecture/'
       - 'http://pinterest.com/maako/beautiful-women/'
       - 'http://pinterest.com/toshi0104/persons/'




=head1 AUTHOR

Toshi Azwad

=cut
