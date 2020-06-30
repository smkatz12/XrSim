using Reel
Reel.extension(m::MIME"image/svg+xml") = "svg"
Reel.set_output_type("gif") # may be necessary for use in IJulia

"""
-------------------------------------------
Constants
-------------------------------------------
"""

ra_1_tikz = "black"
ra_2_tikz = "{rgb,255:red,153; green,204; blue,255}" # light blue
ra_3_tikz = "{rgb,255:red,255; green,180; blue,180}" # light red
ra_4_tikz = "{rgb,255:red,255; green,91; blue,91}" # red
ra_5_tikz = "{rgb,255:red,190; green,0; blue,0}" # dark red

ras_tikz = [ra_1_tikz, ra_2_tikz, ra_3_tikz, ra_4_tikz, ra_5_tikz]

ra_1_speed_tikz = "black" # white
ra_2_speed_tikz = "{rgb,255:red,255; green,204; blue,153}" # light orange
ra_3_speed_tikz = "{rgb,255:red,153; green,255; blue,153}" # light green
ra_4_speed_tikz = "{rgb,255:red,255; green,128; blue,0}" # orange
ra_5_speed_tikz = "{rgb,255:red,0; green,153; blue,0}" # green

ras_speed_tikz = [ra_1_speed_tikz, ra_2_speed_tikz, ra_3_speed_tikz, ra_4_speed_tikz, ra_5_speed_tikz]

"""
-------------------------------------------
Actual functions
-------------------------------------------
"""

function plot_ground_track(τs::Vector{XR_TRAJECTORY}, times, t::Float64)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)

	# Initialize plot object
	a = Axis()

	a.axisEqual = true

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		push!(a, Plots.Linear(x[1:t_idx], y[1:t_idx], mark="none", style="black"))
        a.xlabel = "East (m)"
        a.ylabel = "North (m)"
        a.title = "Ground Track"
        a.width = "10cm"
        a.height = "8cm"
	end
	return a
end

function draw_AC_horizontal(times, τs::Vector{XR_TRAJECTORY}, t::Float64, a::Axis, intType::Symbol, actions::Vector{ACTION_SEQUENCE}; alert_type=:vert)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
    ras = alert_type == :vert ? ras_tikz : ras_speed_tikz
	# Next, loop through AC and draw them
	for i = 1:length(τs)
		# Get location of aircraft
		x = τs[i][t_idx].p[1]
		y = τs[i][t_idx].p[2]
		heading = rad2deg(τs[i][t_idx].h)
        action = actions[i][t_idx][end]
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_top(heading,x,y,ras[action+1],"black")))
		else
			push!(a, Plots.Command(get_UAM_string_top(heading,x,y,ras[action+1],"white")))
		end
	end
	return a
end

function plot_vertical_profile(times, τs::Vector{XR_TRAJECTORY}, t::Float64)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
	# Initialize the plot object
	a = Axis()

	# Iterate through aircraft and plot the trajectories
	for i = 1:length(τs)
		x, y, z = convert_to_xyz(τs[i])
		push!(a, Plots.Linear(times[1:t_idx], z[1:t_idx], mark="none", style="black"))
        a.xlabel = "Time (s)"
        a.ylabel = "Altitude (ft)"
        a.title = "Vertical Profile"
        a.width = "10cm"
        a.height = "8cm"
	end
	return a
end

function draw_AC_vertical(times, τs::Vector{XR_TRAJECTORY}, t::Float64, a::Axis, intType::Symbol, actions::Vector{ACTION_SEQUENCE};
    alert_type=:vert)
	# First, figure out index that the specified time corresponds to
	t_idx = findfirst(t .<= times)
    ras = alert_type == :speed ? ras_speed_tikz : ras_tikz
	# Next, loop through AC and draw them
	heading = 0
	for i = 1:length(τs)
		# Get location of aircraft
		x = times[t_idx]
		y = τs[i][t_idx].p[3]
		action = actions[i][t_idx][1]
		if i > 1 && intType == :quad
			push!(a, Plots.Command(get_quad_string_side(heading,x,y,ras[action+1],"black")))
		else
			push!(a, Plots.Command(get_UAM_string_side(heading,x,y,"white",ras[action+1])))
		end
	end
	return a
end

function plot_enc_to_time(sim_out::SIMULATION_OUTPUT, enc_ind::Int64, t::Float64,
							xmin, ymin, zmin, xmax, ymax, zmax;
							int_type::Symbol=:AC, alert_type::Symbol=:vert)
	τs = Vector{XR_TRAJECTORY}()
	push!(τs, sim_out.ac1_trajectories[enc_ind])
	push!(τs, sim_out.ac2_trajectories[enc_ind])

	actions = Vector{ACTION_SEQUENCE}()
	push!(actions, sim_out.ac1_actions[enc_ind])
	push!(actions, sim_out.ac2_actions[enc_ind])

	a_horiz = plot_ground_track(τs, sim_out.times, t)
	a_horiz = draw_AC_horizontal(sim_out.times, τs, t, a_horiz, int_type, actions, alert_type=alert_type)
	a_horiz.xmin = xmin - 20
    a_horiz.xmax = xmax + 20
    a_horiz.ymin = ymin - 20
    a_horiz.ymax = ymax + 20

	a_vert = plot_vertical_profile(sim_out.times, τs, t)
	a_vert = draw_AC_vertical(sim_out.times, τs, t, a_vert, int_type, actions, alert_type=alert_type)
	a_vert.ymin = zmin - 10
    a_vert.ymax = zmax + 10
    a_vert.xmin = 0.0
    a_vert.xmax = sim_out.times[end]

	g = GroupPlot(2,1,groupStyle="horizontal sep=2cm")
	push!(g, a_horiz)
	push!(g, a_vert)
	return g
end

function playback(sim_out::SIMULATION_OUTPUT, enc_ind::Int64; int_type=:AC, alert_type=:vert)
	frames = Frames(MIME("image/svg+xml"), fps=10)

	# Determine minimum and maximum x
	τs = Vector{XR_TRAJECTORY}()
	push!(τs, sim_out.ac1_trajectories[enc_ind])
	push!(τs, sim_out.ac2_trajectories[enc_ind])
	xmin = Inf
	ymin = Inf
	zmin = Inf
	xmax = -Inf
	ymax = -Inf
	zmax = -Inf
	for i = 1:length(τs)
		x = [τs[i][j].p[1] for j in 1:length(τs[i])]
		y = [τs[i][j].p[2] for j in 1:length(τs[i])]
		z = [τs[i][j].p[3] for j in 1:length(τs[i])]
		minimum(x) < xmin ? xmin = minimum(x) : nothing
		minimum(y) < ymin ? ymin = minimum(y) : nothing
		minimum(z) < zmin ? zmin = minimum(z) : nothing
		maximum(x) > xmax ? xmax = maximum(x) : nothing
		maximum(y) > ymax ? ymax = maximum(y) : nothing
		maximum(z) > zmax ? zmax = maximum(z) : nothing
	end

	for t in sim_out.times
		push!(frames, plot_enc_to_time(sim_out, enc_ind, t, xmin, ymin, zmin, xmax, ymax, zmax, int_type=int_type, alert_type=alert_type))
	end

	return frames
end

	