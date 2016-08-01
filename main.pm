use strict;
use warnings;
package perluim::main;

# Nimsoft packages
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::CFG;
use Nimbus::PDS;

# Bnpp packages
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
    my ($class,$probeName,$domain,$debug) = @_;
    my $this = {
        domain => $domain,
        probeName => $probeName,
        debug => $debug,
        user => undef,
        password => undef
    };
    nimLogSet("$probeName.log",$probeName,0,0);
    if($debug) {
        my $rc = nimLogin("administrator","nim76prox");
        if(not $rc) {
            die "Unable to connect to the nimsoft HUB !\n";
        }
    }
    return bless($this,ref($class) || $class);
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

sub PUT {
    my ($self,$URL) = @_;
    my $request = HTTP::Request->new(PUT => "$URL");
    $request->authorization_basic( "$self->{user}", "$self->{password}" );
    my $ua = LWP::UserAgent->new( ssl_opts => {
        verify_hostname => 0,
        SSL_verify_mode => 0x00
    });
    $ua->timeout(10);
    my $response = $ua->request($request);
    return $response
}

sub Get_LocalRobot {
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
        return new bnpp::robot($PDS);
    }
    else {
        print "GET INFO for Robot $self->{name} failed with RC $RC\n";
        return 0;
    }
}

sub getInput {
    my $input;
    while(<>) {
        s/\s*$//;
        $input = $_;
        if(defined $input && $input ne "") {
            return $input;
        }
    }
}

sub Get_RobotsInfrastructure {
    my ($self) = @_;
    my @LIST_HUB        = $self->Get_ArrayHUBS();
    my %LIST_ROBOTS     = ();
    foreach my $hub (@LIST_HUB) {
        my @ROBOTS = $hub->GET_ArrayRobots();
        foreach my $robot (@ROBOTS) {
            $LIST_ROBOTS{lc $robot->{name}} = $robot;
        }
    }
    return %LIST_ROBOTS;
}

sub Get_LocalHub {
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
        return new bnpp::hub($PDS);
    }
    else {
        print "GET INFO for hub $self->{name} failed with RC $RC\n";
        return 0;
    }
}

sub Get_ArrayHUBS {
    my ($self,$hubADDR) = @_;
    my $focus_hubADDR = $hubADDR || "hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$focus_hubADDR","gethubs",$PDS,10);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $HUBS_PDS = Nimbus::PDS->new($NMS_RES);
        my @Hubslist = ();
        for( my $count = 0; my $HUBNFO = $HUBS_PDS->getTable("hublist",PDS_PDS,$count); $count++) {
            my $HUB = new bnpp::hub($HUBNFO);
            push(@Hubslist,$HUB);
        }
        return @Hubslist;
    }
    else {
        return $RC;
    }
}

sub Get_HashHUBS {
    my ($self,$hubADDR) = @_;
    my $focus_hubADDR = $hubADDR || "hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$focus_hubADDR","gethubs",$PDS,10);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $HUBS_PDS = Nimbus::PDS->new($NMS_RES);
        my %Hubslist = ();
        for( my $count = 0; my $HUBNFO = $HUBS_PDS->getTable("hublist",PDS_PDS,$count); $count++) {
            my $HUB = new bnpp::hub($HUBNFO);
            $Hubslist{$HUB->{name}} = $HUB;
        }
        return %Hubslist;
    }
    else {
        return $RC;
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

sub excludeHUBS {
    my ($self,$arrayHUBS,$excludeHUB) = @_;
    my @tempArray = ();
    foreach(@$arrayHUBS) {
        my $hubName = $_->{name};
        if(not exists $excludeHUB->{$hubName}) {
            push(@tempArray,$_);
        }
    }
    return @tempArray;
}

sub includeProbe {
    my ($self,$arrayPROBES,$includeProbe) = @_;
    my @tempArray = ();
    my %Hash = %{ $includeProbe };
    foreach my $probe (@$arrayPROBES) {
        if(exists $Hash{ $probe->{name} }) {
            push(@tempArray,$probe);
        }
    }
    return @tempArray;
}


sub Get_HashRobots {
    my ($self,$hubname,$hubserver) = @_;
    my $addr = "/$self->{domain}/$hubname/$hubserver/hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$addr","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        my %RobotsList = ();
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new bnpp::robot($ROBOTNFO);
            $RobotsList{$ROBOT->{name}} = $ROBOT;
        }
        return %RobotsList;
    }
    else {
        return $RC;
    }
}

sub Get_ArrayRobots {
    my ($self,$hubname,$hubserver) = @_;
    my $addr = "/$self->{domain}/$hubname/$hubserver/hub";
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$addr","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        my @RobotsList = ();
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new bnpp::robot($ROBOTNFO);
            push(@RobotsList,$ROBOT);
        }
        return @RobotsList;
    }
    else {
        return $RC;
    }
}

sub Get_LocalArrayRobots {
    my ($self,$retry) = @_;
    my $maxRetry = defined($retry) ? $retry : 1;
    my @RobotsList = ();

    while($maxRetry--) {
        my $PDS = pdsCreate();
        my ($RC,$NMS_RES) = nimNamedRequest("hub","getrobots",$PDS,10);
        pdsDelete($PDS);
        if($RC == NIME_OK) {
            my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
            for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
                my $ROBOT = new bnpp::robot($ROBOTNFO);
                push(@RobotsList,$ROBOT);
            }
            last;
        }
        else {
            $self->doSleep(2);
        }
    }
    return @RobotsList;
}

sub doSleep {
    my ($self,$sleepTime) = @_;
    while($sleepTime--) {
        sleep(1);
    }
}

sub Get_RCInformation {
    my ($self,$RC) = @_;
    if($RC == 2) {
        return "NIME_COMERR - Communication error";
    }
    elsif($RC == 3) {
        return "NIME_INVAL - ";
    }
    elsif($RC == 4) {
        return "NIME_NOENT - ";
    }
}

1;
