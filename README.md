# perluim
CA UIM perl object-oriented framework. This framework is used in 10+ probes for BNPP infrastructure.

> Warning : Think to update librairies path in each .pm file.

**!!A big cleanup of all framework methods is in progress.!!**

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
$SDK = new perluim::main("test_probe","PRODUCTION");
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
        my ($RC,@Packages) = $hub->getArchivePackages();
        if($RC == NIME_OK) {
            # Exploit packages class here!
            # Delete package ?
            my $rc_deleted = $hub->deletePackage('name','version');
        }
    }
}
```

# Contribution welcome 

- Better UMP class (to do action on the REST API, and switch UMP if needed, HTTP request etc..). 
- Add event system to each class (like event Emitter). 
- Rework getCfg from probe.pm
- Add new feature to probe.pm (like searching a key/section into a pds file).
- Support for subscribe probe ?

> Feel free to pull-request a new class etc...

# Roadmap 

- Continue to work on documentation.
- Add probeExist to robot API.
- Add getCfg(probeName,path) to robot API.
- Add getLog(probeName,path) to robot API.
- Rework main class (better instanciating/configuration syntax).
