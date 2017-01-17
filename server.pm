use strict;
use warnings;
package perluim::server;

# Nimsoft packages
use lib "D:/apps/Nimsoft/perllib";
use lib "D:/apps/Nimsoft/Perl64/lib/Win32API";
use Nimbus::API;
use Nimbus::CFG;
use Nimbus::PDS;

sub new {
    my ($class,$name,$version,$description) = @_;
    my $this = {
        sess => undef
    };
    my $blessed = bless($this,ref($class) || $class);
    my $sess = Nimbus::Session->new($name);
    $sess->setInfo($version,$description);


    if ($sess->server( NIMPORT_ANY , ref($blessed->timeout) , ref($blessed->restart) ) == 0 ) {
        print "server loaded!\n";
        $sess->dispatch();
    }
    else {
        print "server aborded!\n";
        exit(1);
    }

    $SIG{INT} = \$blessed->breakApplication;
    $blessed->{sess} = $sess;
    return $blessed;
}

sub dispatch {
    my ($self) = @_;
    $self->{sess}->dispatch();
}

sub timeout {
    my ($self) = @_;
    print "timeout\n";
}

sub restart {
    my ($self) = @_;
    print "restart\n";
}

sub breakApplication {
    print "application breaked with CTRL+C\n";
    exit;
}
1;
