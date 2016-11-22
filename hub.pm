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

# perluim packages
use perluim::robot;
use perluim::package;

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

sub removeRobot {
	my ($self,$robotName) = @_;
	my $PDS = pdsCreate();
	pdsPut_PCH ($PDS,"name",$robotName);
	pdsPut_PCH ($PDS,"name","controller");

	my ($RC, $O) = nimNamedRequest("$self->{addr}", "removerobot", $PDS);
	pdsDelete($PDS);
    return $RC;
}

sub getRobots {
    my ($self,$robotname) = @_;
    my $PDS = pdsCreate();
    pdsPut_PCH($PDS,"name","$robotname");
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        return $RC,Nimbus::PDS->new($NMS_RES);
    }
    else {
        return $RC,undef;
    }
}

#
# => Get an Array of robots in the instanciate HUB!
#
sub getArrayRobots {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
    pdsDelete($PDS);

    my @RobotsList = ();
    if($RC == NIME_OK) {
        my $ROBOTS_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $ROBOTNFO = $ROBOTS_PDS->getTable("robotlist",PDS_PDS,$count); $count++) {
            my $ROBOT = new perluim::robot($ROBOTNFO);
            push(@RobotsList,$ROBOT);
        }
    }
    return @RobotsList;
}

#
# => Get an Hash of robots in the instanciate HUB!
#
sub getHashRobots {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}","getrobots",$PDS,10);
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

#
# => Get Archive information
#
sub getArchivePackages {
    my ($self,$name,$version) = @_;
    my $PDS = pdsCreate();
    my $clean_addr = substr($self->{addr},0,-4);
    my ($RC,$NMS_RES) = nimNamedRequest("$clean_addr/automated_deployment_engine","archive_list",$PDS,10);
    pdsDelete($PDS);

    my %PackagesList = ();
    if($RC == NIME_OK) {
        my $PKG_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $PKG_INFO = $PKG_PDS->getTable("entry",PDS_PDS,$count); $count++) {
            my $PKG = new perluim::package($PKG_INFO);
            if(defined($PKG->{version}) && $PKG->{version} ne "") {
                $PackagesList{"$PKG->{name}_$PKG->{version}_$PKG->{build}"} = $PKG;
            }
            else {
                $PKG->setValid(0);
                $PackagesList{"$PKG->{name}_NV"} = $PKG;
            }
        }
        return $RC,%PackagesList;
    }
    else {
        return $RC,%PackagesList;
    }
}

sub getEnv {
    my ($self,$var) = @_;

    my $PDS = pdsCreate();
    if(defined($var)) {
        pdsPut_PCH ($PDS,"variable","$var");
    }
    my $clean_addr = substr($self->{addr},0,-4);
    my ($RC,$RES) = nimNamedRequest("$clean_addr/controller","get_environment",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $Hash = Nimbus::PDS->new($RES)->asHash();
        return $RC,$Hash;
    }
    return $RC,undef;
}

sub getInfo {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my $clean_addr = substr($self->{addr},0,-4);
    my ($RC,$RES) = nimNamedRequest("$clean_addr/controller","get_info",$PDS,10);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $Hash = Nimbus::PDS->new($RES)->asHash();
        return $RC,$Hash;
    }
    return $RC,undef;
}

sub ade_addPackageSyncRule {
    my ($self,$pkg) = @_;

    my $PDS = pdsCreate();
    pdsPut_PCH ($PDS,"name",$pkg->{name});
    pdsPut_PCH ($PDS,"rule_type","ALL");
    my $clean_addr = substr($self->{addr},0,-4);
    my ($RC,$NMS_RES) = nimNamedRequest("$clean_addr/automated_deployment_engine","add_package_sync_rule",$PDS,10);
    pdsDelete($PDS);
    return $RC;
}

sub deletePackage {
    my ($self,$name,$version) = @_;

    my $PDS = pdsCreate();
    my $clean_addr = substr($self->{addr},0,-4);
    pdsPut_PCH($PDS,"name","$name");
    pdsPut_PCH($PDS,"version","$version");
    my ($RC,$NMS_RES) = nimNamedRequest("$clean_addr/automated_deployment_engine","archive_delete",$PDS,10);
    pdsDelete($PDS);

    return $RC;
}

sub probeVerify {
    my ($self,$probeName) = @_;
    my $PDS = pdsCreate();
    pdsPut_PCH($PDS,"name","automated_deployment_engine");
    my $FilterADDR = substr($self->{addr},0,-4);
    my ($RC,$NMS_RES) = nimNamedRequest("$FilterADDR/controller","probe_verify",$PDS,10);
    pdsDelete($PDS);
    return $RC;
}

1;
