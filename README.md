# perluim
CA UIM perl object-oriented framework. This framework is used in 10+ probes for BNPP infrastructure.

> Warning : Think to update librairies path in each .pm file.

# Introduction 

```perl
use bnpp::main;
use bnpp::log;

my $Console = new bnpp::log("test_probe.log");
my $ScriptExecutionTime = time();
$Console->print("Execution start at ".localtime(),5);
$Console->setLevel(3);

$Console->print("Instanciating perluim framework!",3);
my $SDK = new bnpp::main("test_probe","PRODUCTION");
$SDK->setLog($Console);
$Console->print("Create output directory.");
my $Execution_Date = $SDK->getDate();
$SDK->createDirectory("output/$Execution_Date");
```

# Contribution welcome 

- Better UMP class (to do action on the REST API, and switch UMP if needed). 
- Update code syntax / algorithm.
- Add event system to each class (like event Emitter). 
- Rework getCfg from probe.pm
- Add new feature to probe.pm (like searching a key/section into a pds file).
- Support for subscribe probe ?

> Feel free to pull-request a new class etc...

# Roadmap 

- Rework better log.pm class
- Work on the documentation.
- Rework main class (better instanciating/configuration syntax).
