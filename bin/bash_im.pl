#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Term::ReadLine;
use IO::Select;
use Local::Chat::ServerConnection;
use Data::Dumper;
use Term::ReadKey;
use XML::LibXML;
use v5.18;
$|=1;

my @strings_to_show = ();

local $SIG{TERM} = $SIG{INT} = \&stop;

my ( $term_width, $term_height ) = GetTerminalSize();

my $term = Term::ReadLine->new('Simple perl chat');
$term->MinLine();

my $login_prompt = "Enter your nick ";
my $prompt = "Enter your message> ";

local $SIG{WINCH} = sub {
	( $term_width, $term_height ) = GetTerminalSize();
};

sub stop {
    print "\e[".(2 + @strings_to_show).";1H\e[J\n";
    exit;
}

sub init {
    print "\e[1;1H\e[J";
    print $prompt;
}

sub redraw {
	print "\e7";
    print "\e[2;1H\e[J";
	print join "\n", @strings_to_show;
    print "\e8";
}

sub add_message {
	my $string = shift;
	unshift @strings_to_show, split /\n/, $string;
	splice @strings_to_show, ( $term_height - 1 ) if @strings_to_show > $term_height - 1;
	redraw;
}

my $nick = $term->readline($login_prompt);
chomp($nick);
$term->MinLine(1);

init();

my $server = Local::Chat::ServerConnection->new(nick => $nick, host => $ARGV[0] || 'localhost', 
	on_fd => sub {
		my ($srv, $fd) = @_;
		if ($fd == $term->IN) {
			my $msg = $term->readline('');
			print "\e[1;1H\e[2K";
            print $prompt;
                        stop() unless defined $msg;
			chomp($msg);
                        return unless length $msg;
			if ($msg =~ m{^/(\w+)(?:\s+(\S+))*$}) {
				if ($1 eq 'nick') {
					$srv->nick($2);
					return;
				}
				elsif ($1 eq 'names') {
					$srv->names();
				}
				elsif ($1 eq 'kill') {
					$srv->kill($2);
				}
				else {
					add_message( "\e[31mUnknown command '$1'\e[0m\n" );
				}
				return;
			}
			$srv->message({ text => $msg });
		}
	},
	on_idle => sub {
		my ($srv, $message) = @_;
		my $dom = XML::LibXML->new()->parse_file('bash.xml');
		
			my @D = map { $_="$_"; s/\<\!\[CDATA\[(.+)\]\]>/$1/msg; s/<\/?description>//gms; $_ } $dom->getElementsByTagName('description');
		
	  my $n = int rand( scalar @D);
	  	$srv->message({ text => $D[$n] });
		sleep(10);
	
	},

	on_error => sub {
		my ($srv, $message) = @_;
		add_message( "\e[31;1m"."Error"."\e[0m".": $message->{text}\n" );
	}
);

$server->sel->add($term->IN);
my $last_error = time();
while () {
	eval {
		$server->connect;
	};
	if ($@) {
		if (time() - $last_error > 60) {
			add_message("Ожидание сервера");
			$last_error = time();
		}
		sleep(1);
	}
	else {
		$server->poll();
	}

}

stop();
