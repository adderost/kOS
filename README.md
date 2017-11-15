# kOS Launch and operations (KSP)

*A bunch of programs automating vessels in Kerbal Space Program.
All vessels comes preloaded with an OS from the /boot-folder*

## System files
* /boot
  - Contains OS-scripts that should be preloaded on the vessels. Should automatically download and execute vessel-specific operations from named folders
  - **OS1** is the first OS for vessels from the KSC.
    - Automatically handles radio-contact and provides functions for logging and transmitting data to KSC.
    - Automatically downloads vessel specific ops and executes them
    - Will keep state in memory and resume on reboot or power loss
    - Memory management: If memory is full tries to dump logs to free up memory
    - Because of limited memory, aggressively tries to send logs to KSC and delete local copies 
* /includes
  - Contains modules that can be loaded into the OS.
  - output.ks Provides methods to log to multiple files and transmitting these to KSC.
  - telemetry.ks Provides methods for the vessel to get detailed data about its current position

* /Vessels 
  - Contains ops and logs for specific vessels. These folders are the storage archives for the vessels.