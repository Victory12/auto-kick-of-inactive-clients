=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use Data::Dumper;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

use FindBin;
require "$FindBin::Bin/../lib/rpn.pl";

sub evaluate {
	my $rpn_ = shift;
	my @rpn = @{$rpn_};
	my @stack = ();
	for my $i (@rpn) {
		if ($i !~/^\d+/) {
			if ($i ne 'U+' && $i ne 'U-') {
				my $prev1 = pop(@stack);
				my $prev2 = pop(@stack);
				if ($i eq '-') {
					push(@stack, $prev2 - $prev1);
				} elsif ($i eq '+') {
					push(@stack, $prev2 + $prev1);
				} elsif ($i eq '*') {
					push(@stack, $prev2 * $prev1);
				} elsif ($i eq '/') {
					push(@stack, $prev2 / $prev1);
				} else {
					push(@stack, $prev2 ** $prev1);
				}
			} else {
				if ($i eq 'U+') {
					push(@stack, 1 * pop(@stack));
				} else {
					push(@stack, -1 * pop(@stack));
				}
			}
		} else {
			push(@stack, $i);
		}
	}
	
	return pop(@stack);
}
1;;
