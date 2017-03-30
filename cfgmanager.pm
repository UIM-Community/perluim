package perluim::cfgmanager;

use strict;
use warnings;
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

sub new {
    my ($class,$filePath,$readOnly) = @_;
    my $cfg = cfgOpen($filePath,$readOnly || 0);
    my $this = {
        _closed => 0,
        _inner => $cfg,
        readyOnly => $readOnly || 0
    };
    return bless($this,ref($class) || $class);
}

sub has {
    my ($self,$section,$key) = @_;
    my $value = cfgKeyRead($self->{_inner},$section,$key || "");
    return defined $value ? 1 : 0; 
}

sub read {
    my ($self,$section,$key) = @_;
    my $value = cfgKeyRead($self->{_inner},$section,$key || "");
    return $value;
}

#
# Key management
# 
sub createKey {
    my ($self,$section,$key,$value) = @_; 
    cfgKeyWrite($self->{_inner},$section,$key,$value || "");
}

sub hashKeys {
    my ($self,$section,$hashRef) = @_;
    foreach my $key (keys $hashRef) {
        cfgKeyWrite($self->{_inner},$section,$key,$hashRef->{$key} || "");
    }
}

sub arrayKeys {
    my ($self,$section,$arrayRef) = @_;
    foreach my $key ($arrayRef) {
        cfgKeyWrite($self->{_inner},$section,$key,@$arrayRef[$key] || "");
    }
}
 
sub deleteKey {
    my ($self,$section,$key) = @_;
    cfgKeyDelete($self->{_inner},$section,$key);
}

sub listKeys {
    my ($self,$section) = @_;
    my ($arr) = cfgKeyList($self->{_inner},$section);
    return $arr;
}

#
# Section management
#
sub createSection {
    my ($self,$sectionPath) = @_;
    cfgKeyWrite($self->{_inner},$sectionPath,"key","value");
    cfgKeyDelete($self->{_inner},$sectionPath,"key");
}

sub deleteSection {
    my ($self,$section) = @_;
    cfgSectionDelete($self->{_inner},$section);
}

sub copySection {
    my ($self,$from,$to) = @_; 
    cfgSectionCopy($self->{_inner},$from,$to);
}

sub listSections {
    my ($self,$section) = @_;
    my ($arr) = cfgSectionList($self->{_inner},$section);
    return $arr;
}

sub save {
    my ($self) = @_;
    cfgSync($self->{_inner});
}

sub open {
    my ($self,$path,$readOnly) = @_;
    if($self->{_closed} == 0) {
        $self->save();
        $self->close();
    }
    $self->{_inner}  = cfgOpen($path,$readOnly || $self->{readOnly});
    $self->{_closed} = 0;
}

sub close {
    my ($self) = @_;
    cfgClose($self->{_inner});
    $self->{_closed} = 1;
}

1;
