"""
Xr.jl
- main file for ACAS Xr sim
"""

using Distributions
using GridInterpolations
using Mmap
import Base: copy

include("XrConst.jl")
include("XrTypes.jl")
include("XrSim.jl")
include("XrInterface.jl")