package perluim::main;

use strict;
use Carp;
use vars qw(@ISA @EXPORT $AUTOLOAD);
require 5.010;
require Exporter;
require DynaLoader;
require AutoLoader;

use Nimbus::API;
use Nimbus::CFG;
use Nimbus::PDS;

# perluim packages
use perluim::hub;
use perluim::robot;


@ISA = qw(Exporter DynaLoader);

@EXPORT = qw(
    localRequest
);
no warnings 'recursion';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.
	no strict 'refs'; 
	
	my $sub = $AUTOLOAD;
    my $constname;
    ($constname = $sub) =~ s/.*:://;
	
	$!=0; 
    my ($val,$rc) = constant($constname, @_ ? $_[0] : 0);
    if ($rc != 0) {
		$AutoLoader::AUTOLOAD = $sub;
		goto &AutoLoader::AUTOLOAD;
    }
    *$sub = sub { $val }; # Same as eval "sub $sub { $val }";
    goto &$sub;
}

sub new {
    my ($class,$domain) = @_;
    my $this = {
        domain => $domain
    };
    return bless($this,ref($class) || $class);
}

sub localRequest {
    print "local request started!\n";
}

sub getLocalRobot {
    my ($self,$addr) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest($addr || "controller","get_info",$PDS,1);
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
    my ($RC_Hub,@LIST_HUB) = $self->getArrayHubs();
    if($RC_Hub == NIME_OK) {
        my %LIST_ROBOTS     = ();
        foreach my $hub (@LIST_HUB) {
            my ($RC,@ROBOTS) = $hub->robotsArray();
            next if $RC != NIME_OK;
            foreach my $robot (@ROBOTS) {
                $LIST_ROBOTS{lc $robot->{name}} = $robot;
            }
        }
        return $RC_Hub,%LIST_ROBOTS;
    }
    return $RC_Hub,undef;
}

sub getLocalHub {
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

1;
