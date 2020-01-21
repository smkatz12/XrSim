# XrSim

Repository for simulating encounters in order to test various Urban Air Mobility (UAM) collision avoidance logics. Encounter files for this repository can be created using the `UAMEncounterGen` repository. 

## Quick Start Guide

Ensure that the following packages are installed in your current version of Julia: `LinearAlgebra`, `Random`, `Distributions`, `GridInterpolations`, and `Mmap`. This code was created and tested using Julia 1.1.

The following lines of code will simulate the encounters in the file `data_files/enc_file.bin` for an ownship equipped with Xr vertical logic (table located at `data_files/Xr_vertical.bin`) and an intruder that is unequipped.

```
sim = simulation()
sim.acs[1] = uam_vert(q_file = "../data_files/Xr_vertical.bin")
sim.enc_file = "data_files/enc_file.bin"
xr_sim!(sim)
```
The function `xr_sim!(sim::SIMULATION)` will modify the simulation output in the simulation object. For example, to access the trajectory of the ownship after running the lines above use:

```
sim.sim_out.ac1_trajectory
```