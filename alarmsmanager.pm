package perluim::alarmstask;

# Nimsoft librairies !
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

use Data::Dumper;

sub new {
    my ($class,$name,$arr) = @_;
    my $this = {
        name => $name,
        message => @$arr[0],
        severity => @$arr[2] || 1,
        token => @$arr[1] || undef,
        subsystem => @$arr[3] || "1."
    };
    return bless($this,ref($class) || $class);
}

sub call {
    my ($self,$hashRef) = @_;
    my $CopyMsg = $self->{message};
    my @matches = ( $CopyMsg =~ /\$([A-Za-z0-9]+)/g );
    foreach (@matches) {
        if(exists($hashRef->{"$_"})) {
            $self->{message} =~ s/\$\Q$_/$hashRef->{$_}/g;
        }
    }
    my ($rc,$alarmid) = nimAlarm($self->{severity},$final_msg,$self->{subsystem});
    return $rc,$alarmid;
}


package perluim::alarmsmanager;

use Data::Dumper;

sub new {
    my ($class,$CFG,$section) = @_;
    my %Alarms = ();
    foreach my $key (keys $CFG->{"$section"}) {
        my @Arr = (
            $CFG->{"$section"}->{$key}->{"message"},
            $CFG->{"$section"}->{$key}->{"i18n_token"},
            $CFG->{"$section"}->{$key}->{"severity"},
            $CFG->{"$section"}->{$key}->{"subsystem"}
        );
        $Alarms{$key} = new perluim::alarmstask($key,\@Arr);
    }
    my $this = {
        alarms => \%Alarms
    };
    return bless($this,ref($class) || $class);
}

sub call {
    my $self = shift;
    my $alarmName = shift;
    my $hash = shift;
    if( defined($self->{alarms}->{$alarmName}) ) {
        return $self->{alarms}->{$alarmName}->call($hash);
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
