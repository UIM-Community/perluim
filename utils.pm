package perluim::utils;
use strict;
use warnings;
use Exporter qw(import);

use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::Session;
use Nimbus::CFG;
use Nimbus::PDS;

our @EXPORT_OK = qw(minIndex getTerminalInput);

sub minIndex {
	my( $aref, $idx_min ) = ( shift, 0 );
	$aref->[$idx_min] < $aref->[$_] or $idx_min = $_ for 1 .. $#{$aref};
	return $idx_min;
}

sub getTerminalInput {
    my $input;
    while(<>) {
        s/\s*$//;
        $input = $_;
        if(defined $input && $input ne "") {
            return $input;
        }
    }
}
