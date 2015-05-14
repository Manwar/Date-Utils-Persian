package Date::Utils::Persian;

$Date::Utils::Persian::VERSION = '0.02';

=head1 NAME

Date::Utils::Persian - Persian date specific routines as Moo Role.

=head1 VERSION

Version 0.02

=cut

use 5.006;
use Data::Dumper;
use POSIX qw/floor ceil/;
use Date::Calc qw/Delta_Days/;

use Moo::Role;
use namespace::clean;

our $PERSIAN_MONTHS = [
    '',
    'Farvardin',  'Ordibehesht',  'Khordad',  'Tir',  'Mordad',  'Shahrivar',
    'Mehr'     ,  'Aban'       ,  'Azar'   ,  'Dey',  'Bahman',  'Esfand'
];

our $PERSIAN_DAYS = [
    '<yellow><bold>    Yekshanbeh </bold></yellow>',
    '<yellow><bold>     Doshanbeh </bold></yellow>',
    '<yellow><bold>    Seshhanbeh </bold></yellow>',
    '<yellow><bold> Chaharshanbeh </bold></yellow>',
    '<yellow><bold>   Panjshanbeh </bold></yellow>',
    '<yellow><bold>         Jomeh </bold></yellow>',
    '<yellow><bold>       Shanbeh </bold></yellow>'
];

has persian_epoch  => (is => 'ro', default => sub { 1948320.5       });
has persian_days   => (is => 'ro', default => sub { $PERSIAN_DAYS   });
has persian_months => (is => 'ro', default => sub { $PERSIAN_MONTHS });

with 'Date::Utils';

=head1 DESCRIPTION

Persian date specific routines as Moo ROle.

=head1 METHODS

=head2 persian_to_gregorian($year, $month, $day)

Returns Gregorian date as list (year, month, day) equivalent of the given Persian
date.

=cut

sub persian_to_gregorian {
    my ($self, $year, $month, $day) = @_;

    $self->validate_date($year, $month, $day);
    ($year, $month, $day) =  $self->julian_to_gregorian($self->persian_to_julian($year, $month, $day));

    return ($year, $month, $day);
}

=head2 gregorian_to_persian($year, $month, $day)

Returns Persian date as list (year, month, day) equivalent of the given Gregorian
date.

=cut

sub gregorian_to_persian {
    my ($self, $year, $month, $day) = @_;

    $self->validate_date($year, $month, $day);
    my $julian = $self->gregorian_to_julian($year, $month, $day) + (floor(0 + 60 * (0 + 60 * 0) + 0.5) / 86400.0);
    ($year, $month, $day) = $self->julian_to_persian($julian);

    return ($year, $month, $day);
}

=head2 persian_to_julian($year, $month. $day)

Returns Julian date of the given Persian date.

=cut

sub persian_to_julian {
    my ($self, $year, $month, $day) = @_;

    my $epbase = $year - (($year >= 0) ? 474 : 473);
    my $epyear = 474 + ($epbase % 2820);

    return $day + (($month <= 7)?(($month - 1) * 31):((($month - 1) * 30) + 6)) +
           floor((($epyear * 682) - 110) / 2816) +
           ($epyear - 1) * 365 +
           floor($epbase / 2820) * 1029983 +
           ($self->persian_epoch - 1);
}

=head2 julian_to_persian($julian_date)

Returns Persian date as list  (year, month, day)  equivalent of the  given Julian
date.

=cut

sub julian_to_persian {
    my ($self, $julian) = @_;

    $julian = floor($julian) + 0.5;
    my $depoch = $julian - $self->persian_to_julian(475, 1, 1);
    my $cycle  = floor($depoch / 1029983);
    my $cyear  = $depoch % 1029983;

    my $ycycle;
    if ($cyear == 1029982) {
        $ycycle = 2820;
    }
    else {
        my $aux1 = floor($cyear / 366);
        my $aux2 = $cyear % 366;
        $ycycle = floor(((2134 * $aux1) + (2816 * $aux2) + 2815) / 1028522) + $aux1 + 1;
    }

    my $year = $ycycle + (2820 * $cycle) + 474;
    if ($year <= 0) {
        $year--;
    }

    my $yday  = ($julian - $self->persian_to_julian($year, 1, 1)) + 1;
    my $month = ($yday <= 186) ? ceil($yday / 31) : ceil(($yday - 6) / 30);
    my $day   = ($julian - $self->persian_to_julian($year, $month, 1)) + 1;

    return ($year, $month, $day);
}

=head2 is_persian_leap_year($year)

Returns 0 or 1 if the given Persian year C<$year> is a leap year or not.

=cut

sub is_persian_leap_year {
    my ($self, $year) = @_;

    return (((((($year - (($year > 0) ? 474 : 473)) % 2820) + 474) + 38) * 682) % 2816) < 682;
}

=head2 days_in_persian_month_year($month, $year)

Returns total number of days in the given Persian month year.

=cut

sub days_in_persian_month_year {
    my ($self, $month, $year) = @_;

    $self->validate_year($year);
    $self->validate_month($month);

    my @start = $self->persian_to_gregorian($year, $month, 1);
    if ($month == 12) {
        $year += 1;
        $month = 1;
    }
    else {
        $month += 1;
    }

    my @end = $self->persian_to_gregorian($year, $month, 1);

    return Delta_Days(@start, @end);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Date-Utils-Persian>

=head1 ACKNOWLEDGEMENTS

Entire logic is based on the L<code|http://www.fourmilab.ch/documents/calendar> written by John Walker.

=head1 BUGS

Please report any bugs / feature requests to C<bug-date-utils-persian at rt.cpan.org>
, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-Utils-Persian>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::Utils::Persian

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-Utils-Persian>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-Utils-Persian>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-Utils-Persian>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-Utils-Persian/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Date::Utils::Persian
