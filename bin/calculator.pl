#!/usr/bin/env perl

use 5.010;  # for say, given/when
use strict;
use warnings;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
our $VERSION = 1.0;

BEGIN{
	$|++;     # Enable autoflush on STDOUT
	$, = " "; # Separator for print x,y,z
	$" = " "; # Separator for print "@array";
}

use FindBin;
require "$FindBin::Bin/../lib/evaluate.pl";
require "$FindBin::Bin/../lib/rpn.pl";
sub calculator{
        my $expression = shift; 
	next if $expression =~ /^\s*$/;

	return eval {
		my $rpn = rpn($expression);
		my $value = evaluate($rpn);
		##print join(" ",@$rpn)."\n";
		chomp $expression;
                my $ans =  $value;
warn $ans;
                return $ans;
	1} or return do {
		warn "Error: $@";
		return "NaN";
	};

	### Check using perl
	if (0) {
		chomp $expression;
		my $x = $expression =~ s{\^}{**}r; # replace "^" with "**"
		if( my $v = eval( $x ) or not $@ ) {
			print STDERR "Perl: $v\n";
		} else {
			warn $@;
		}
	};
};
1;
