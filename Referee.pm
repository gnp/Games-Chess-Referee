#
# Copyright (C) 1999 Gregor N. Purdy
# All rights reserved.
#

package Games::Chess::Referee;
use base 'Exporter';
use strict;
use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.001';
@EXPORT = qw(&ply &move &new_game &show_board);
@EXPORT_OK = @EXPORT;

my $board;
my $move;
my $to_move;

my $white = 0;
my $black = 1;

my $white_may_castle_short;
my $white_may_castle_long;
my $black_may_castle_short;
my $black_may_castle_long;

sub upper { my ($s) = @_; $s =~ tr/a-z/A-Z/; return $s; };
sub lower { my ($s) = @_; $s =~ tr/A-Z/a-z/; return $s; };

sub white { my ($s) = @_; $s =~ tr/a-z/A-Z/; return $s; };
sub black { my ($s) = @_; $s =~ tr/A-Z/a-z/; return $s; };

my $occupy  = '-';
my $capture = 'x';

my $empty   = ' ';
my $pawn    = 'P';
my $rook    = 'R';
my $knight  = 'N';
my $bishop  = 'B';
my $queen   = 'Q';
my $king    = 'K';


#
# is_empty()
#

sub is_empty
{
	my ($s) = @_;
	return $s eq $empty;
}


#
# is_white()
#

sub is_white
{
	my ($s) = @_;
	return $s =~ m/[PRNBQK]/;
}


#
# is_black()
#

sub is_black
{
	my ($s) = @_;
	return $s =~ m/[prnbqk]/;
}


#
# is_pawn()
#

sub is_pawn
{
	my ($s) = @_;
	return $s =~ m/[pP]/;
}


#
# new_game()
#

sub new_game
{
	my ($file, $rank);

	undef $board;

	foreach $file ('a' ... 'h') {
		$board->{$file}{2} = white($pawn);
		$board->{$file}{7} = black($pawn);
		foreach $rank (3 ... 6) { $board->{$file}{$rank} = $empty; }
	}

	$board->{'a'}{1} = white($rook);
	$board->{'h'}{1} = white($rook);
	$board->{'a'}{8} = black($rook);
	$board->{'h'}{8} = black($rook);

	$board->{'b'}{1} = white($knight);
	$board->{'g'}{1} = white($knight);
	$board->{'b'}{8} = black($knight);
	$board->{'g'}{8} = black($knight);

	$board->{'c'}{1} = white($bishop);
	$board->{'f'}{1} = white($bishop);
	$board->{'c'}{8} = black($bishop);
	$board->{'f'}{8} = black($bishop);

	$board->{'d'}{1} = white($queen);
	$board->{'e'}{1} = white($king);
	$board->{'d'}{8} = white($queen);
	$board->{'e'}{8} = white($king);

	$to_move = $white;

	$white_may_castle_short = 1;
	$white_may_castle_long  = 1;
	$black_may_castle_short = 1;
	$black_may_castle_long  = 1;

	$move = 1;
}


#
# show_board()
#

sub show_board
{
	my ($rank, $file, $square);

	print "\n";

	my @ranks = (8, 7, 6, 5, 4, 3, 2, 1);
	my @files = qw(a b c d e f g h);

	print "\n";

	foreach $rank (@ranks) {
		foreach $file (@files) {
			$square = $board->{$file}{$rank};
			$square = ' ' unless defined($square);

			print $square;
		}
		print "\n";
	}

	return;
}


#
# occupy()
#

sub occupy
{
	my ($file, $rank, $piece, $color) = @_;

	
}


#
# ply()
#

