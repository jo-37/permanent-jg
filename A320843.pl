#!/usr/bin/perl

use v5.26;
use warnings;

use experimental qw(signatures);

die <<EOS unless 0 < @ARGV <= 2;
usage: $0 FROM [TO]

FROM
    start size

TO
    end size, default: FROM

EOS

my ($from, $to) = @ARGV;
$to //= $from;

say "$_ ", count_cute($_) for $from .. $to;


### Implementation

use integer;

sub count_cute ($n) {
    # Build the adjacency matrix A for a "cute list" of size N.
    my @a;
    for my $i (0 .. $n - 1) {
        for my $k (0 .. $n - 1) {
            my $v = 0 + (!(($i + 1) % ($k + 1)) || !(($k + 1) % ($i + 1)));
            $a[$i][$k] = $v;
        }
    }
    my @s = sort {grep($_, @$a) <=> grep($_, @$b)} @a;

    # Find the number of cute lists.
    permanent(\@s);
}

# An attempt to implement the "Johnson-Gentleman tree minor algorithm":
# This is a non-recursive approach that avoids the re-examination of
# minors appearing in recursive approaches.  It does not split the task
# of calculating a determinant/permanent into smaller tasks but instead
# builds the whole result by extending from single elements.  This takes
# a lot of memory for larger matrices.  Restricting to matrices having
# only zeroes and ones as elements.
#
sub permanent ($a) {
    my $node;
    my $last = $#$a;
    my $sel;

    # Nodes are key-value pairs where the keys are integers with bits
    # set for the selected columna forming a minor matrix and the
    # corresponding sub-permanent as values.

    # The first node is the empty minor
    $node->{0} = 1;

    # Loop over all rows
    for my $i (0 .. $last) {
        my $next;
        # Loop over all minors of the previous node. These have a size
        # of $i x $i
        my $row = $a->[$i];
        for my $minor (keys %$node) {
            # Loop over all columns.  Process only nonzero elements
            # and columns that are not part of the current minor.
            # Add the minor's part to the next larger minor extended
            # by the current column.
            $row->[$_] && !(($sel = 1 << $_) & $minor) &&
            ($next->{$minor | $sel} += $row->[$_] * $node->{$minor})
            for 0 .. $last;
        }
        $node = $next;
    }
    
    # At the end, there is only one value left - the permanent of the
    # whole matrix.
    (values %$node)[0];
}
