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
    }
    return $RC;
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
    }
    return $RC;
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
    }
    return $RC;
}

sub getHub {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimNamedRequest("$self->{addr}/controller","gethub",$PDS,1);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $RobotNFO = Nimbus::PDS->new($NMS_RES)->asHash();
        return $RC,$RobotNFO;
    }
    return $RC,undef;
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
    return $RC,@PackagesList;
}

sub getLocalPackages {
    my ($self) = @_;

    my $PDS = pdsCreate();
    my ($RC,$NMS_RES) = nimRequest("$self->{name}",48000,"inst_list_summary",$PDS,1);
    pdsDelete($PDS);

    my @PackagesList = ();
    if($RC == NIME_OK) {
        my $PACKAGE_PDS = Nimbus::PDS->new($NMS_RES);
        for( my $count = 0; my $PACKAGENFO = $PACKAGE_PDS->getTable("pkg",PDS_PDS,$count); $count++) {
            if( $PACKAGENFO->get("name") ) {
                my $Package = new perluim::package($PACKAGENFO);
                push(@PackagesList,$Package);
            }
        }
    }
    return $RC,@PackagesList;
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

    if($RC == NIME_OK) {
        my $ProbeCFG = Nimbus::PDS->new($NMS_RES)->asHash();
        foreach my $ProbeName (keys $ProbeCFG) {
            my $Iprobe = new perluim::probe($ProbeName,$ProbeCFG,$self->{addr});
            $Iprobe->{robotname} = $self->{name};
            push(@ProbesArray,$Iprobe);
        }
    }
    return $RC,@ProbesArray;
}

sub getRobotCFG {
    my ($self,$filepath) = @_;

    my $PDS_args = pdsCreate();
    pdsPut_PCH ($PDS_args,"directory","robot");
    pdsPut_PCH ($PDS_args,"file","robot.cfg");
    pdsPut_INT ($PDS_args,"buffer_size",10000000);

    my ($RC, $ProbePDS_CFG) = nimNamedRequest("$self->{addr}/controller", "text_file_get", $PDS_args,3);
    pdsDelete($PDS_args);

    if($RC == NIME_OK) {
        my $CFG_Handler;
        unless(open($CFG_Handler,">","$filepath/robot_$self->{name}_.cfg")) {
            warn "\nUnable to create configuration file for robot probe on path $filepath\n";
            return 1;
        }
        my @ARR_CFG_Config = Nimbus::PDS->new($ProbePDS_CFG)->asHash();
        print $CFG_Handler $ARR_CFG_Config[0]{'file_content'};
        close $CFG_Handler;
        return $RC;
    }
    return $RC;
}

sub probeConfig_set {
    my ($self,$probeName,$section,$key,$value) = @_;

    my $PDS_args = pdsCreate();
    pdsPut_PCH ($PDS_args,"name","$probeName");
    pdsPut_PCH ($PDS_args,"section","$section");
    pdsPut_PCH ($PDS_args,"key","$key");
    pdsPut_PCH ($PDS_args,"value","$value");
    pdsPut_PCH ($PDS_args,"robot","1");

    my ($RC, $O) = nimNamedRequest("$self->{addr}/controller", "probe_config_set", $PDS_args,3);
    pdsDelete($PDS_args);

    return $RC;
}

sub probeConfig_get {
    my ($self,$probeName,$var) = @_;

    my $PDS_args = pdsCreate();
    pdsPut_PCH ($PDS_args,"name","$probeName");
    if(defined($var)) {
        pdsPut_PCH ($PDS_args,"var","$var");
    }

    my ($RC, $RES) = nimNamedRequest("$self->{addr}/controller", "probe_config_get", $PDS_args,3);
    pdsDelete($PDS_args);

    if($RC == NIME_OK) {
        if(defined($var)) {
            my $value = (Nimbus::PDS->new($RES))->get("value");
            return $RC,$value;
        }
        else {
            my $Hash = Nimbus::PDS->new($RES)->asHash();
            return $RC,$Hash;
        }
    }
    return $RC,undef;
}

sub probeExist {
    my ($self,$probeName) = @_;

    my $PDS = pdsCreate();
	pdsPut_PCH($PDS,"name",$probeName);
	my ($RC,$RES) = nimNamedRequest( "$self->{addr}/controller", "probe_list",$PDS,5);
    pdsDelete($PDS);

    if($RC == NIME_OK) {
        my $Hash = Nimbus::PDS->new($RES)->asHash();
        return $RC,$Hash->{"$probeName"};
    }
    return $RC,undef;
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
    pdsDelete($PDS);

	return $RC;
}

sub probeActivate {
	my ($self,$probeName) = @_;

	my $PDS = pdsCreate();
	pdsPut_PCH($PDS,"name",$probeName);
	my ($RC,$OBJ) = nimNamedRequest( "$self->{addr}/controller", "probe_activate",$PDS,5);
    pdsDelete($PDS);

	return $RC;
}

1;
