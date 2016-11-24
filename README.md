# perluim
CA UIM perl object-oriented framework. This framework is used in 10+ probes for BNPP infrastructure.

> Warning : Think to update librairies path in each .pm file.

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
        my ($RC,@Packages) = $hub->archive()->getPackages();
        if($RC == NIME_OK) {
            # Exploit packages class here!
            # Delete package ?
            my $rc_deleted = $hub->deletePackage('name','version');
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
- Support for daemon probe (not really supported by main right now...)

> Feel free to pull-request a new class etc...

# Roadmap 

- Continue to work on documentation.
- Rework main class (better instanciating/configuration syntax).