sub ply
{
	my ($ply) = @_;
	my ($piece, $ff, $fr, $act, $tf, $tr, $note);
	my $notation = undef;
	
	#
	# Translate castling notations:
	#

	if ($ply eq '0-0') {
		if ($to_move == $white) { $ply = 'e1g1'; }
		else                    { $ply = 'e8g8'; }
	}
	elsif ($ply eq '0-0-0') {
		if ($to_move == $white) { $ply = 'e1c1'; }
		else                    { $ply = 'e8c8'; }
	}

	#
	# Parse the ply notation:
	#

	if ($ply =~ m/^([PRNBQK]|)([a-h])([1-8])(x|-|)([a-h])([1-8])(.*)$/) {
		($piece, $ff, $fr, $act, $tf, $tr, $note) = ($ply =~ m/^([PRNBQK]|)([a-h])([1-8])(x|-|)([a-h])([1-8])(.*)$/);
		$piece = upper($piece);
	}
	else {
		die "Unsupported notation: '$ply'!\n";
	}


	#
	# Check for attempts to castle:
	#
	# 1. Ensure castling is permitted (neither King nor Rook has moved prior).
	# 2. Ensure the way is clear between the King and Rook.
	# 3. Move the Rook to its final location (the King's move will be
	#    effected by the later code.
	#
	# TODO: Ensure that the King is not in check, and that none of the
	# relevant squares are under attack.
	#

	if	($ff eq 'e' and $fr == 1 and $tf eq 'g' and $tr == 1) {
		die "Castling short not permitted!\n" unless $white_may_castle_short;
		die "Way not clear for castling short!\n" unless is_space($board->{'f'}{1});
		die "Way not clear for castling short!\n" unless is_space($board->{'g'}{1});
		$board->{'f'}{1} = $board->{'g'}{1};
		$board->{'g'}{1} = $empty;
		$notation = '0-0';
	}
	elsif	($ff eq 'e' and $fr == 8 and $tf eq 'g' and $tr == 8) {
		die "Castling short not permitted!\n" unless $black_may_castle_short;
		die "Way not clear for castling short!\n" unless is_space($board->{'f'}{8});
		die "Way not clear for castling short!\n" unless is_space($board->{'g'}{8});
		$board->{'f'}{8} = $board->{'g'}{8};
		$board->{'g'}{8} = $empty;
		$notation = '0-0';
	}
	elsif	($ff eq 'e' and $fr == 1 and $tf eq 'c' and $tr == 1) {
		die "Castling long not permitted!\n" unless $white_may_castle_long;
		die "Way not clear for castling long!\n" unless is_space($board->{'b'}{1});
		die "Way not clear for castling long!\n" unless is_space($board->{'c'}{1});
		die "Way not clear for castling long!\n" unless is_space($board->{'d'}{1});
		$board->{'d'}{1} = $board->{'a'}{1};
		$board->{'a'}{1} = $empty;
		$notation = '0-0-0';
	}
	elsif	($ff eq 'e' and $fr == 8 and $tf eq 'c' and $tr == 8) {
		die "Castling long not permitted!\n" unless $black_may_castle_long;
		die "Way not clear for castling long!\n" unless is_space($board->{'b'}{8});
		die "Way not clear for castling long!\n" unless is_space($board->{'c'}{8});
		die "Way not clear for castling long!\n" unless is_space($board->{'d'}{8});
		$board->{'d'}{8} = $board->{'a'}{8};
		$board->{'a'}{8} = $empty;
		$notation = '0-0-0';
	}
	
	#
	# Record new castling permissions:
	#

	if    ($ff eq 'a' and $fr == 1) { $white_may_castle_long  = 0; } # Queen's Rook
	elsif ($ff eq 'a' and $fr == 8) { $black_may_castle_long  = 0; }
	elsif ($ff eq 'h' and $fr == 1) { $white_may_castle_short = 0; } # King's Rook
	elsif ($ff eq 'h' and $fr == 8) { $black_may_castle_long  = 0; }
	elsif ($ff eq 'e' and $fr == 1) {
		$white_may_castle_short = 0;
		$white_may_castle_long  = 0;
	}
	elsif ($ff eq 'e' and $fr == 8) {
		$black_may_castle_short = 0;
		$black_may_castle_long  = 0;
	}

	#
	# Detect the piece: 
	#

	if ($piece and (upper($piece) ne upper($board->{$ff}{$fr}))) {
		die "Ply piece '$piece' does not match board piece (",
			upper($board->{$ff}{$fr}), ") at $ff$fr!\n";
	}

	$piece = $board->{$ff}{$fr};

	#
	# Detect the action:
	#

	if (is_empty($board->{$tf}{$tr})) {
		if ($act eq $capture) { die "Ply capture (__x__) does not match board!\n"; }
		$act = $occupy;
	}
	else {
		if ($act eq $occupy)  { die "Ply occupy (__-__) does not match board!\n"; }
		$act = $capture;
	}

	#
	# Effect the move:
	#
	# TODO: Deal with castle capabilities and en passant target.
	# TODO: Detect check and checkmate for notes (and validate against those
	# passed in, if any).
	# TODO: Detect en passant capture for notes.
	# TODO: Detect en passant capture for notes.
	# TODO: Detect illegal moves based on move pattern of piece, or intervening
	# pieces, etc.
	# TODO: Detect forced for notes.
	#

	$board->{$tf}{$tr} = $board->{$ff}{$fr};
	$board->{$ff}{$fr} = $empty;

	#
	# Print the move:
	#

	if (!defined $notation) {
		if (is_pawn($piece)) { $piece = $empty; }
		$notation = $piece . $ff . $fr . $act . $tf . $tr . $note;
	}

	if ($to_move == $white) {
		print "$move. $notation ";
		$to_move = $black;
		$ply++;
	}
	else {
		print "$notation\n";
		$to_move = $white;
		$ply++;
		$move++;
	}
}


#
# move()
#

sub move
{
	ply $_[0];
	ply $_[1];
}


#
# Return success:
#

1;

#
# End of file.
#
