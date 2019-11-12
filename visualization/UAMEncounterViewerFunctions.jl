"""
UAMEncounterViewerFunctions
Functions for UAMEncounterViewer
07/2019 (Fixing for new sim) S.M. Katz (smkatz@stanford.edu)
"""

"""
-------------------------------------------
Constants
-------------------------------------------
"""
#sc = ["ra_1={mark=none},ra_2={mark=o,blue},ra_3={mark=o,red},ra_4={mark=halfcircle*,red},ra_5={mark=*,red}"]
ra_dict = Dict(0=>"ra_1", 1=>"ra_2", 2=>"ra_3", 3=>"ra_4", 4=>"ra_5")
ra_dict_speed = Dict(0=>"ra_1_speed", 1=>"ra_2_speed", 2=>"ra_3_speed", 3=>"ra_4_speed", 4=>"ra_5_speed")

# Vertical ##################################################################
ra_1 = RGB(1.0,1.0,1.0) # white
ra_2 = RGB(153.0/255.0,204.0/255.0,255.0/255.0) # light blue
ra_3 = RGB(255.0/255.0,180.0/255.0,180.0/255.0) # light red
ra_4 = RGB(255.0/255.0,91.0/255.0,91.0/255.0) # red
ra_5 = RGB(190.0/255.0,0.0/255.0,0.0/255.0) # dark red

colors = [ra_1;ra_2;ra_3;ra_4;ra_5]

# Create scatter plot classes for color key
sc_string = "{"
for i=1:5
    define_color("ra_$i",  colors[i])
    if i==1
        global sc_string *= "ra_$i={mark=square, style={black, mark options={fill=ra_$i}, mark size=6}},"
    else
        global sc_string *= "ra_$i={style={ra_$i, mark size=6}},"
    end
end

# Color key as a scatter plot
sc_string=sc_string[1:end-1]*"}"
xx = [-0.8, -0.8, -0.8, -0.8, -0.8]
yy = [1.65, 1.15, 0.65, 0.15, -0.35]
zz = ["ra_1","ra_2","ra_3","ra_4","ra_5"]
sc_vert_key = string(sc_string)

# Create scatter plot classes for on plot markers
sc_string = "{"
for i=1:5
    if i==1
        global sc_string *= "ra_$i={mark=none},"
    else
        global sc_string *= "ra_$i={mark=*, style={ra_$i, mark size=1}},"
    end
end
sc_string=sc_string[1:end-1]*"}"
sc_vert = string(sc_string)

# Speed ##################################################################
ra_1_speed = RGB(1.0,1.0,1.0) # white
ra_2_speed = RGB(255.0/255.0,204.0/255.0,153.0/255.0) # light orange
ra_3_speed = RGB(153.0/255.0,255.0/255.0,153.0/255.0) # light green
ra_4_speed = RGB(255.0/255.0,128.0/255.0,0.0/255.0) # orange
ra_5_speed = RGB(0.0/255.0,153.0/255.0,0.0/255.0) # green

colors = [ra_1_speed;ra_2_speed;ra_3_speed;ra_4_speed;ra_5_speed]

# Create scatter plot classes for color key
sc_string = "{"
for i=1:5
    define_color("ra_$(i)_speed",  colors[i])
    if i==1
        global sc_string *= "ra_$i={mark=square, style={black, mark options={fill=ra_$(i)_speed}, mark size=6}},"
    else
        global sc_string *= "ra_$i={style={ra_$(i)_speed, mark size=6}},"
    end
end

# Color key as a scatter plot
sc_string=sc_string[1:end-1]*"}"
sc_speed_key = string(sc_string)

# Create scatter plot classes for on plot markers
sc_string = "{"
for i=1:5
    if i==1
        global sc_string *= "ra_$i={mark=none},"
    else
        global sc_string *= "ra_$i={mark=*, style={ra_$(i)_speed, mark size=1}},"
    end
end
sc_string=sc_string[1:end-1]*"}"
sc_speed = string(sc_string)

