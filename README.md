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

To visualize the output of a simulation, you can use UAMEncounterViewer.jl in an interactive Jupyter session. See EncounterViewerNotebook for details. 

## Type Descriptions
`PHYSICAL_STATE` - contains a position, velocity, acceleration (all 3D), and heading. Horizontal values are in meters. Vertical values are in feet. Heading is in radians. NOTE: all horizontal values in the code (until right before looking up in table) are in meters and vertical values in feet. This should probably be changed in the future.

`OBSERVATION_STATE` - contains just a position and velocity observation

`MDP_STATE` - Abstract type of states to be looked up in tables (VERT_STATE, SPEED_STATE)

`BELIEF_STATE` - Contains a vector of MDP_STATEs and their corresponding probabilies. `probs` should be a vector that sums to 1

`KALMAN_FILTER` - Used by the tracking module to keep track of current position estimate mean and covariance

`TRACKER_HISTORY` - Contains the observations received throughout an encounter and the progression of the tracker estimate

`XR_TRAJECTORY` - Vector of physical states

`AIRCRAFT` - abstract type that allows for a distinction between collision avoidance logics and properties. Each type of logic (unequipped, heuristic, vertical, speed, blended) has a corresponding aircraft type. Aircraft are initialized at the beginning of an encounter to contain a vectors of nominal accelerations to follow if no collision avoidance actions are taken. Throughout an encounter, an aircraft's current states (observation, physical, and belief) are updated. Aircraft with MDP-based logics contain their Q tables.