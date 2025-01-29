How to run the sim. 

First if you are using ssh, to allow for a display make sure you do -X.
If you are using fast-x, ignore this.

Then you need to source modelsim with:

source /vol/eecs392/env/modelsim.env

Then launch the simulation with:

vsim -do timer_sim.do

Btw: If you want to just launch modelsim in the terminal, you can just type the following:

vsim -c -do motion_detect_sim.do

This isn't good if you want to see the waves, but it is helpful if you want to check if all your code complies.
You can exit the command line by just typing "exit"