"""
-------------------------------------------
Actual functions
-------------------------------------------
"""

"""
function plotGroundTrack
- plots the ground track of a particular encounter
"""
function plot_ground_track(τs::Vector{XR_TRAJECTORY})
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
        a.width = "10cm"
        a.height = "8cm"
	end
	return a
end

function plot_side_track(τs::Vector{XR_TRAJECTORY})
	# Initialize plot object
	a = Axis()

	#a.axisEqual = true

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		dist = get_distances(τs[i])
		push!(a, Plots.Linear(dist, z, mark="none", style="black"))
        a.xlabel = "Distance (m)"
        a.ylabel = "Altitude (ft)"
        a.title = "Vertical Profile"
	end
	return a
end

function convert_to_xyz(τ::XR_TRAJECTORY)
	x = [τ[i].p[1] for i = 1:length(τ)]
	y = [τ[i].p[2] for i = 1:length(τ)]
	z = [τ[i].p[3] for i = 1:length(τ)]
	return x, y, z
end

function convert_to_vxyz(τ::XR_TRAJECTORY)
	vx = [τ[i].v[1] for i = 1:length(τ)]
	vy = [τ[i].v[2] for i = 1:length(τ)]
	vz = [τ[i].v[3] for i = 1:length(τ)]
	return vx, vy, vz
end

function get_distances(τ)
	vx, vy, vz = convert_to_vxyz(τ)
	d = [0.0]
	for i = 2:length(τ)
		push!(d, d[i-1] + norm([vx[i-1], vy[i-1]]))
	end
	return d
end

"""
function plotVerticalProfile
- plots the verical profile of a particular encounter
"""
function plot_vertical_profile(times, τs::Vector{XR_TRAJECTORY})
	# Initialize the plot object
	a = Axis()

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		push!(a, Plots.Linear(times, z, mark="none", style="black"))
        a.xlabel = "Time (s)"
        a.ylabel = "Altitude (ft)"
        a.title = "Vertical Profile"
        a.width = "10cm"
        a.height = "8cm"
	end
	return a
end

"""
function getHorizRange
- returns the horizontal range at a particular time in the encounter
"""
function get_horiz_range(times, τs::Vector{XR_TRAJECTORY}, t::Float64)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Get aircraft states
	x0 = τs[1][t_idx].p[1]
	x1 = τs[2][t_idx].p[1]
	y0 = τs[1][t_idx].p[2]
	y1 = τs[2][t_idx].p[2]
	return sqrt((x1-x0)^2+(y1-y0)^2)*3.28084
end

"""
function getVertRange
- returns the vertical range at a particular time in the encounter
"""
function get_vert_range(times, τs::Vector{XR_TRAJECTORY}, t::Float64)
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

function get_UAM_string_top(heading,x,y,fill,draw,width=1.5)
    return "\\node[UAM top,fill="*fill*",draw="*draw*", minimum width="*string(width)*"cm,rotate="*string(heading-90)*",scale = 0.15] at (axis cs:"*string(x)*", "*string(y)*") {};"
end

function get_UAM_string_side(heading,x,y,fill,draw,width=1.5)
    return "\\node[UAM side,fill="*fill*",draw="*draw*", minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.5] at (axis cs:"*string(x)*", "*string(y)*") {};"
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
    return "\\node[quadcopter top,fill="*fill*",draw="*draw*",minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.15] at (axis cs:"*string(x)*", "*string(y)*") {};"
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
    return "\\node[quadcopter side,fill="*fill*",draw="*draw*",minimum width="*string(width)*"cm,rotate="*string(heading)*",scale = 0.2] at (axis cs:"*string(x)*", "*string(y)*") {};"
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
function draw_AC_horizontal(times, τs::Vector{XR_TRAJECTORY}, t::Float64, a::Axis, intType::Symbol)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Next, loop through AC and draw them
	for i = 1:length(τs)
		# Get location of aircraft
		x = τs[i][t_idx].p[1]
		y = τs[i][t_idx].p[2]
		# ẋ = τs[i][t_idx].v[1]
		# ẏ = τs[i][t_idx].v[2]
		# heading = atand(ẏ, ẋ) # Check if degrees is correct!!!!
		heading = rad2deg(τs[i][t_idx].h)
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_top(heading,x,y,"black","black")))
		elseif i == 1
			push!(a, Plots.Command(get_UAM_string_top(heading,x,y,"black","white")))
		else
			push!(a, Plots.Command(get_UAM_string_top(heading,x,y,"black","white")))
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
function draw_AC_vertical(times, τs::Vector{XR_TRAJECTORY}, t::Float64, a::Axis, intType::Symbol)
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
		elseif i == 1
			push!(a, Plots.Command(get_UAM_string_side(heading,x,y,"white","black")))
		else
			push!(a, Plots.Command(get_UAM_string_side(heading,x,y,"white","black")))
		end
	end
	return a
