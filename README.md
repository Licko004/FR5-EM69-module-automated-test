# DEMONSTRATION OF EM69 MODULE TESTING USING FR5 COBOT  

## Introduction
This repository contains .lua code and necessary 3D step files to setup a FR5 cobot so that it can preform a demonstration of an automated EM69 module test. The said modules are electrical socket 1M modules, that contain a USB-A and USB-C charging port. The said ports are what is being tested.

## Assembly of robots gripper and electrical connections
### Mechanical
To assemble the robots gripper, please use an FDM 3D printer and PETG filament to print the next files: INCLUDE FILE NAMES WITH LINK

To assemble the robot gripper SCREW SIZES, STEPS

DESKA DXF!

### Electrical
MAKE A DIAGRAM OF ELECTRICAL CONNECTIONS INSIDE THE VACUUM GRIPPER! INCLUDE MAIN BOARD VERSION AND V-UNIT VERSION AND LEDRING VERSION!

### Software
FLASH MAIN BOARD WITH ARM_MOD --> INCLUDE THIS IN REPO AND ADD LINK HERE

## Automated test steps and whole setup
The setup included 3 trays. Two stacked on top of eachother and one alone. They were placed to the right and left of the robot. For easier program we refered to the stacked trays as TRAY1, either TRAY1_TOP or TRAY1_BTM (bottom) and the third tray was TRAY2_BTM.
For better visualisation of the setup, you can look at the photo below of the test setup. 

![Test setup](https://github.com/Licko004/FR5-EM69-module-automated-test/blob/main/photos/setup-marked.png)

### Steps of the step


## Main program setup
Connect the robot through an ethernet connection to your PC/teach pendant.
For connection instructions refer to [fairino documentation](https://fairino-doc-en.readthedocs.io/latest/index.html).

When your robot is connected and you can enter the WEB UI at 192.168.58.2 (username: admin, password: 123). Firstly upload the desired program, which you wish to run localy on the robot controller, you can upload lua scripts in the PROGRAM -> CODING.

Once your program is uploaded, got to APPLICATION -> Tool App. In the Tool App tag, choose Main program  and follow instruction there.
To run the main program you need to trigger a designated CI, which is a digital input that supports special functions, such as switching modes (AUTO/MANUAL) and starting the main program. To trigger this CI of your choice, connect a switch to the robot controller, you can find the connection diagram [here](https://fairino-doc-en.readthedocs.io/latest/CobotsManual/installation.html).

## Additional documentation
[Fairino manual for lua](https://fairino-doc-en.readthedocs.io/latest/LuaProgram/lua_intro.html)
[Fairino docs](https://fairino-doc-en.readthedocs.io/latest/index.html)