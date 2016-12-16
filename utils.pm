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

our @EXPORT_OK = qw(minIndex getTerminalInput getDate randomString createDirectory doSleep);

sub doSleep {
    my ($self,$sleepTime) = @_;
    while($sleepTime--) {
        sleep(1);
    }
}


sub createDirectory {
    my ($self,$path) = @_;
    my @dir = split("/",$path);
    my $track = "";
    foreach(@dir) {
        my $path = $track.$_;
        if( !(-d $path) ) {
            mkdir($path) or die "Unable to create $_ directory!";
        }
        $track .= "$_/";
    }
}

sub randomString {
    my ($length) = @_; 
    my @set = ('0' ..'9', 'A' .. 'F');
    my $str = join '' => map $set[rand @set], 1 .. $length;
    return $str;
}

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

sub getDate {
    my ($self) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $timestamp   = sprintf ( "%04d%02d%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	$timestamp     =~ s/\s+/_/g;
	$timestamp     =~ s/://g;
    return $timestamp;
}