end

function draw_AC_side(times, τs::Vector{XR_TRAJECTORY}, t::Float64, a::Axis, intType::Symbol)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Next, loop through AC and draw them
	heading = 0
	for i = 1:length(τs)
		xs, ys, zs = convert_to_xyz(τs[i])
		dist = get_distances(τs[i])
		# Get location of aircraft
		x = dist[t_idx]
		y = zs[t_idx]
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_side(heading,x,y,"black","white")))
		elseif i == 1
			push!(a, Plots.Command(get_AC_string_side(heading,x,y,"teal","white")))
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
function get_horiz_info_plot(times, τs::Vector{XR_TRAJECTORY}, t::Float64)
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
function get_vert_info_plot(times, τs::Vector{XR_TRAJECTORY}, t::Float64)
	vertString = @sprintf("Vertical Range: %.4g", get_vert_range(times, τs, t))
	f = (x,y)->1
	a = Axis([Plots.Image(f, (-2,2), (-2,2), colormap=ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]), colorbar=false),
		Plots.Node(vertString,0,-0.82)], hideAxis=true, width="10 cm", height="2cm")
	return a
end

function add_RAs_horiz(τs::Vector{XR_TRAJECTORY}, actions::Vector{ACTION_SEQUENCE}, a::Axis, sc)
	for i = 1:length(τs)
		x, y, ni = convert_to_xyz(τs[i])
        if length(actions[i][1]) < 2
            z = [ra_dict[actions[i][j]] for j = 1:length(actions[i])]
        else
            z = [ra_dict[actions[i][j][2]] for j = 1:length(actions[i])]
        end
		push!(a, Plots.Scatter(x, y, z, scatterClasses=sc))
	end
	return a
end

function add_RAs_vertical(times, τs::Vector{XR_TRAJECTORY}, actions::Vector{ACTION_SEQUENCE}, a::Axis, sc)
	for i = 1:length(τs)
		x, y, ni = convert_to_xyz(τs[i])
		if length(actions[i][1]) < 2
            z = [ra_dict[actions[i][j]] for j = 1:length(actions[i])]
        else
            z = [ra_dict[actions[i][j][1]] for j = 1:length(actions[i])]
        end
		push!(a, Plots.Scatter(times, ni, z, scatterClasses=sc))
	end
	return a
end

function add_RAs_side(times, τs::Vector{XR_TRAJECTORY}, actions::Vector{ACTION_SEQUENCE}, a::Axis)
	for i = 1:length(τs)
		x, y, ni = convert_to_xyz(τs[i])
		dist = get_distances(τs[i])
		z = [ra_dict[actions[i][j]] for j = 1:length(actions[i])]
		push!(a, Plots.Scatter(dist, ni, z, scatterClasses=sc))
	end
	return a
end

function get_key_vert()
	f = (x,y)->1
	return Axis([
                Plots.Image(f, (-2,2), (-2,2),colormap = ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]),colorbar=false),
                Plots.Scatter(xx, yy, zz, scatterClasses=sc_vert_key),
                Plots.Node("RA 1: COC ",0.38,0.915,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 2: DNC ",0.38,0.790,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 3: DND",0.38,0.665,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 4: CL250",0.38,0.540,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 5: SCL450 ",0.38,0.415,style="black,anchor=west", axis="axis description cs"),
                ],width="6cm",height="8cm", hideAxis =true, title="KEY")
