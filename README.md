# Perluim
CA UIM perl object-oriented framework.

This framework has been created to help developer to work with the Perl SDK of CA UIM. It bring to you a default OO structure with a lot of callbacks with generic and useful methods.

# Documentation

Find the [Starter guide](https://github.com/fraxken/perluim/wiki/Starter-guide) if you need to start working with the framework. All API documentation are under the wiki section of github.

# Probes 

- Archive_cleaner   - [Link](https://github.com/fraxken/archive_cleaner)
- Alarms_management - [Link](https://github.com/fraxken/Alarms_management)
- Archive_inventory - [Link](https://github.com/fraxken/archive_inventory)
- ump_management    - [Link](https://github.com/fraxken/ump_management) (Rework of UMP_ha 3). 
- Keyreplacer - [Link](https://github.com/fraxken/keyreplacer)
- Robots_checker    - [Link](https://github.com/fraxken/robots_checker/tree/master)
- Selfmonitoring    - [Link](https://github.com/fraxken/selfmonitoring)

> **Warning** Some probes have to be updated for the latest releases of this framework.

# Features 

- Default probe structure.
- Map of generic callbacks for hubs/robots/probes/packages
- First step to work with UIM Rest (Need more work on this part..) 
- Better logs
- Better alarms management (Alarmsmanager, filemap, utils::generateAlarms)

> Feel free to pull-request new features.

# Roadmap r4.2

- Refactor log.pm constructor (double constructor with Hash params) 
- Add missing .pm class from documentation.
