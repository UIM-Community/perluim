use strict;
use warnings;
package perluim::main;

# Nimsoft packages
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::CFG;
use Nimbus::PDS;

# perluim packages
use perluim::hub;
use perluim::robot;

use Term::ANSIColor qw(:constants);
use Win32::Console::ANSI;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use XML::Simple;
$Data::Dumper::Indent = 1;

sub new {
    my ($class,$domain) = @_;
    my $this = {
        domain => $domain,
        user => undef,
        password => undef,
        console => undef
    };
    return bless($this,ref($class) || $class);
}

sub setLog {
    my ($self,$console) = @_;
    $self->{console} = $console;
}

sub setAuthentification {
    my ($self,$user,$password) = @_;
    $self->{user} = $user;
    $self->{password} = $password;
}

sub HTTP {
    my ($self,$method,$URL) = @_;
    my $request = HTTP::Request->new("$method" => "$URL");
    $request->header( 'content-type' => 'application/json' );
    $request->header( 'accept' => 'application/json' );
    $request->authorization_basic( "$self->{user}", "$self->{password}" );
    my $ua = LWP::UserAgent->new( ssl_opts => {
        verify_hostname => 0,
        SSL_verify_mode => 0x00
    });
    $ua->timeout(30);
    my $response = $ua->request($request);
    return $response
}

sub getLocalRobot {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("controller","get_info",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        my $PDS = new Nimbus::PDS();
        foreach my $key (keys $RobotNFO) {
            $PDS->put($key,$RobotNFO->{$key},PDS_PCH);
        }
        return $RC,new perluim::robot($PDS);
    }
    else {
        return $RC,undef;
    }
}

sub getAllRobots {
    my ($self) = @_;
    my @LIST_HUB        = $self->getArrayHubs();
    my %LIST_ROBOTS     = ();
    foreach my $hub (@LIST_HUB) {
        my @ROBOTS = $hub->getArrayRobots();
        foreach my $robot (@ROBOTS) {
            $LIST_ROBOTS{lc $robot->{name}} = $robot;
        }
    }
    return %LIST_ROBOTS;
}

sub getHub {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("hub","get_info",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        my $PDS = new Nimbus::PDS();
        foreach my $key (keys $RobotNFO) {
            $PDS->put($key,$RobotNFO->{$key},PDS_PCH);
        }
        return $RC,new perluim::hub($PDS);
    }
    else {
        return $RC,undef;
    }
}

sub getLocalHub {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("hub",48000,"get_info",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        my $PDS = new Nimbus::PDS();
        foreach my $key (keys $RobotNFO) {
            $PDS->put($key,$RobotNFO->{$key},PDS_PCH);
        }
        return $RC,new perluim::hub($PDS);
    }
    else {
        return $RC,undef;
    }
}

sub getArrayHubs {
    my ($self,$hubADDR) = @_;
    my $focus_hubADDR = $hubADDR || "hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$focus_hubADDR","gethubs",$PDS,10);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $HUBS_PDS = Nimbus::PDS->new($NMS_RES);
        my @Hubslist = ();
        for( my $count = 0; my $HUBNFO = $HUBS_PDS->getTable("hublist",PDS_PDS,$count); $count++) {
            my $HUB = new perluim::hub($HUBNFO);
            push(@Hubslist,$HUB);
        }
        return $RC,@Hubslist;
    }
    else {
        return $RC,undef;
    }
}

sub getHashHubs {
    my ($self,$hubADDR) = @_;
    my $focus_hubADDR = $hubADDR || "hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$focus_hubADDR","gethubs",$PDS,10);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $HUBS_PDS = Nimbus::PDS->new($NMS_RES);
        my %Hubslist = ();
        for( my $count = 0; my $HUBNFO = $HUBS_PDS->getTable("hublist",PDS_PDS,$count); $count++) {
            my $HUB = new perluim::hub($HUBNFO);
            $Hubslist{$HUB->{name}} = $HUB;
        }
        return $RC,%Hubslist;
    }
    else {
        return $RC,undef;
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

sub getDate {
    my ($self) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $timestamp   = sprintf ( "%04d%02d%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	$timestamp     =~ s/\s+/_/g;
	$timestamp     =~ s/://g;
    return $timestamp;
}

sub getHashRobots {
    my ($self,$hubname,$hubserver) = @_;
    my $addr = "/$self->{domain}/$hubname/$hubserver/hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$addr","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        my %RobotsList = ();
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new perluim::robot($ROBOTNFO);
            $RobotsList{$ROBOT->{name}} = $ROBOT;
        }
        return $RC,%RobotsList;
    }
    else {
        return $RC,undef;
    }
}

sub getArrayRobots {
    my ($self,$hubname,$hubserver) = @_;
    my $addr = "/$self->{domain}/$hubname/$hubserver/hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$addr","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        my @RobotsList = ();
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new perluim::robot($ROBOTNFO);
            push(@RobotsList,$ROBOT);
        }
        return $RC,@RobotsList;
    }
    else {
        return $RC,undef;
    }
}

sub getLocalArrayRobots {
    my ($self,$retry) = @_;
    my $maxRetry = defined($retry) ? $retry : 1;
    my @RobotsList = ();

    my ($RC,$NMS_RES);
    while($maxRetry--) {
        my $PDS = pdsCreate();
        ($RC,$NMS_RES) = nimNamedRequest("hub","getrobots",$PDS,10);
        pdsDelete($PDS);
        if($RC == NIME_OK) {
            my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
            for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
                my $ROBOT = new perluim::robot($ROBOTNFO);
                push(@RobotsList,$ROBOT);
            }
            last;
        }
        else {
            $self->doSleep(2);
        }
    }
    return $RC,@RobotsList;
}

sub doSleep {
    my ($self,$sleepTime) = @_;
    while($sleepTime--) {
        sleep(1);
    }
}

1;
