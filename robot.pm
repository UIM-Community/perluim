use strict;
use warnings;

package perluim::robot;

# Nimsoft librairies !
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

# perluim librairies
use perluim::probe;
use perluim::package;

sub new {
    my ($class,$o) = @_;
    my $this = {
        name            => $o->get("name") || $o->get("robotname") ,
        origin          => $o->get("origin"),
        addr            => $o->get("addr") || "/".$o->get("domain")."/".$o->get("hubname")."/".$o->get("robotname"),
        port            => $o->get("port") || "48000",
        version         => $o->get("version"),
        ip              => $o->get("ip") || $o->get("robotip"),
        status          => $o->get("status") || 0,
        os_major        => $o->get("os_major"),
        os_minor        => $o->get("os_minor"),
        os_user1        => $o->get("os_user1"),
        os_user2        => $o->get("os_user2"),
        os_description  => $o->get("os_description"),
        ssl_mode        => $o->get("ssl_mode"),
        device_id       => $o->get("device_id") || $o->get("robot_device_id"),
        metric_id       => $o->get("metric_id"),
        probe_list      => {},
        hubname         => "",
        hubip           => "",
        domain          => "",
        robotip         => "",
        hubrobotname    => "",
        uptime          => 0,
        started         => 0,
        os_version      => "",
        workdir         => "",
        log_level       => 0,
        source          => ""

    };
    return bless($this,ref($class) || $class);
}

#
# => Get robot information !
#
sub getInfo {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}/controller","get_info",$PDS,1);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        $self->{hubname}        = $RobotNFO->{hubname};
        $self->{hubip}          = $RobotNFO->{hubip};
        $self->{domain}         = $RobotNFO->{domain};
        $self->{robotip}        = $RobotNFO->{robotip};
        $self->{hubrobotname}   = $RobotNFO->{hubrobotname};
        $self->{uptime}         = $RobotNFO->{uptime};
        $self->{started}        = $RobotNFO->{started};
        $self->{os_version}     = $RobotNFO->{os_version};
        $self->{workdir}        = $RobotNFO->{workdir};
        $self->{log_level}      = $RobotNFO->{log_level};
        $self->{source}         = $RobotNFO->{source};
        return 1;
    }
    else {
        return 0;
    }
}

sub getLocalInfo {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("$self->{name}",48000,"get_info",$PDS,1);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        $self->{hubname}        = $RobotNFO->{hubname};
        $self->{hubip}          = $RobotNFO->{hubip};
        $self->{domain}         = $RobotNFO->{domain};
        $self->{robotip}        = $RobotNFO->{robotip};
        $self->{hubrobotname}   = $RobotNFO->{hubrobotname};
        $self->{uptime}         = $RobotNFO->{uptime};
        $self->{started}        = $RobotNFO->{started};
        $self->{os_version}     = $RobotNFO->{os_version};
        $self->{workdir}        = $RobotNFO->{workdir};
        $self->{log_level}      = $RobotNFO->{log_level};
        $self->{source}         = $RobotNFO->{source};
        return 1;
    }
    else {
        return 0;
    }
}

sub dump {
    my ($self) = @_;
    my $str = "";
    $str.= "Robot : $self->{name} = {\n";
    $str.= "\t Ip : $self->{ip}\n";
    $str.= "\t OS_Major : $self->{os_major}\n";
    $str.= "\t OS_Minor : $self->{os_minor}\n";
    $str.= "\t Origin : $self->{origin}\n";
    $str.= "\t Hubname : $self->{hubname}\n";
    $str.= "}\n";
}

