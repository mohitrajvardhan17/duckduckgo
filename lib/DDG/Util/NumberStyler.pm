package DDG::Util::NumberStyler;
# ABSTRACT: A role to allow Goodies to recognize and work with numbers in different notations.

use strict;
use warnings;

BEGIN {
    require Exporter;
    our @ISA = qw(Exporter);
    our @EXPORT = qw(
        number_style_for
        number_style_regex
    );
}

use DDG::Util::NumberStyle;

use List::Util qw( all first );

# If it could fit more than one the first in order gets preference.
my @known_styles = (
    DDG::Util::NumberStyle->new({
            id        => 'perl',
            decimal   => '.',
            thousands => ',',
        }
    ),
    DDG::Util::NumberStyle->new({
            id        => 'euro',
            decimal   => ',',
            thousands => '.',
        }
    ),
);

sub number_style_regex {
    my $return_regex = join '|', map { $_->number_regex } @known_styles;
    return qr/$return_regex/;
}

# Takes an array of numbers and returns which style to use for parse and display
# If there are conflicting answers among the array, will return undef.
sub number_style_for {
    my @numbers = @_;

    my $style;    # By default, assume we don't understand the numbers.

    STYLE:
    foreach my $test_style (@known_styles) {
        my $exponential = lc $test_style->exponential;    # Allow for arbitrary casing.
        if (all { $test_style->understands($_) } map { split /$exponential/, lc $_ } @numbers) {
            # All of our numbers fit this style.  Since we have them in preference order
            # we can pick it and move on.
            $style = $test_style;
            last STYLE;
        }
    }

    return $style;
}

1;
