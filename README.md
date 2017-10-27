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

* /<ship-name>
  - Contains ops and logs for specific vessels. These folders are the storage archives for the vessels.

## Continuator MK2-Series
*The first series of computer controlled space probes. With limited batteries and data-storage these probes are prone to reboot and lose logs. When in orbit the probes acts as orbital communications relays, allowing for temporary coverage of greater areas along the equator.*

![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Continuator%20Mk2/Continuator-MK2-launcher.png "Continuator MK2 Launch Vehicle")

* ### Continuator MK2
  - First automated vessel launched from KSC and the first vessel to return from a stable orbit. Splashed down and sank to the bottom of the ocean after two completed orbits.
  - On completed orbital insertion it continued to ping it's altitude every 60s
  - Ran out of electricity on the night-side of the planet, hence incomplete logs.
  - Ran out of onboard memory before reestablishing radio contact with KSC, hence incomplete logs.
  ![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Continuator%20Mk2/Continuator-MK2.png "Continuator MK2")
* ### Continuator MK2 B
  - Currently orbiting at approx 120km. Working as a comms relay satellite. Ready to recieve new ops
  - Intermittently loses electrical power on dark side of planet, incufficient batteries on board.
  - Used the same launch profile as the MK2.
  - Ops completed when orbital insertion was verified.
  - Onboard scientific apparatus: Geiger counter.
  ![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Continuator%20Mk2%20B/Continuator-MK2-B.png "Continuator MK2 B")
 * ### Continuator MK2 C
  - Currently orbiting at approx 120km. Working as a comms relay satellite. Ready to recieve new ops
  - Virtually identical to MK2 B.
  - Intermittently loses electrical power on dark side of planet, incufficient batteries on board.
  - Used the same launch profile as the MK2 and MK2 B.
  - Ops completed when orbital insertion was verified.
  - Initially didn't start relaying comms signals. Fixed after manual reboot.
  - Onboard scientific apparatus: Thermometer.
  ![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Continuator%20Mk2%20C/Continuator-MK2-C.png "Continuator MK2 C")
