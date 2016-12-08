# perluim
CA UIM perl object-oriented framework.

> Warning : Think to update librairies path in each .pm file.

# Probes 

- Selfmonitoring - [Link](https://github.com/fraxken/selfmonitoring)
- Archive_cleaner - [Link](https://github.com/fraxken/archive_cleaner)
- Checkconfig - Not updated for this version of the framework.
- Alarms_management - [Link](https://github.com/fraxken/Alarms_management)
- Archive_inventory - Comming soon. 
- ump_management - Comming soon (Rework of UMP_ha 3.X). 

# Introduction 

```perl
use perluim::main;
use perluim::log;

my ($Console,$ScriptExecutionTime,$SDK,Execution_Date);

$Console = new perluim::log("test_probe.log");
$ScriptExecutionTime = time();
$Console->print("Execution start at ".localtime(),5);
$Console->setLevel(3);

$Console->print("Instanciating perluim framework!",3);
$SDK = new perluim::main("DOMAIN-PROD");
$SDK->setLog($Console);
$Console->print("Create output directory.");
$Execution_Date = $SDK->getDate();
$SDK->createDirectory("output/$Execution_Date");
```

### Get robots or hubs 
```perl
my ($RC,@Hubs) = $SDK->getArrayHubs();
if($RC == NIME_OK) {
    foreach my $hub (@Hubs) {
        # Hub is perluim:hub class
        my @Robots $hub->getArrayRobots();
    }
}


# Or if you need directly all robots 
my %Robots = $SDK->getAllRobots(); # Key = robotname, value = class robot
```

### Get archive packages from hubs 
```perl
my ($RC,@Hubs) = $SDK->getArrayHubs();
if($RC == NIME_OK) {
    foreach my $hub (@Hubs) {
        # Hub is perluim:hub class
        my $archive = $hub->archive();
        my ($RC,@Packages) = $archive->getPackages();
        if($RC == NIME_OK) {
            # Exploit packages class here!
            # Delete package ?
            foreach my $pkg (@Packages) {
                my $rc_deleted = $archive->deletePackage($pkg);
                if($rc_deleted == NIME_OK) {
                    $Console->print("$pkg->{name} successfully deleted from hub $hub->{name}");
                }
            }
        }
    }
}
```

# Features 

- Default structure (need to work on deamon)
- Actions on hubs/robots/probes/packages
- First step to work with UIM Rest (Need more work on this part..) 
- Better logs

# Contribution welcome 

- Better UMP class (to do action on the REST API, and switch UMP if needed, HTTP request etc..). 
- Map all supported probes as .PM class with all callbacks as method with clear arguments.

> Feel free to pull-request a new class etc...

# Roadmap 

- Continue to work on documentation.
- Rework methods to support nimNamedRequest or nimRequest (local or remote)
- Support level 1 for daemon probe.
