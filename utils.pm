package perluim::utils;

use strict;
use warnings;
use Exporter qw(import);
use Nimbus::API;
use Nimbus::Session;
use Nimbus::CFG;
use Nimbus::PDS;

our @EXPORT_OK = qw(minIndex getTerminalInput getDate rndStr createDirectory doSleep generateAlarm nimId postRaw strBeginWith);

sub doSleep {
    my ($self,$sleepTime) = @_;
    while($sleepTime--) {
        sleep(1);
    }
}

sub strBeginWith {
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

sub createDirectory {
    my ($path) = @_;
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

sub rndStr { 
    return join'', @_[ map{ rand @_ } 1 .. shift ] 
}

sub nimId {
    my $A = rndStr(10,'A'..'Z',0..9);
    my $B = rndStr(5,0..9);
    return "$A-$B";
}

sub generateAlarm {
    my ($subject,$hashRef) = @_;

    my $PDS = pdsCreate(); 
    my $nimid = nimId();

    pdsPut_PCH($PDS,"nimid",$nimid);
    pdsPut_INT($PDS,"nimts",time());
    pdsPut_INT($PDS,"tz_offset",-3600);
    pdsPut_PCH($PDS,"subject","$subject");
    #pdsPut_PCH($PDS,"md5sum","");
    pdsPut_PCH($PDS,"user_tag_1",$hashRef->{usertag1} || "");
    pdsPut_PCH($PDS,"user_tag_2",$hashRef->{usertag2} || "");
    pdsPut_PCH($PDS,"source",$hashRef->{source} || $hashRef->{robot} || "");
    pdsPut_PCH($PDS,"robot",$hashRef->{robot} || "");
    pdsPut_PCH($PDS,"prid",$hashRef->{probe} || "");
    pdsPut_INT($PDS,"pri",$hashRef->{severity} || 1);
    pdsPut_PCH($PDS,"dev_id",$hashRef->{dev_id} || "");
    pdsPut_PCH($PDS,"met_id",$hashRef->{met_id} || "");
    pdsPut_PCH($PDS,"supp_key",$hashRef->{supp_key} || "1");
    pdsPut_PCH($PDS,"suppression",$hashRef->{suppression} || "");
    pdsPut_PCH($PDS,"origin",$hashRef->{origin} || "");
    pdsPut_PCH($PDS,"domain",$hashRef->{domain} || "");

    my $AlarmPDS = pdsCreate();
    pdsPut_INT($AlarmPDS,"level",$hashRef->{severity} || 0);
    pdsPut_PCH($AlarmPDS,"message",$hashRef->{message});
    pdsPut_PCH($AlarmPDS,"subsys",$hashRef->{subsystem} || 1);
    if(defined $hashRef->{token}) {
        pdsPut_PCH($AlarmPDS,"token",$hashRef->{token});
    }

    pdsPut_PDS($PDS,"udata",$AlarmPDS);

    return ($PDS,$nimid);
}   

sub postRaw {
    my ($alarmHashRef) = @_;
    if(not defined $alarmHashRef->{robot}) {
        return undef,undef;
    }
    else {
        my $robot = $alarmHashRef->{robot}; 
        if(not defined $alarmHashRef->{origin}) {
            $alarmHashRef->{origin} = $robot->{origin};
        }
        
        if(not defined $alarmHashRef->{usertag1}) {
            $alarmHashRef->{usertag1} = $robot->{os_user1};
        }

        if(not defined $alarmHashRef->{usertag2}) {
            $alarmHashRef->{usertag2} = $robot->{os_user2};
        }

        if(not defined $alarmHashRef->{dev_id}) {
            $alarmHashRef->{dev_id} = $robot->{device_id};
        }

        if(not defined $alarmHashRef->{met_id}) {
            $alarmHashRef->{met_id} = $robot->{metric_id};
        }

        if(not defined $alarmHashRef->{source}) {
            $alarmHashRef->{source} = $robot->{ip};
        }

        $alarmHashRef->{robot} = $robot->{name};
    }

    my ($PDS,$alarmid) = generateAlarm('alarm',$alarmHashRef);
    my ($rc_alarm,$res) = nimRequest("$alarmHashRef->{robot}",48001,"post_raw",$PDS);
    return $rc_alarm,$alarmid;
}
