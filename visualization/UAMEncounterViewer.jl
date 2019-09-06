"""
UAMEncounterViewer
Encounter viewer to visualize UAM encounters. This is meant to be used as
an interactive Julia notebook.
01/2019 S.M. Katz (smkatz@stanford.edu)
"""

# module UAMEncounterViewer

# You will need to install any of these packages that you do not have
using PGFPlots
using Interact
using Colors
using ColorBrewer
using Printf

# Add to latex preamble so we can use the aircraft shapes package
if !@isdefined sc_vert
	pushPGFPlotsPreamble("\\usepackage{aircraftshapes}")
end

# using UAMEncounterGenerator
include("../src/XrTypes.jl")
include("./UAMEncounterViewerFunctions.jl")

# end # module UAMEncounterViewer

