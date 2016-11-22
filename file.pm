use strict;
use warnings;
package perluim::file;

sub new {
    my ($class,$fileName) = @_;
    my $this = {
        fileName => $fileName,
        content => undef
    };
    return bless($this,ref($class) || $class);
}

sub load {
    my ($self) = @_;
    if(open(my $list, '<:encoding(UTF-8)',$self->{fileName})) {
        my @Rows = ();
        while(my $row = <$list>) {
            $row =~ s/^\s+|\s+$//g;
            push(@Rows,$row);
        }
        $self->{content} = @Rows;
        return 1,@Rows;
    }
    else {
        return 0,undef;
    }
}

sub loadString {
    my ($self) = @_;
    if(open(my $list, '<:encoding(UTF-8)',$self->{fileName})) {
        my $Str = "";
        while(my $row = <$list>) {
            $row =~ s/^\s+|\s+$//g;
            $Str .= $row;
        }
        return 1,$Str;
    }
    else {
        return 0,undef;
    }
}

sub save {
    my ($self,$output,$Array) = @_;
    if(defined($Array)) {
        my $file_handler;
        unless(open($file_handler,">", "$output")) {
            warn "Unabled to open rejected_files \n";
            return;
        }
        foreach(@{ $Array }) {
            print $file_handler "$_\n";
        }
        close $file_handler;
    }
    else {
        my $file_handler;
        unless(open($file_handler,">", "$output")) {
            warn "Unabled to open rejected_files \n";
            return;
        }
        foreach(@{ $self->{content} }) {
            print $file_handler "$_\n";
        }
        close $file_handler;
    }
}

1;
