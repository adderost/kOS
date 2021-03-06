# Hermes-series Communications satellites
*The second series of automatically launched spacecrafts from the KSC and the first series sporting the brand new OS, aptly named OS2.*

![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Vessels/Hermes/Hermes-launcher.png "Hermes Launch Vehicle")

## The Launch Vehicle
The Launch Vehicle is a slightly modified and modernized version of the Continuator launcher with greater range (the orbital stage could possibly bring a small payload on a roundtrip to the Mun).

### Changes from Continuator Launch Vehicle
  * The Hermes-series Launch Vehicle only has three solid fuel boosters in the first stage as opposed to the Continuator-series Launch Vehicle which had four.
  * Every stage on the Hermes-series Launch Vehicle is outfitted with auto-deploying parachutes in order to make the launcher completely recoverable from Low Kerbin Orbit.
  * The third stage, or the orbital stage, has exchanged the quite oversized LV-T30 Reliant LF-engine for the smaller, lighter, and weaker LV-909 Terrier LF-engine.
  * The boosters on the first stage has been outfitted with small retrorockets that will make sure the boosters separate cleanly from the second stage.
  * Since the whole Launch Vehicle is designed to be recoverable the per-launch cost will be lower than the cost listed in the table below.
  * Our engineers estimate that up to ~$6200 can be shaved off the per-launch cost if recovery of dropped stages is successful

### Comparisons between Continuator LV and Hermes LV
  | Comparison    | Continuator LV | Hermes LV   |
  | ------------- | --------------:| -----------:|
  | Total ΔV      | 4414 m/s       | 5245 m/s    |
  | Stage 1 ΔV    | 1145 m/s       | 952 m/s     |
  | Stage 2 ΔV    | 1782 m/s       | 1897 m/s    |
  | Stage 3 ΔV    | 1487 m/s       | 2396 m/s    |
  | Wet weight    | 25170 Kg       | 21809 Kg    |
  | Dry weight    | 6770 Kg        | 6221 Kg     |
  | Total cost    | $11607         | $12310      |

## The Payloads
*This section will be updated with information on the launched payloads as they are planned and completed*

### Hermes - Ena (Active)
*The first of five identical satellites designed to provide continuous communications coverage along the equator*

![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Vessels/Hermes/Ena/Hermes-Ena.png "Hermes - Ena satellite")

  * The goal of these satellites is to sit in an orbit between 250 and 300km with an orbital period of exactly 45 minutes. (Or as close to as is possible)
  * With a near perfect recovery of the first three stages we saved $6222 on the launch
  * An unknown bug in the software caused an error where the circulization routine couldn't enter its complete-state. Therefore it didn't automatically load the periodization routine.
  * A quick bugfix was issued and the OS was rebooted. However, cached files caused the system to get stuck in a reboot-loop
  * We remotely stopped OS2 and manually removed cached files, thus enabling the OS to reboot proper. A bug-report is issued to the OS2 developers and will hopefully be fixed before the next launch.
  * Hermes - Ena is now in a stable orbit with a period of 45 minutes, 0.02 seconds. 
  * Our ops-team is currently working on increasing the accuracy for our periodization routine to shave off those .02 seconds.
  * New ops were uploaded and executed. Hermes - Ena now has an orbital period of 45 minutes, 0.00 seconds.

### Hermes - Dio (Active)

![alt text](https://raw.githubusercontent.com/adderost/kOS/master/Vessels/Hermes/Dio/Hermes-Dio.png "Hermes - Dio satellite")

  * All launch stages were recovered successfully
  * We did not experience the circularization bug on this launch. Even though we didn't have time to update the software
  * Hermes - Dio is now in a stable orbit with a period of 45 minutes, 0 seconds. 
  * The periodisation routine used was the new one tested on Hermes - Ena a few weeks earlier