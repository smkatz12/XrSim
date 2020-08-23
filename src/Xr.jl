"""
Xr.jl
- main file for ACAS Xr sim
"""

using LinearAlgebra
using Random
using Distributions
using Parameters
using GridInterpolations
using Mmap
import Base: copy

include("XrConst.jl")
include("XrTypes.jl")
include("XrCoordination.jl")
include("XrLogic.jl")
include("XrSim.jl")
include("XrInterface.jl")
include("XrSTM.jl")