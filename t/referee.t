BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }
use Games::Chess::Referee;
$loaded = 1;
print "ok 1\n";

use strict;
use UNIVERSAL 'isa';
$^W = 1;
my $n = 1;
my $success;

exit;

sub do_test (&)
{
	my ($test) = @_;
	$n++;
	$success = 1;
	&$test;
	print 'not ' unless $success;
	print "ok $n\n";
}

sub fail
{
	my ($mesg) = @_;
	print STDERR $mesg, "\n";
	$success = 0;
}

do_test {
	print "1998-12-15 Ondrick vs. Purdy\n";

	new_game();

	move('e2e4',	'e7e5');
	move('d2d3',	'c7c6');

	show_board;

	move('g1h3',	'f8c5');
	move('c1g5',	'd8a5+');
	move('c2c3',	'g8f6');
	move('f1e2',	'd7d6');

	show_board;

	move('e1g1',	'e8g8');
	move('b2b3',	'c5a3');
	move('b3b4',	'a5a6');
	move('g5e3',	'c6c5');
	move('b4c5',	'a3c5');
	move('d3d4!',	'a6c6');

	show_board;

	move('d4c5',	'c6e4');
	move('f2f3?',	'e4e3+');
	move('g1h1',	'e3c5');
	move('d1b3',	'd6d5');
	move('b3a3',	'c5e3');
	move('a3c1?',	'e3e2');

	show_board;

	move('h3g5',	'e5e4');
	move('f3e4',	'd5e4');
	move('b1a3',	'f8d8');
	move('c3c4',	'd8d2');
	move('a3b5??',	'e2g2');

	show_board;

	print "Checkmate.\n";
}


#
# End of file.
#