end

function get_key_speed()
	f = (x,y)->1
	return Axis([
                Plots.Image(f, (-2,2), (-2,2),colormap = ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]),colorbar=false),
                Plots.Scatter(xx, yy, zz, scatterClasses=sc_speed_key),
                Plots.Node("RA 1: COC ",0.38,0.915,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 2: WD ",0.38,0.790,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 3: WA ",0.38,0.665,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 4: SD ",0.38,0.540,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 5: SA ",0.38,0.415,style="black,anchor=west", axis="axis description cs"),
                ],width="6cm",height="8cm", hideAxis =true, title="KEY")
end

function get_filler()
	f = (x,y)->1
	return Axis(Plots.Image(f, (-2,2), (-2,2), colormap=ColorMaps.RGBArrayMap([RGB(1.0,1.0,1.0)]), colorbar=false),
		hideAxis=true, width="6cm", height="2cm")
end

"""
function encounter_viewer
	- function that actually creates the interactive encounter viewer
	Inputs:
	- encs: array of encounters
"""
function encounter_viewer(sim_out::SIMULATION_OUTPUT; int_type::Symbol=:AC, alert_type::Symbol=:vert)
	currSavePlot = 0

	@manipulate for fileName in textbox(value="myFile.pdf",label="File Name") |> onchange,
		savePlot in button("Save Plot"),
		enc in spinbox(1:length(sim_out.ac1_trajectories)),
		# making assumption that all input encounters are the same length (can change later)
		t in slider(0:1:sim_out.times[end], value=0)

		enc_ind = convert(Int64, enc)
		τs = Vector{XR_TRAJECTORY}()
		push!(τs, sim_out.ac1_trajectories[enc_ind])
		push!(τs, sim_out.ac2_trajectories[enc_ind])

		actions = Vector{ACTION_SEQUENCE}()
		push!(actions, sim_out.ac1_actions[enc_ind])
		push!(actions, sim_out.ac2_actions[enc_ind])

		sc_horizontal = alert_type == :vert ? sc_vert : sc_speed
        sc_vertical = alert_type == :speed ? sc_speed : sc_vert

		a_horiz = plot_ground_track(τs)
		a_horiz = draw_AC_horizontal(sim_out.times, τs, t, a_horiz, int_type)
		a_horiz = add_RAs_horiz(τs, actions, a_horiz, sc_horizontal)
		a_vert = plot_vertical_profile(sim_out.times, τs)
		a_vert = draw_AC_vertical(sim_out.times, τs, t, a_vert, int_type)
		a_vert = add_RAs_vertical(sim_out.times, τs, actions, a_vert, sc_vertical)
		# a_vert = plot_side_track(τs)
		# a_vert = draw_AC_side(sim_out.times, τs, t, a_vert, int_type)
		# a_vert = add_RAs_side(sim_out.times, τs, actions, a_vert)
		a_horiz_info = get_horiz_info_plot(sim_out.times, τs, t)
		a_vert_info = get_vert_info_plot(sim_out.times, τs, t)
		g = GroupPlot(3,2,groupStyle = "horizontal sep=2cm, vertical sep=2cm")
		push!(g, a_horiz_info)
		push!(g, a_vert_info)
		push!(g, get_filler())
		push!(g, a_horiz)
		push!(g, a_vert)
		alert_type == :vert ? push!(g, get_key_vert()) : push!(g, get_key_speed())

		if savePlot > currSavePlot
			currSavePlot = savePlot
			g2 = GroupPlot(3,1,groupStyle = "horizontal sep=2cm")
			push!(g2, a_horiz)
			push!(g2, a_vert)
			alert_type == :vert ? push!(g2, get_key_vert()) : push!(g2, get_key_speed())
			PGFPlots.save(fileName, g2)
		end

		return g
	end
end