package perluim::alarmstask;

# Nimsoft librairies !
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

sub new {
    my ($class,$hash) = @_;
    my $this = {
        message => $hash->{"message"},
        severity => $hash->{"severity"} || 1,
        token => $hash->{"token"},
        subsystem => $hash->{"subsystem"}
    };
    return bless($this,ref($class) || $class);
}

sub call {
    my ($self,$message) = @_;
    print "call alarms !\n";
    my $final_msg = $message || $self->{message};
    my ($rc,$alarmid) = nimAlarm($self->{severity},$final_msg,$self->{subsystem},$self->{token});
    return $rc,$alarmid;
}


package perluim::alarmsmanager;

use Data::Dumper;

sub new {
    my ($class,$CFG) = @_;
    my %Alarms = ();
    foreach my $key (keys %{$CFG}) {
        my %SubHash = (
            message => %{$CFG}->{$key}->{"message"},
            token => %{$CFG}->{$key}->{"i18n_token"},
            severity => %{$CFG}->{$key}->{"severity"},
            subsystem => %{$CFG}->{$key}->{"subsystem"}
        );
        $Alarms{$key} = new perluim::alarmstask(\%SubHash);
    }
    my $this = {
        alarms => \%Alarms
    };
    return bless($this,ref($class) || $class);
}

sub call {
    my ($self,$alarmName,$msg) = @_;
    if( defined($self->{alarms}->{$alarmName}) ) {
        return $self->{alarms}->{$alarmName}->call($msg);
    }
    return 1,undef;
}

sub get {
    my ($self,$alarmName) = @_;
    if( defined($self->{alarms}->{$alarmName}) ) {
        return $self->{alarms}->{$alarmName};
    }
    return undef;
}


1;
