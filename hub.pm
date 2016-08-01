use strict;
use warnings;

# Namespace
package perluim::hub;

# Nimsoft librairies !
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

# Bnpp packages
use perluim::robot;

use Data::Dumper;
$Data::Dumper::Indent = 1;

sub new {
    my ($class,$o) = @_;
    my @addrArray;
    if($o->get("hubaddr")) {
        @addrArray = split("/",$o->get("hubaddr"));
    }
    my $this = {
        name        => $o->get("name") || $o->get("hubname"),
        robotname   => $o->get("robotname") || $addrArray[4] || "undefined",
        addr        => $o->get("addr") || $o->get("hubaddr"),
        domain      => $o->get("domain"),
        ip          => $o->get("ip") || $o->get("hubip"),
        port        => $o->get("port"),
        status      => $o->get("status"),
        version     => $o->get("version"),
        origin      => $o->get("origin") || "BP2I",
        source      => $o->get("source"),
        last        => $o->get("last"),
        origin      => $o->get("origin"),
        license     => $o->get("license"),
        sec_on      => $o->get("sec_on"),
        sec_ver     => $o->get("sec_ver"),
        ssl_mode    => $o->get("ssl_mode"),
        ldap        => $o->get("ldap"),
        ldap_version => $o->get("ldap_version") || "unknown",
        tunnel      => $o->get("tunnel") || "no",
        uptime      => $o->get("uptime") || 0,
        started     => $o->get("started") || 0
    };
    return bless($this,ref($class) || $class);
}

#
# => Remove robot from the HUB !
#
sub RemoveRobot {
	my ($self,$robotName) = @_;
	my $PDS = pdsCreate();
	pdsPut_PCH ($PDS,"name",$robotName);
	pdsPut_PCH ($PDS,"name","controller");

	my ($RC, $O) = nimNamedRequest("$self->{addr}", "removerobot", $PDS);
	pdsDelete($PDS);
    return $RC;
}

sub Get_Robot {
    my ($self,$robotname) = @_;
    my $PDS = pdsCreate();
    pdsPut_PCH($PDS,"name","$robotname");
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        return Nimbus::PDS->new($NMS_RES);
    }
    else {
        print "get robot failed!\n";
        return 0;
    }
}

#
# => Get an Array of robots in the instanciate HUB!
#
sub GET_ArrayRobots {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
    pdsDelete($PDS);

    my @RobotsList = ();
    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new bnpp::robot($ROBOTNFO);
            push(@RobotsList,$ROBOT);
        }
    }
    return @RobotsList;
}

#
# => Get an Hash of robots in the instanciate HUB!
#
sub GET_HashRobots {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
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

1;
