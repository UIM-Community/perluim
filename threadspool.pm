package perluim::threadspool;

use strict;
use warnings;
use threads;
use Thread::Queue;
use Data::Dumper;

sub new {
    my ($class,$cbRef,$threadsNumber,$maxRow) = @_;
    my $this = {
        cb => $cbRef,
        queue => Thread::Queue->new,
        count => $maxRow,
        threads => undef,
        done => 0
    };
    my $blessed = bless($this,ref($class) || $class);
    my @Threads = ();
    while($threadsNumber--) {
        my $thr = threads->new(sub {
            my $Element;
            while (not $blessed->{count} <= $blessed->{done} and $Element = $blessed->{queue}->dequeue) {
                my $res = $blessed->{cb}($Element);
                if($res eq "done") {
                    $blessed->{done}++;
                }
            }
        });
        push(@Threads,$thr);
    }
    $blessed->{threads} = \@Threads;
    return $blessed;
}

sub enqueue {
    my ($self,@elements) = @_;
    $self->{queue}->enqueue(@elements);
}

sub await {
    my ($self) = @_;
    foreach my $thr (@{$self->{threads}}) {
        $thr->join;
    }
}

sub stop {
    my ($self) = @_;
    foreach my $thr (@{$self->{threads}}) {
        $thr->detach;
    }
}

1;
