"""
Xr.jl
- main file for ACAS Xr sim
"""

using LinearAlgebra
using Random
using Distributions
using GridInterpolations
using Mmap
import Base: copy

include("XrConst.jl")
include("XrTypes.jl")
include("XrLogic.jl")
include("XrSim.jl")
include("XrInterface.jl")