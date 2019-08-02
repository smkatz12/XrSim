"""
UAMEncounterViewerFunctions
Functions for UAMEncounterViewer
07/2019 (Fixing for new sim) S.M. Katz (smkatz@stanford.edu)
"""

"""
function plotGroundTrack
- plots the ground track of a particular encounter
"""
function plot_ground_track(τs::Vector{TRAJECTORY})
	# Initialize plot object
	a = Axis()

	a.axisEqual = true

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		push!(a, Plots.Linear(x, y, mark="none", style="black"))
        a.xlabel = "East (m)"
        a.ylabel = "North (m)"
        a.title = "Ground Track"
	end
	return a
end

function convert_to_xyz(τ::TRAJECTORY)
	x = [τ[i].p[1] for i = 1:length(τ)]
	y = [τ[i].p[2] for i = 1:length(τ)]
	z = [τ[i].p[3] for i = 1:length(τ)]
	return x, y, z
end

"""
function plotVerticalProfile
- plots the verical profile of a particular encounter
"""
function plot_vertical_profile(times, τs::Vector{TRAJECTORY})
	# Initialize the plot object
	a = Axis()

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		push!(a, Plots.Linear(times, z, mark="none", style="black"))
        a.xlabel = "Time (s)"
        a.ylabel = "Altitude (ft)"
        a.title = "Vertical Profile"
	end
	return a
end

"""
function getHorizRange
- returns the horizontal range at a particular time in the encounter
"""
function get_horiz_range(times, τs::Vector{TRAJECTORY}, t::Float64)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Get aircraft states
	x0 = τs[1][t_idx].p[1]
	x1 = τs[2][t_idx].p[1]
	y0 = τs[1][t_idx].p[2]
	y1 = τs[2][t_idx].p[2]
	return sqrt((x1-x0)^2+(y1-y0)^2)
end

"""
function getVertRange
- returns the vertical range at a particular time in the encounter
"""
function get_vert_range(times, τs::Vector{TRAJECTORY}, t::Float64)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Get aircraft states
	z0 = τs[1][t_idx].p[3]
	z1 = τs[2][t_idx].p[3]
	return abs(z1-z0)
end

"""
function getACStringTop
	- returns a string to draw an aircraft shape from top view
	Inputs:
	- heading: heading of the aircraft ccw from the +x axis
	- x: x-position of the aircraft
	- y: y-position of the aircraft
	- fill: color of the aircraft
	- draw: border color of the aircraft
	- width: size of icon
	Outputs:
	- String to be used with PGFPlots command function
"""
function get_AC_string_top(heading,x,y,fill,draw,width=1.5)
    return "\\node[aircraft top,fill="*fill*",draw="*draw*", minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.30] at (axis cs:"*string(x)*", "*string(y)*") {};"
end

"""
function getACStringSide
	- returns a string to draw an aircraft shape from a side view
	Inputs:
	- heading: heading of the aircraft ccw from the +x axis
	- x: x-position of the aircraft
	- y: y-position of the aircraft
	- fill: color of the aircraft
	- draw: border color of the aircraft
	- width: size of icon
	Outputs:
	- String to be used with PGFPlots command function
"""
function get_AC_string_side(heading,x,y,fill,draw,width=1.5)
    return "\\node[aircraft side,fill="*fill*",draw="*draw*", minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.3] at (axis cs:"*string(x)*", "*string(y)*") {};"
end

"""
function getQuadStringTop
	- returns a string to draw a quadcopter shape from top view
	Inputs:
	- heading: heading of the quadcopter ccw from the +x axis
	- x: x-position of the quadcopter
	- y: y-position of the quadcopter
	- fill: color of the quadcopter
	- draw: border color of the quadcopter
	- width: size of icon
	Outputs:
	- String to be used with PGFPlots command function
"""
function get_quad_string_top(heading,x,y,fill,draw,width=1.5)
    return "\\node[quadcopter top,fill="*fill*",draw="*draw*",minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.5] at (axis cs:"*string(x)*", "*string(y)*") {};"
end

"""
function getQuadStringSide
	- returns a string to draw a quadcopter shape from side view
	Inputs:
	- heading: heading of the quadcopter ccw from the +x axis
	- x: x-position of the quadcopter
	- y: y-position of the quadcopter
	- fill: color of the quadcopter
	- draw: border color of the quadcopter
	- width: size of icon
	Outputs:
	- String to be used with PGFPlots command function
"""
function get_quad_string_side(heading,x,y,fill,draw,width=1.5)
    return "\\node[quadcopter side,fill="*fill*",draw="*draw*",minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.5] at (axis cs:"*string(x)*", "*string(y)*") {};"
end

"""
function drawACHorizontal
	- draws aircraft shape at the locations of the aircraft at a particular 
	time in the encounter with the correct heading (looking from above)
	Inputs: 
	- enc: encounter currently being plotted
	- t: time to draw aircraft
	- a: axis object to add the shapes to
	- intType: type of intruder (right now supports :AC and :quad)
"""
function draw_AC_horizontal(times, τs::Vector{TRAJECTORY}, t::Float64, a::Axis, intType::Symbol)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Next, loop through AC and draw them
	for i = 1:length(τs)
		# Get location of aircraft
		x = τs[i][t_idx].p[1]
		y = τs[i][t_idx].p[2]
		ẋ = τs[i][t_idx].v[1]
		ẏ = τs[i][t_idx].v[2]
		heading = atand(ẏ, ẋ) # Check if degrees is correct!!!!
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_top(heading,x,y,"black","black")))
		else
			push!(a, Plots.Command(get_AC_string_top(heading,x,y,"black","white")))
		end
	end
	return a
