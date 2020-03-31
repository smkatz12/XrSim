# XrSim

Repository for simulating encounters between Urban Air Mobility (UAM) vehicles and other vehicles they may encounter in the airspace in order to test collision avoidance logic. The functions in this repository are designed to simulate an encounter file that is can be created using the `UAMEncounterGen` repository.

## Quick Start Guide
In order to simulate encounters, ensure that the following packages are installed in your current version of Julia: `LinearAlgebra`, `Random`, `Distributions`, `GridInterpolations`, and `Mmap`. For the visualization, you will also need `PGFPlots`, `Interact`, `Colors`, `ColorBrewer`, and `Printf`. This code was created and tested using Julia 1.1.

The following lines will generate an encounter file titled "test.bin" containing five encounters with a UAM vehicle as the ownship and a commercial sUAS as the intruder.

```
include("UAMEncounterGen.jl")
enc = uam_suas()
num_encs = 5
filename = "test.bin"
generate_encounter_file_bin(enc, num_encs, filename)
```

Possible encounter types are `uam_uam()`, `uam_hd()`, `uam_suas()`, and `uam_manned()` which have a UAM vehicle as the ownship and intruders of a UAM vehicle, hobby drone, small unmanned aircraft system (sUAS), and manned aircraft respectively.

## Type Descriptions
`SAMPLER` - abstract type of which specific encounter samplers are subtypes. A sampler contains the distributions of random variables associated with a particular encounter type (e.g. vertical miss distance, time of closest point of approach, etc.)

`ENCOUNTER` - abstract type of which specific encounters such as `UAM_UAM` and `UAM_HD` are subtypes. All encounter types contain a corresponding sampler, a time step, total time, two trajectories, and a place to store each variable in the sampler. 

`TRAJECTORY` - contains position (`p`), velocity (`v`), and acceleration (`a`) for an entire trajectory. Each row is the x, y, and z values of the variable at a particular time step with time increasing with the rows.

## Key Functions
`sample_features!(enc::ENCOUNTER)` - replaces feature values in the encounter by sampling new values according to the distributions specified in the sampler.

`generate_encounter!(enc::ENCOUNTER)` - runs `sample_features!(enc)` on the encounter and uses the sampled features to generate the trajectories of the encounter. When this function is called, the trajectories in the encounter object will be replaced with the newly generated encounter trajectories. 

If you want to hold any features constant during the encounter, you will need to add a line after `sample_features!(enc)` gets called. For example, if you know you want a vertical miss distance of 100 feet, using the following lines of code to generate the encounter:

```
sample_features!(enc)
enc.vmd = 100
get_trajectories!(enc)
```

## UAMTrajectoryGen
The `UAMTrajectoryGen` subdirectory contains functions for generating various UAM trajectory types. It is set up very similar to the UAM encounter generator. The following lines of code will generate a UAM vertical descent landing trajectory:

```
τ = vertical_descent()
generate_trajectory!(τ)
```

The `generate_trajectory!(τ::UAM_TRAJECTORY)` function works very similar to `generate_encounter!(enc::ENCOUNTER)`. It first runs `sample_features!(τ)` on the trajectory and uses to sampled features to constrain a convex optimization problem. The `solve_trajectory!(τ::UAM_TRAJECTORY)` function then solves the convex problem replaces the `p` and `v` fields of the trajectory object with the position and velocity respectively at each time step in the trajectory.

## File Descriptions
`UAMEncounterGenerator.jl` - Main file to include for UAM encounter generation that sets up constants and types; includes all necessary files, and defines general functions for all types of encounters.

`UAM_HD.jl` - defines functions and types for encounters with a UAM ownship and hobby drone intruder.

`UAM_manned.jl` - defines functions and types for encounters with a UAM ownship and manned intruder.

`UAM_sUAS.jl` - defines functions and types for encounters with a UAM ownship and a sUAS intruder.

`UAM_UAM.jl` - defines functions and types for encounters with a UAM ownship and a UAM intruder.

`data_files/mode_c_veil_waypoints_filtered.bin` - data file containing waypoints for manned aircraft trajectories filtered for low altitudes from Mode C Veil data

`data_files/sUAS_waypoints.bin` - data file containing waypoints for sUAS trajectories (based on Weinert et al. and Deaton).

`HDTrajectoryGen/CreateHobbyDroneTrajectories.jl` - functions for creating hobby drone trajectories using dynamic Bayesian networks (based on code and work of Mueller).

`HDTrajectoryGen/HobbyDroneInterface.jl` - functions to allow hobby drone trajectory generator to interface with the rest of the encounter generator.

`HDTrajectoryGen/iBN_data.jld2` - contains data (parameters, structure) for the initial hobby drone Bayesian network.

`HDTrajectoryGen/tBN_data.jld2` - contains data (parameters, structure) for the transition hobby drone Bayesian network.

`MannedTrajectoryGen/MannedTrajectoryInterpolator.jl` - functions to read and interpolate manned trajectories from the data file.

`sUASTrajectoryGen/sUASTrajectoryInterpoltor.jl` - functions to read and interpolate sUAS trajectories from the data file.

`UAMTrajectoryGen/UAMTrajectoryGenerator.jl` - main file for generation of UAM trajectories; includes all necessary files, and defines general functions for all types of UAM trajectories.

`UAMTrajectoryGen/HighReconaissance.jl` - defines functions and types for high reconaissance trajectories.

`UAMTrajectoryGen/Nominal Landing.jl` - defines optimization problem and types for nominal landing trajectories.

`UAMTrajectoryGen/NominalTakeoff.jl` - defines optimization problem and types for nominal takeoff trajectories.

`UAMTrajectoryGen/VerticalAscent.jl` - defines optimization problem and types for vertical ascent takeoff trajectories.

`UAMTrajectoryGen/VerticalDescent.jl` - defines optimization problem and types for vertical descent landing trajectories.

## Setup of Encounter Files
Encounter files are set of as follows:
```
dt (encounter 1)
num_steps 
ownship initial x position
ownship initial y position
ownship initial z position
ownship initial x velocity
ownship initial y velocity
ownship initial z velocity
ownship initial x acceleration
ownship initial y acceleration
ownship initial z acceleration
ownship x acceleration for first time step
ownship x acceleration for second time step
...
ownship x acceleration for num_steps time step
ownship y acceleration for first time step
ownship y acceleration for second time step
...
ownship y acceleration for num_steps time step
ownship z acceleration for first time step
ownship z acceleration for second time step
...
ownship z acceleration for num_steps time step
intruder initial x position
intruder initial y position
intruder initial z position
intruder initial x velocity
intruder initial y velocity
intruder initial z velocity
intruder initial x acceleration
intruder initial y acceleration
intruder initial z acceleration
intruder x acceleration for first time step
intruder x acceleration for second time step
...
intruder x acceleration for num_steps time step
intruder y acceleration for first time step
intruder y acceleration for second time step
...
intruder y acceleration for num_steps time step
intruder z acceleration for first time step
intruder z acceleration for second time step
...
intruder z acceleration for num_steps time step
dt (encounter 2)
num_steps
ownship initial x position
...
```