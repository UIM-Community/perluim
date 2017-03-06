package perluim::logger;
use strict;
use warnings;
use File::Copy;
use File::stat;
use File::Path 'rmtree';
use IO::Handle;

our %loglevel_label = (
	0 => "[CRITICAL]",
	1 => "[ERROR]   ",
	2 => "[WARNING] ",
	3 => "[INFO]    ",
	4 => "[DEBUG]   ",
	5 => "          ",
	6 => "[SUCCESS] "
);

use constant {
	NimFATAL => 0,
	NimERROR => 1,
	NimWARN  => 2,
	NimINFO	 => 3,
	NimDEBUG => 4,
	NimEmpty => 5,
	NimSUCCESS => 6
};

sub new {
    my ($class,$hashRef) = @_;
    my $this = {
		logfile => $hashRef->{file},
		loglevel => $hashRef->{level} || 3,
		logsize => $hashRef->{size} || 0,
		logrewrite => $hashRef->{overwrite} || 'yes',
		_time => time(),
		_fh => undef
    };
    my $blessed = bless($this,ref($class) || $class);
	my $rV = $blessed->{logrewrite} eq "yes" ? ">" : ">>";
	if($blessed->{logsize} != 0) {
		my $fileSize = (stat $blessed->{logfile})[7];
		if($fileSize >= $blessed->{logsize}) {
			copy("$blessed->{logfile}","_$blessed->{logfile}") or warn "Failed to copy logfile!";
			$rV = ">";
		}
	}
	open ($this->{_fh},"$rV","$hashRef->{file}");
	$blessed->log(5,"New console class created with logfile as => $hashRef->{file}!");
	return $blessed;
}

sub setLevel {
	my ($self,$level) = @_;
	$self->{loglevel} = $level || 5;
}

sub truncate {
	my ($self) = @_;
	if($self->{logsize} != 0) {
		my $fileSize = (stat $self->{logfile})[7];
		if($fileSize >= $self->{logsize}) {
			copy("$self->{logfile}","_$self->{logfile}") or warn "Failed to copy logfile!";
			close($self->{_fh});
			open ($self->{_fh},">","$self->{logfile}");
		}
	}
}

sub close {
	my ($self) = @_;
	close($self->{_fh});
}

sub getDate {
	my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
	my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $timetwoDigits = sprintf("%02d %02d:%02d:%02d",$mday,$hour,$min,$sec);
	return "$months[$mon] $timetwoDigits";
}

sub log {
	my ($self,$loglevel,$logmsg) = @_;
	if(not defined($loglevel)) {
		$loglevel = 3;
	}
	if($loglevel <= $self->{loglevel} || $loglevel == 5 || $loglevel == 4) {
		my $date = getDate();
		my $filehandler = $self->{_fh};
		print $filehandler "$date $loglevel_label{$loglevel} - $logmsg\n";
		print "$date $loglevel_label{$loglevel} - $logmsg\n";
		$filehandler->autoflush;
	}
}

sub cleanDirectory {
	my ($self,$directory,$maxAge) = @_;

	opendir(DIR,"$directory");
	my @directory = readdir(DIR);
	my @removeDirectory = ();
	foreach my $file (@directory) {
		next if ($file =~ m/^\./);
		my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$directory/$file");
		if(defined $ctime) {
			push(@removeDirectory,$file) if(time() - $ctime > $maxAge);
		}
	}

	foreach(@removeDirectory) {
		$self->log(2,"Remove old directory $directory => $_");
		rmtree("$directory/$_");
	}
}

sub finalTime {
	my ($self) = @_;
	my $FINAL_TIME  = sprintf("%.2f", time() - $self->{_time});
    my $Minute      = sprintf("%.2f", $FINAL_TIME / 60);
	$self->log(5,'---------------------------------------');
    $self->log(5,"Execution time = $FINAL_TIME second(s) [$Minute minutes]!");
	$self->log(5,'---------------------------------------');
}

sub copyTo {
	my ($self,$path) = @_;
	copy("$self->{logfile}","$path/$self->{logfile}") or warn "Failed to copy logfile!";
}

1;
