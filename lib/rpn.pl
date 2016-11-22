=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
require "$FindBin::Bin/../lib/tokenize.pl";
sub isNum {
	my $check = shift;
	if ($check =~/\d+/) {
		return 1;
	} else {
		return 0;
	}	
}
sub rpn {
	my $expr = shift;
	my $arrHref = tokenize($expr);
	my @arr = @$arrHref;
	my %prio = (
  'U+'=>6,
  'U-'=>6,
  '^' => 5,
  '*' => 4,
  '/' => 4,
  '+' => 3,
  '-' => 3,
  '(' => 2,
  ')' => 1
);
my @postfix;
my @stack;
 
for my $x (@arr) {
  if ($x =~ m/\d+/) {
    push @postfix, $x;
  }
  if ($x eq '+' || $x eq '-' || $x eq '*' || $x eq '/' || $x eq '^'|| $x =~ /^U[-+]$/) {
    if ($x eq '^' && @stack && $prio{$stack[-1]} >= $prio{$x}){
        push @stack, $x;
    }elsif($x =~ /^U[-+]$/ && @stack && $prio{$stack[-1]} >= $prio{$x} ){
        push @stack, $x;
    }
    else{
        while (@stack  && $prio{$x} <= $prio{$stack[-1]}) {
            push @postfix, pop @stack;
        }
        push @stack, $x;
    }
  }
  if ($x eq '(') {
    push @stack, $x;
  }
  if ($x eq ')') {
    while ($stack[-1] ne '(' ) {
      push @postfix, pop @stack;
    }
    pop @stack;
  }
}
while (@stack > 0) {
  if ($stack[-1] eq '(') {
    pop @stack;
  }
  else {
    push @postfix, pop @stack;
  }
}
	return \@postfix;
}
1;
