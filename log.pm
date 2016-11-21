package perluim::log;
use strict;
use warnings;
use File::Copy;

our %WarnState = (
	0 => "[CRITICAL]",
	1 => "[ERROR]   ",
	2 => "[WARNING] ",
	3 => "[INFO]    ",
	4 => "[DEBUG]   ",
	5 => "          "
);

sub new {
    my ($class,$logfile,$loglevel) = @_;
    my $this = {
		logfile => $logfile,
		loglevel => $loglevel || 3,
		fh => undef
    };
	open ($this->{fh},">","$logfile");
    my $blessed = bless($this,ref($class) || $class);
	$blessed->print("New console instance with path $logfile!");
	return $blessed;
}

sub setLevel {
	my ($self,$level) = @_;
	$self->{loglevel} = $level;
}

sub close {
	my ($self) = @_;
	close($self->{fh});
}

sub dateLog {
	my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
	my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $timetwoDigits = sprintf("%02d %02d:%02d:%02d",$mday,$hour,$min,$sec);
	return "$months[$mon] $timetwoDigits";
}

sub print {
	my ($self,$logmsg,$loglevel) = @_;
	if(not defined($loglevel)) {
		$loglevel = 3;
	}
	if($loglevel <= $self->{loglevel} || $loglevel == 5 || $loglevel == 4) {
		my $date = dateLog();
		my $filehandler = $self->{fh};
		print $filehandler "$date $WarnState{$loglevel} - $logmsg\n";
		print "$date $WarnState{$loglevel} - $logmsg\n";
	}
}

sub finalTime {
	my ($self,$timer) = @_;
	my $FINAL_TIME  = sprintf("%.2f", time() - $timer);
    my $Minute      = sprintf("%.2f", $FINAL_TIME / 60);
    $self->print("Final execution time = $FINAL_TIME second(s) [$Minute minutes]!");
}

sub copyTo {
	my ($self,$path) = @_;
	copy("$self->{logfile}","$path/$self->{logfile}") or warn "Failed to copy logfile!";
}

1;