end

"""
function drawACVertical
	- draws aircraft shape at the locations of the aircraft at a particular 
	time in the encounter with the correct heading (looking from the side)
	Inputs: 
	- enc: encounter currently being plotted
	- t: time to draw aircraft
	- a: axis object to add the shapes to
	- intType: type of intruder (right now supports :AC and :quad)
"""
function draw_AC_vertical(times, τs::Vector{TRAJECTORY}, t::Float64, a::Axis, intType::Symbol)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Next, loop through AC and draw them
	heading = 0
	for i = 1:length(τs)
		# Get location of aircraft
		x = times[t_idx]
		y = τs[i][t_idx].p[3]
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_side(heading,x,y,"black","black")))
		else
			push!(a, Plots.Command(get_AC_string_side(heading,x,y,"black","white")))
		end
	end
	return a
end

"""
function getHorizInfoPlot
	- returns a plot that will update with info about the current state
"""
function get_horiz_info_plot(times, τs::Vector{TRAJECTORY}, t::Float64)
	horizString = @sprintf("Horizontal Range: %.4g", get_horiz_range(times, τs, t))
	f = (x,y)->1
	a = Axis([Plots.Image(f, (-2,2), (-2,2), colormap=ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]), colorbar=false),
		Plots.Node(horizString,0,-0.82)], hideAxis =true, width="10 cm", height="2cm")
	return a
end

"""
function getVertInfoPlot
	- returns a plot that will update with info about the current state
"""
function get_vert_info_plot(times, τs::Vector{TRAJECTORY}, t::Float64)
	vertString = @sprintf("Vertical Range: %.4g", get_vert_range(times, τs, t))
	f = (x,y)->1
	a = Axis([Plots.Image(f, (-2,2), (-2,2), colormap=ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]), colorbar=false),
		Plots.Node(vertString,0,-0.82)], hideAxis=true, width="10 cm", height="2cm")
	return a
end

function add_RAs_horiz(τs::Vector{TRAJECTORY}, actions::Vector{ACTION_SEQUENCE}, a::Axis)
	for i = 1:length(τs)
		x, y, ni = convert_to_xyz(τs[i])
		z = [ra_dict[actions[i][j]] for j = 1:length(actions[i])]
		push!(a, Plots.Scatter(x, y, z, scatterClasses=sc))
	end
	return a
end

function add_RAs_vertical(times, τs::Vector{TRAJECTORY}, actions::Vector{ACTION_SEQUENCE}, a::Axis)
	for i = 1:length(τs)
		x, y, ni = convert_to_xyz(τs[i])
		z = [ra_dict[actions[i][j]] for j = 1:length(actions[i])]
		push!(a, Plots.Scatter(times, ni, z, scatterClasses=sc))
	end
	return a
end

"""
function encounter_viewer
	- function that actually creates the interactive encounter viewer
	Inputs:
	- encs: array of encounters
"""
function encounter_viewer(sim_out::SIMULATION_OUTPUT; int_type::Symbol=:AC)
	currSavePlot = 0

	@manipulate for fileName in textbox(value="myFile.pdf",label="File Name") |> onchange,
	savePlot in button("Save Plot"),
		enc in spinbox(1:length(sim_out.ac1_trajectories)),
		# making assumption that all input encounters are the same length (can change later)
		t in slider(0:1:sim_out.times[end], value=0)

		enc_ind = convert(Int64, enc)
		τs = Vector{TRAJECTORY}()
		push!(τs, sim_out.ac1_trajectories[enc_ind])
		push!(τs, sim_out.ac2_trajectories[enc_ind])

		actions = Vector{ACTION_SEQUENCE}()
		push!(actions, sim_out.ac1_actions[enc_ind])
		push!(actions, sim_out.ac2_actions[enc_ind])

		a_horiz = plot_ground_track(τs)
		a_horiz = draw_AC_horizontal(sim_out.times, τs, t, a_horiz, int_type)
		a_horiz = add_RAs_horiz(τs, actions, a_horiz)
		a_vert = plot_vertical_profile(sim_out.times, τs)
		a_vert = draw_AC_vertical(sim_out.times, τs, t, a_vert, int_type)
		a_vert = add_RAs_vertical(sim_out.times, τs, actions, a_vert)
		a_horiz_info = get_horiz_info_plot(sim_out.times, τs, t)
		a_vert_info = get_vert_info_plot(sim_out.times, τs, t)
		g = GroupPlot(2,2,groupStyle = "horizontal sep=2cm, vertical sep=2cm")
		push!(g, a_horiz_info)
		push!(g, a_vert_info)
		push!(g, a_horiz)
		push!(g, a_vert)

		if savePlot > currSavePlot
			currSavePlot = savePlot
			g2 = GroupPlot(2,1,groupStyle = "horizontal sep=2cm")
			push!(g2,a_horiz)
			push!(g2,a_vert)
			PGFPlots.save(fileName, g2)
		end

		return g
	end
end