function xr_sim!(sim::SIMULATION; enc_inds=[])
	reset!(sim.sim_out)
	#i = 1
	# Load in the bin file to get dt, num_steps, and all of the encounters
	open(sim.enc_file, "r") do f
		dt = read(f, Float64)
		num_steps = read(f, Int64)
		# For each encounter
		while !eof(f)
			#println(i)
			#i += 1
			# Make an encounter out of info
			for ac in sim.acs
				reset!(ac)
				ac.curr_phys_state = read_phys_state(f)
				ac.ẍ = read_vector(f, num_steps)
				ac.ÿ = read_vector(f, num_steps)
				ac.z̈ = read_vector(f, num_steps)
				#@show ac.z̈
			end
			enc_out = initialize_encounter_output(sim.sim_out, sim.acs)
			enc = ENCOUNTER(sim.acs, dt, num_steps, enc_out)
			# Simulate the encounter
			simulate_encounter!(enc)
			update_output!(sim.sim_out, enc)
		end
		sim.sim_out.times = collect(range(0, step=dt, length=num_steps+1))
	end
end

function xr_sim!(sim::SIMULATION, enc_inds::Vector{Int64})
	reset!(sim.sim_out)
	ind = 1
	enc_ind = 1
	# Load in the bin file to get dt, num_steps, and all of the encounters
	open(sim.enc_file, "r") do f
		dt = read(f, Float64)
		num_steps = read(f, Int64)
		# For each encounter
		while !eof(f)
			# Make an encounter out of info
			for ac in sim.acs
				reset!(ac)
				ac.curr_phys_state = read_phys_state(f)
				ac.ẍ = read_vector(f, num_steps)
				ac.ÿ = read_vector(f, num_steps)
				ac.z̈ = read_vector(f, num_steps)
				#@show ac.z̈
			end
			if ind == enc_inds[enc_ind]
				enc_out = initialize_encounter_output(sim.sim_out, sim.acs)
				enc = ENCOUNTER(sim.acs, dt, num_steps, enc_out)
				# Simulate the encounter
				simulate_encounter!(enc)
				update_output!(sim.sim_out, enc)
				enc_ind += 1
				if enc_ind > length(enc_inds)
					break
				end
			end
			ind += 1
		end
		sim.sim_out.times = collect(range(0, step=dt, length=num_steps+1))
	end
end

function read_phys_state(f::IOStream)
	data = zeros(3,3)
	for i = 1:3
		for j = 1:3
			data[i,j] = read(f, Float64)
		end
	end
	return PHYSICAL_STATE(data[1,:], data[2,:], data[3,:])
end

function read_vector(f::IOStream, num_steps::Int64)
	data = zeros(num_steps)
	for i = 1:num_steps
		data[i] = read(f, Float64)
	end
	return data
end

# function initialize_encounter_output(sim_out::PAIRWISE_SIMULATION_OUTPUT, aircraft::Vector{AIRCRAFT})
# 	return PAIRWISE_ENCOUNTER_OUTPUT([aircraft[1].curr_phys_state], [aircraft[2].curr_phys_state], [COC], [COC])
# end

function initialize_encounter_output(sim_out::PAIRWISE_SIMULATION_OUTPUT, aircraft::Vector{AIRCRAFT})
	return pairwise_encounter_output()
end

function initialize_encounter_output(sim_out::SMALL_SIMULATION_OUTPUT, aircraft::Vector{AIRCRAFT})
	return pairwise_encounter_output()
end

function update_output!(sim_out::PAIRWISE_SIMULATION_OUTPUT, enc::ENCOUNTER)
	push!(sim_out.ac1_trajectories, enc.enc_out.ac1_trajectory)
	push!(sim_out.ac2_trajectories, enc.enc_out.ac2_trajectory)
	push!(sim_out.ac1_actions, enc.enc_out.ac1_actions)
	push!(sim_out.ac2_actions, enc.enc_out.ac2_actions)
end

function update_output!(sim_out::SMALL_SIMULATION_OUTPUT, enc::ENCOUNTER)
	is_nmac(enc.enc_out) ? sim_out.nmacs += 1 : nothing
	is_alert(enc.enc_out) ? sim_out.alerts += 1 : nothing
end

function is_nmac(enc_out::PAIRWISE_ENCOUNTER_OUTPUT)
	τ₀ = enc_out.ac1_trajectory
	τ₁ = enc_out.ac2_trajectory

	for i = 1:length(τ₀)
		h_sep = get_horiz_sep(τ₀[i], τ₁[i])
		v_sep = get_vert_sep(τ₀[i], τ₁[i])
		nmac = h_sep < 500ft2m && v_sep < 100ft2m
		if nmac
			return true
		end
	end
	return false
end

function get_horiz_sep(ps₀, ps₁)
	return sqrt((ps₀.p[1] - ps₁.p[1])^2 + (ps₀.p[2] - ps₁.p[2])^2)
end

function get_vert_sep(ps₀, ps₁)
	return abs(ps₀.p[3] - ps₁.p[3])
end

function is_alert(enc_out::PAIRWISE_ENCOUNTER_OUTPUT)
	alert₀ = any(enc_out.ac1_actions .> 0)
	alert₁ = any(enc_out.ac2_actions .> 0)
	return alert₀ || alert₁
end

