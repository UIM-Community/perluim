use strict;
use warnings;

# Namespace
package perluim::probe;

# Nimsoft librairies !
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

sub new {
    my ($class,$name,$o,$addr) = @_;
    my $this = {
        name            => $o->{$name}{"name"},
        addr            => $addr,
        description     => $o->{$name}{"description"}  || "",
        group           => lc $o->{$name}{"group"}  || "",
        active          => $o->{$name}{"active"},
        type            => $o->{$name}{"type"},
        command         => $o->{$name}{"command"},
        config          => lc $o->{$name}{"config"},
        logfile         => lc $o->{$name}{"logfile"},
        workdir         => lc $o->{$name}{"workdir"},
        arguments       => $o->{$name}{"arguments"} || "",
        pid             => $o->{$name}{"pid"},
        times_started   => $o->{$name}{"times_started"},
        last_started    => $o->{$name}{"last_started"} || 0,
        pkg_name        => $o->{$name}{"pkg_name"} || "",
        pkg_version     => $o->{$name}{"pkg_version"} || "",
        pkg_build       => $o->{$name}{"pkg_build"} || "",
        process_state   => $o->{$name}{"process_state"} || "unknown",
        port            => $o->{$name}{"port"},
        times_activated => $o->{$name}{"times_activated"},
        timespec        => $o->{$name}{"timespec"},
        last_action     => $o->{$name}{"last_action"},
        is_marketplace  => $o->{$name}{"is_marketplace"},
        local_cfg       => undef
    };
    return bless($this,ref($class) || $class);
}

sub getCfg {
    my ($self,$filepath) = @_;
    my $tempGroup   = "probes/$self->{group}/$self->{name}/";
    my $configName  = $self->{config};

    $self->{local_cfg} = "$filepath"."$self->{config}";

    if($self->{name} eq "hub") {
        $tempGroup = "hub";
        $configName = "hub.cfg";
    }

    if($self->{name} eq "controller") {
        $tempGroup = "robot";
        $configName = "controller.cfg";
    }

    if($self->{name} eq "nas") {
        $tempGroup = "probes/service/$self->{name}/";
    }

    if($self->{name} eq "controller") {
        my $PDS_args = pdsCreate();
        pdsPut_PCH ($PDS_args,"directory",$tempGroup);
        pdsPut_PCH ($PDS_args,"file","robot.cfg");
        pdsPut_INT ($PDS_args,"buffer_size",10000000);

        my ($RC, $ProbePDS_CFG) = nimRequest("$self->{robotname}",48000, "text_file_get", $PDS_args,3);
        pdsDelete($PDS_args);

        if($RC == NIME_OK) {
            my $CFG_Handler;

            unless(open($CFG_Handler,">>","$filepath/robot.cfg")) {
                warn "\nUnable to create configuration file for robot probe on path $filepath\n";
                return 0;
            }
            my @ARR_CFG_Config = Nimbus::PDS->new($ProbePDS_CFG)->asHash();
            print $CFG_Handler $ARR_CFG_Config[0]{'file_content'};
            close $CFG_Handler;
        }
        else {

        }
    }

    {
        my $PDS_args = pdsCreate();
        pdsPut_PCH ($PDS_args,"directory",$tempGroup);
        pdsPut_PCH ($PDS_args,"file","$configName");
        pdsPut_INT ($PDS_args,"buffer_size",10000000);

        my ($RC, $ProbePDS_CFG) = nimRequest("$self->{robotname}",48000, "text_file_get", $PDS_args,3);
        pdsDelete($PDS_args);

        if($RC == NIME_OK) {
            my $CFG_Handler;

            unless(open($CFG_Handler,">>","$filepath/$configName")) {
                warn "\nUnable to create configuration file for $self->{name} probe on path $filepath\n";
                return 0;
            }
            my @ARR_CFG_Config = Nimbus::PDS->new($ProbePDS_CFG)->asHash();
            print $CFG_Handler $ARR_CFG_Config[0]{'file_content'};
            close $CFG_Handler;

            return 1;
        }
        else {

            return 0;
        }
    }

}

sub getLog {
    my ($self,$filepath) = @_;

    my $logName = "$self->{name}.log";
    my $log_pds = pdsCreate();
    pdsPut_PCH ($log_pds,"directory","probes/$self->{group}/$self->{name}/");
    pdsPut_PCH ($log_pds,"file","$logName");
    pdsPut_INT ($log_pds,"buffer_size",10000000);

    my ($RC_LOG, $LOGPDS) = nimRequest("$self->{robotname}","48000", "text_file_get", $log_pds,3);
    pdsDelete($log_pds);

    if($RC_LOG == NIME_OK) {
        my $CFG_Handler;
        unless(open($CFG_Handler,">>","$filepath/$logName")) {
            warn "\nUnable to create log file\n";
            return 0;
        }
        my @ARR_CFG_Config = Nimbus::PDS->new($LOGPDS)->asHash();
        print $CFG_Handler $ARR_CFG_Config[0]{'file_content'};
        close $CFG_Handler;
        return 1;
    }
    return 0;
}

1;