sub getLocalHub {
    my ($self) = @_;
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("$self->{name}",48000,"gethub",$PDS,1);
    pdsDelete($PDS);
    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        $self->{phub_domain}        = $RobotNFO->{phub_domain} || "NMS-PROD";
        $self->{phub_name}          = $RobotNFO->{phub_name} || "";
        $self->{phub_robotname}     = $RobotNFO->{phub_robotname} || "";
        $self->{phub_ip}            = $RobotNFO->{phub_ip} || "";
        $self->{phub_dns_name}      = $RobotNFO->{phub_dns_name} || $RobotNFO->{phub_name} || "";
        $self->{phub_port}          = $RobotNFO->{phub_port} || 48002;
        $self->{shub_domain}        = $RobotNFO->{shub_domain} || "NMS-PROD";
        $self->{shub_name}          = $RobotNFO->{shub_name} || "";
        $self->{shub_robotname}     = $RobotNFO->{shub_robotname} || "";
        $self->{shub_ip}            = $RobotNFO->{shub_ip} || "";
        $self->{shub_dns_name}      = $RobotNFO->{shub_dns_name} || $RobotNFO->{shub_name} || "";
        $self->{shub_port}          = $RobotNFO->{shub_port} || 48002;
        return 1;
    }
    else {
        return 0;
    }
}

sub getHub {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}/controller","gethub",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        return 1;
    }
    else {
        return 0;
    }
}

sub getPackages {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}/controller","inst_list_summary",$PDS,1);
    pdsDelete($PDS);

    my @PackagesList = ();
    if($RC == NIME_OK) {
        my $PACKAGE_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $PACKAGENFO = $PACKAGE_PDS->getTable("pkg",PDS_PDS,$count); $count++) {
            my $Package = new perluim::package($PACKAGENFO);
            push(@PackagesList,$Package);
        }
    }
    return @PackagesList;
}

sub getLocalPackages {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("$self->{name}",48000,"inst_list_summary",$PDS,1);
    pdsDelete($PDS);

    my @PackagesList = ();
    my $RC_REQUEST = 0;
    if($RC == NIME_OK) {
        my $PACKAGE_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $PACKAGENFO = $PACKAGE_PDS->getTable("pkg",PDS_PDS,$count); $count++) {
            if( $PACKAGENFO->get("name") ) {
                my $Package = new perluim::package($PACKAGENFO);
                push(@PackagesList,$Package);
            }
        }
        $RC_REQUEST = 1;
    }
    return ($RC_REQUEST,@PackagesList);
}

sub getArrayProbes {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}/controller","probe_list",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my @ProbesArray = ();
        my $ProbeCFG = Nimbus::PDS->new($NMS_RES)->asHash();
        foreach my $ProbeName (keys $ProbeCFG) {
            my $Iprobe = new perluim::probe($ProbeName,$ProbeCFG,$self->{addr});
            push(@ProbesArray,$Iprobe);
        }
        return $RC,@ProbesArray;
    }
    return $RC,undef;
}

sub getLocalArrayProbes {
    my ($self) = @_;

    my @ProbesArray = ();
    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("$self->{name}",48000,"probe_list",$PDS,1);
    pdsDelete($PDS);

    my $REQUEST_RC = 0;
    if($RC == NIME_OK) {
        my $ProbeCFG = Nimbus::PDS->new($NMS_RES)->asHash();
        foreach my $ProbeName (keys $ProbeCFG) {
            my $Iprobe = new perluim::probe($ProbeName,$ProbeCFG,$self->{addr});
            $Iprobe->{robotname} = $self->{name};
            push(@ProbesArray,$Iprobe);
        }
        $REQUEST_RC = 1;
    }
    return ($REQUEST_RC,@ProbesArray);
}

sub probeRestart {
    my ($self,$probeName) = @_;
	my $RC = nimNamedRequest( "$self->{addr}/$probeName", "_restart");
	return $RC;
}

sub probeDeactivate {
	my ($self,$probeName) = @_;

	my $PDS = pdsCreate();
	pdsPut_PCH($PDS,"name",$probeName);
	pdsPut_INT($PDS,"noforce",1);
	my ($RC,$OBJ) = nimNamedRequest( "$self->{addr}/controller", "probe_deactivate",$PDS,5);

	return $RC;
}

sub probeActivate {
	my ($self,$probeName) = @_;

	my $PDS = pdsCreate();
	pdsPut_PCH($PDS,"name",$probeName);
	my ($RC,$OBJ) = nimNamedRequest( "$self->{addr}/controller", "probe_activate",$PDS,5);

	return $RC;
}

1;