function update_encounter_output!(enc_out::PAIRWISE_ENCOUNTER_OUTPUT, acs::Vector{AIRCRAFT})
	push!(enc_out.ac1_trajectory, acs[1].curr_phys_state)
	# println("Phys_state: $(acs[1].curr_phys_state)")
	# length(enc_out.ac1_trajectory) > 1 ? println("Output: $(enc_out.ac1_trajectory[end-1])") : nothing
	push!(enc_out.ac2_trajectory, acs[2].curr_phys_state)
	push!(enc_out.ac1_actions, acs[1].curr_action)
	push!(enc_out.ac2_actions, acs[2].curr_action)
end

# Currently, this does not support multithreat
function simulate_encounter!(enc::ENCOUNTER)
	update_encounter_output!(enc.enc_out, enc.aircraft)
	ac1 = enc.aircraft[1]
	ac2 = enc.aircraft[2]
	# Get initial state (physical and mdp) and set it to current state
	ac1.curr_mdp_state = get_mdp_state(ac1.curr_phys_state, ac2.curr_phys_state, ac1.curr_action)
	ac2.curr_mdp_state = get_mdp_state(ac2.curr_phys_state, ac1.curr_phys_state, ac2.curr_action)
	# println(ac1.curr_mdp_state)
	# println(ac2.curr_mdp_state)
	# Get encounter length
	# For each time step in the encounter
	for i = 1:enc.num_steps
		# For each aircraft in the encounter
		for ac in enc.aircraft
			action = select_action(ac)
			dynamics!(ac, action, enc.dt)
			#typeof(ac) == UAM_VERT ? println("alerted: $(ac.alerted)") : nothing
		end
		# get next mdp state - mdp_state(phys_state)
		ac1.curr_mdp_state = get_mdp_state(ac1.curr_phys_state, ac2.curr_phys_state, ac1.curr_action)
		ac2.curr_mdp_state = get_mdp_state(ac2.curr_phys_state, ac1.curr_phys_state, ac2.curr_action)
		update_encounter_output!(enc.enc_out, enc.aircraft)
	end
end

function get_mdp_state(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, pra::Int64)
	h = int_state.p[3] - own_state.p[3]
	ḣ₀ = own_state.v[3]
	ḣ₁ = int_state.v[3]

	# Figure out τ
	# Shift intruder to be relative to ownship at the origin
	p₁ = [int_state.p[1], int_state.p[2]]
	p₀ = [own_state.p[1], own_state.p[2]]
	p₁shift = p₁ - p₀
	# Rotate intuder velocity to be relative to ownship heading of zero degrees
	v₁ = [int_state.v[1], int_state.v[2]]
	v₀ = [own_state.v[1], own_state.v[2]]
	if any(v₁ .> 1e-8) && any(v₀ .> 1e-8)
		rot_ang = -atand(own_state.v[2], own_state.v[1])
		R = [cosd(rot_ang) -sind(rot_ang); sind(rot_ang) cosd(rot_ang)]
		v₁rot = R*v₁
		# Figure out when y-value is zero now
		τ = -p₁shift[2]/v₁rot[2]
	else
		τ = Inf
	end

	if τ < 0
		τ = Inf
	end

	return MDP_STATE(h, ḣ₀, ḣ₁, pra, τ)
end

function dynamics!(ac::AIRCRAFT, action::Int64, dt::Float64)		
	should_print = typeof(ac) == UAM_VERT && action > COC

	ac.curr_action = action
	curr_p = ac.curr_phys_state.p
	curr_v = ac.curr_phys_state.v
	curr_a = ac.curr_phys_state.a

	#any(curr_v .≥ 0) ? println(curr_v) : nothing

	action > COC ? ac.alerted = true : nothing

	if !ac.alerted # Follow flight path
		next_az = ac.z̈[ac.curr_step]
	else # Determine acceleration based on current ra
		# Sample an acceleration
		next_az = rand(acceleration_dist)
		vlow, vhigh = vel_ranges[action]
		#should_print ? println("curr_v: $(curr_v[3])") : nothing
		#println("curr_v: $(curr_v[3])")
		if (vlow ≥ curr_v[3]) .| (vhigh ≤ curr_v[3]) # Compliant velocity
        	next_az = 0
	    elseif vlow > curr_v[3] + next_az 
	        next_az = vlow - curr_v[3]
	    elseif vhigh < curr_v[3] + next_az
	        next_az = vhigh - curr_v[3]
	    end
	end
	#println("next_az: $next_az")
	#should_print ? println("next_az: $next_az") : nothing
    next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], next_az]
	next_p = curr_p + curr_v*dt + 0.5*next_a*dt^2
	next_v = curr_v + next_a*dt
	#should_print ? println("next_v: $next_v") : nothing

	ac.curr_phys_state = PHYSICAL_STATE(next_p, next_v, next_a)
	#should_print ? println(ac.curr_phys_state.v) : nothing
	ac.curr_step += 1
end

function reset!(ac::AIRCRAFT)
	ac.ẍ = Vector{Float64}()
	ac.ÿ = Vector{Float64}()
	ac.z̈ = Vector{Float64}()
	ac.curr_action = COC
	ac.curr_mdp_state = mdp_state()
	ac.curr_phys_state = physical_state()
	ac.alerted = false
	ac.curr_step = 1
end

function reset!(sim::SIMULATION)
	sim.sim_out = pairwise_simulation_output()
end

function convert_to_grid_state(s::MDP_STATE)
	return [s.h, s.ḣ₀, s.ḣ₁, s.a_prev, s.τ]
end