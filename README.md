# Beagle-Boom
Beagle Boom is a Eurorack Sampler based on the Beaglebone single-board computer.
It was build as part of a project for the Creative Technologies AG (CTAG) of the University of Applied Sciences Kiel.
The project's aim is to provide an easy to use sampler which has access to the freesound.org sound database. The key features are:

- Search, download, save and play any freesound sample
- Use MIDI and CV / gate keyboards
- Multiscreen System: In addition to the build in LCD display, any browser can be used as a second screen and keyboard input.
- Modular architecture: every component communicates over a message queue and can be replaced if wished.
- Browser based UI: The interface is browser based and can be styled by your liking.

## I want to see it!
[![CTAG Beagle Boom](https://img.youtube.com/vi/ARSwFIjIRGI/0.jpg)](https://www.youtube.com/watch?v=ARSwFIjIRGI)
## Overview
The BeagleBoom consists of a shield for the Beaglebone and several programs handling sound generation, displaying graphics, reading cv, gate, button and rotary values.
### Hardware
To meet the strict size limitations of eurorack modules (and for cheap PCBs) we devided the circuit board into two stacked ones. The lower one contains the power supply, adc + level shifter (for gate/cv). The upper shields holds the buttons, rotaries and the lcd, as well as the needed resistors and capacitators.

The kicad project can be found at [https://github.com/BeagleBoom/Snouts](https://github.com/BeagleBoom/Snouts)
### Software
#### General
This rebo holds the installation script (`install.sh`) needed to setup your Beaglebone. We assume an [https://beagleboard.org/latest-images](debian-based image). The documentation for the single applications resides in their own repositories.
#### Message Queue
Each application comunicates over POSIX MessageQueues. The MessageQueue repository holds a C++ library which is used to send events with arbitrary parameters to predefined recipients.
Repo: [https://github.com/BeagleBoom/BeagleQueue](https://github.com/BeagleBoom/BeagleQueue)
#### ADC Manager
The BeagleBoom allows for the usage of a CV/Gate Keyboard. The ADC Manager is used to transform the readings of the adc chip into events with notes and keypresses. The software makes use of the PRU of the beaglebone, to lower the load on the main CPU.
Repo: [https://github.com/BeagleBoom/ADCManager](https://github.com/BeagleBoom/ADCManager)
#### Inputs
This application is used to transform button presses and rotary encoder rotations into events.
Repo: [https://github.com/BeagleBoom/Inputs](https://github.com/BeagleBoom/Inputs)

#### Beagle Audio
BeagleAudio is used to play an audio file in different pitches based on incomming events.
Repo: [https://github.com/BeagleBoom/BeagleAudio](https://github.com/BeagleBoom/BeagleAudio)
#### Menu
The Menu is a state based application which is used to couple UI events with actions. It also produces the html and events used for displaying information.
Repo: [https://github.com/BeagleBoom/Menu](https://github.com/BeagleBoom/Menu)
#### Device Portal
The API of freesound.org uses OAuth to authorize its requests. The DevicePortal works as a bridge between BeagleBoom and the freesound API.
Repo: [https://github.com/BeagleBoom/DevicePortal](https://github.com/BeagleBoom/DevicePortal)
