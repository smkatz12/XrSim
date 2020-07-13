function xr_sim!(sim::SIMULATION; verbose=false)
	reset!(sim.sim_out)
	# Load in the bin file to get dt, num_steps, and all of the encounters
	open(sim.enc_file, "r") do f
		dt = read(f, Float64)
		num_steps = read(f, Int64)
		# For each encounter
		while !eof(f)
			sim.curr_enc += 1
			Random.seed!(sim.curr_enc)
			# Make an encounter out of info
			for ac in sim.acs
				reset!(ac)
				ac.curr_phys_state = read_phys_state(f)
				ac.ẍ = read_vector(f, num_steps)
				ac.ÿ = read_vector(f, num_steps)
				ac.z̈ = read_vector(f, num_steps)
			end
			enc_out = initialize_encounter_output(sim.sim_out, sim.acs)
			enc = XR_ENCOUNTER(sim.acs, dt, num_steps, enc_out)
			# Simulate the encounter
			simulate_encounter!(enc, verbose=verbose, surveillance_on=sim.surveillance_on)
			update_output!(sim, sim.sim_out, enc)
		end
		sim.sim_out.times = collect(range(0, step=dt, length=num_steps+1))
	end
end

function xr_sim!(sim::SIMULATION, enc_inds::Vector{Int64}; verbose=false)
	reset!(sim.sim_out)
	enc_ind = 1
	# Load in the bin file to get dt, num_steps, and all of the encounters
	open(sim.enc_file, "r") do f
		dt = read(f, Float64)
		num_steps = read(f, Int64)
		# For each encounter
		while !eof(f)
			sim.curr_enc += 1
			Random.seed!(sim.curr_enc)
			# Make an encounter out of info
			for ac in sim.acs
				reset!(ac)
				ac.curr_phys_state = read_phys_state(f)
				ac.ẍ = read_vector(f, num_steps)
				ac.ÿ = read_vector(f, num_steps)
				ac.z̈ = read_vector(f, num_steps)
			end
			if sim.curr_enc == enc_inds[enc_ind]
				enc_out = initialize_encounter_output(sim.sim_out, sim.acs)
				enc = XR_ENCOUNTER(sim.acs, dt, num_steps, enc_out)
				# Simulate the encounter
				simulate_encounter!(enc, verbose=verbose, surveillance_on=sim.surveillance_on)
				update_output!(sim, sim.sim_out, enc)
				enc_ind += 1
				if enc_ind > length(enc_inds)
					break
				end
			end
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
	heading = atan(data[2,2], data[2,1])
	return PHYSICAL_STATE(data[1,:], data[2,:], data[3,:], heading)
end

function read_vector(f::IOStream, num_steps::Int64)
	data = zeros(num_steps)
	for i = 1:num_steps
		data[i] = read(f, Float64)
	end
	return data
end

function initialize_encounter_output(sim_out::PAIRWISE_SIMULATION_OUTPUT, aircraft::Vector{AIRCRAFT})
	return pairwise_encounter_output()
end

function initialize_encounter_output(sim_out::SMALL_SIMULATION_OUTPUT, aircraft::Vector{AIRCRAFT})
	return pairwise_encounter_output()
end

function update_output!(sim::SIMULATION, sim_out::PAIRWISE_SIMULATION_OUTPUT, enc::XR_ENCOUNTER)
	push!(sim_out.ac1_trajectories, enc.enc_out.ac1_trajectory)
	push!(sim_out.ac2_trajectories, enc.enc_out.ac2_trajectory)
	push!(sim_out.ac1_actions, enc.enc_out.ac1_actions)
	push!(sim_out.ac2_actions, enc.enc_out.ac2_actions)
	push!(sim_out.ac1_tracker_hists, enc.enc_out.ac1_tracker_hist)
	push!(sim_out.ac2_tracker_hists, enc.enc_out.ac2_tracker_hist)
end

function update_output!(sim::SIMULATION, sim_out::SMALL_SIMULATION_OUTPUT, enc::XR_ENCOUNTER)
	if is_nmac(enc.enc_out) 
		sim_out.nmacs += 1
		push!(sim_out.nmac_inds, sim.curr_enc)
	end
	if is_alert(enc.enc_out)
		sim_out.alerts += 1
		push!(sim_out.alert_inds, sim.curr_enc)
	end
end

function is_nmac(enc_out::PAIRWISE_ENCOUNTER_OUTPUT)
	τ₀ = enc_out.ac1_trajectory
	τ₁ = enc_out.ac2_trajectory

	for i = 30:length(τ₀)
		h_sep = get_horiz_sep(τ₀[i], τ₁[i])
		v_sep = get_vert_sep(τ₀[i], τ₁[i])
		nmac = h_sep < 500ft2m && v_sep < 100 #ft2m
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
	if length(enc_out.ac1_actions[1]) > 1
		alert₀ = false
		alert₁ = false
		for i = 1:length(enc_out.ac1_actions)
			if any(enc_out.ac1_actions[i] .> 0)
				alert₀ = true
				break
			end
		end
		for i = 1:length(enc_out.ac2_actions)
			if any(enc_out.ac2_actions[i] .> 0)
				alert₁ = true
				break
			end
		end
	else
		alert₀ = any(enc_out.ac1_actions .> 0)
		alert₁ = any(enc_out.ac2_actions .> 0)
	end
	return alert₀ || alert₁
end

function update_encounter_output!(enc_out::PAIRWISE_ENCOUNTER_OUTPUT, acs::Vector{AIRCRAFT}; surveillance_on=false)
	push!(enc_out.ac1_trajectory, acs[1].curr_phys_state)
	push!(enc_out.ac2_trajectory, acs[2].curr_phys_state)
	push!(enc_out.ac1_actions, acs[1].curr_action)
	push!(enc_out.ac2_actions, acs[2].curr_action)
	if surveillance_on
		push!(enc_out.ac1_tracker_hist.observations, acs[1].curr_observation)
		push!(enc_out.ac1_tracker_hist.μb, acs[1].tracker.μb)
		push!(enc_out.ac1_tracker_hist.Σb, acs[1].tracker.Σb)
		push!(enc_out.ac2_tracker_hist.observations, acs[2].curr_observation)
		push!(enc_out.ac2_tracker_hist.μb, acs[2].tracker.μb)
		push!(enc_out.ac2_tracker_hist.Σb, acs[2].tracker.Σb)
	end
end

# Currently, this does not support multithreat
function simulate_encounter!(enc::XR_ENCOUNTER; verbose=false, surveillance_on=false)
	ac1 = enc.aircraft[1]
	ac2 = enc.aircraft[2]
	# Sample NACp for intruder
	ac2.NACp = rand(NACp_dist) + 7
	# Get initial state (physical and mdp) and set it to current state
	if surveillance_on && typeof(ac1) != HEURISTIC_VERT
		make_observation!(ac1)
		make_observation!(ac2)
		ac1.tracker = kalman_filter(μb=[ac1.curr_phys_state.p; ac1.curr_phys_state.v; ac2.curr_phys_state.p; ac2.curr_phys_state.v])
		ac2.tracker = kalman_filter(μb=[ac2.curr_phys_state.p; ac2.curr_phys_state.v; ac1.curr_phys_state.p; ac1.curr_phys_state.v])
		update_belief!(ac1, ac2, enc.dt)
	else
		ac1.curr_belief_state = get_belief_state(ac1, ac2, enc.dt)
		ac2.curr_belief_state = get_belief_state(ac2, ac1, enc.dt)
	end
	update_encounter_output!(enc.enc_out, enc.aircraft, surveillance_on=surveillance_on)
	# Get encounter length
	# For each time step in the encounter
	for i = 1:enc.num_steps
		# For each aircraft in the encounter
		for ac in enc.aircraft
			action = select_action(ac)
			(verbose && typeof(ac) == UAM_BLENDED) ? println(action) : nothing
			dynamics!(ac, action, enc.dt)
		end
		if  surveillance_on
			make_observation!(ac1)
			make_observation!(ac2)
			update_belief!(ac1, ac2, enc.dt)
		else
			ac1.curr_belief_state = get_belief_state(ac1, ac2, enc.dt)
			ac2.curr_belief_state = get_belief_state(ac2, ac1, enc.dt)
		end
		# # get next mdp state - mdp_state(phys_state)
		# ac1.curr_belief_state = get_belief_state(ac1, ac2, enc.dt)
		# verbose ? println(ac1.curr_belief_state) : nothing
		# # println(ac1.curr_phys_state)
		# # println(ac2.curr_phys_state)
		# # println()
		# ac2.curr_belief_state = get_belief_state(ac2, ac1, enc.dt)
		update_encounter_output!(enc.enc_out, enc.aircraft, surveillance_on=surveillance_on)
	end
end

# Fully observable - vertical
function get_belief_state(ownship::Union{UNEQUIPPED, HEURISTIC_VERT, UAM_VERT}, intruder::AIRCRAFT, dt::Float64)
	return BELIEF_STATE([get_vert_state(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0])
end

# Fully observable - speed
function get_belief_state(ownship::UAM_SPEED, intruder::AIRCRAFT, dt::Float64)
	scale_factor = 0
	if ownship.perform_scaling
		own_speed = norm(ownship.curr_phys_state.v[1:2])
		int_speed = norm(intruder.curr_phys_state.v[1:2])
		scale_factor = max(own_speed / v₀max, int_speed / v₁max)
	end

	speed_state = get_speed_state(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)
	
	if scale_factor > 1
		speed_state.r /= scale_factor
		speed_state.v₀ /= scale_factor
		speed_state.v₁ /= scale_factor
	end

	return BELIEF_STATE([speed_state], [1.0])
end

function get_belief_state(ownship::UAM_SPEED_INTENT, intruder::AIRCRAFT, dt::Float64)
	return BELIEF_STATE([get_speed_state_intent(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0])
end

function get_belief_state(ownship::UAM_BLENDED, intruder::AIRCRAFT, dt::Float64)
	return [BELIEF_STATE([get_vert_state(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0]),
			BELIEF_STATE([get_speed_state(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0])]
end

function get_belief_state(ownship::UAM_BLENDED_INTENT, intruder::AIRCRAFT, dt::Float64)
	return [BELIEF_STATE([get_vert_state(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0]),
			BELIEF_STATE([get_speed_state_intent(ownship.curr_phys_state, intruder.curr_phys_state, ownship.curr_action, dt)], [1.0])]
end

# Partially observable (just τ for now)
function get_belief_state(ownship::UAM_VERT_PO, intruder::AIRCRAFT, dt::Float64)
	own_state = ownship.curr_phys_state
	int_state = intruder.curr_phys_state

	turns = [-8.0, 0.0, 8.0]
	turn_probs = [0.2, 0.6, 0.2]

	states = Vector{MDP_STATE}()
	probs = Vector{Float64}()

	for i = 1:length(turns)
		for j = 1:length(turns)
			push!(states, get_mdp_state_turn(own_state, int_state, turns[i], turns[j], ownship.curr_action, dt))
			push!(probs, turn_probs[i]*turn_probs[j])
		end
	end
	return BELIEF_STATE(states, probs)
end

function get_vert_state(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, a_prev::ACTION, dt::Float64)
	h = int_state.p[3] - own_state.p[3]
	ḣ₀ = own_state.v[3]
	ḣ₁ = int_state.v[3]

	# Figure out tau
	p₁ = [int_state.p[1], int_state.p[2]]
	p₀ = [own_state.p[1], own_state.p[2]]
	v₁ = [int_state.v[1], int_state.v[2]]
	v₀ = [own_state.v[1], own_state.v[2]]
	r = norm(p₁ - p₀)
	r_next = norm((p₁ + v₁*dt) - (p₀ + v₀*dt))
	ṙ = r - r_next
	τ = r < 500ft2m ? 0 : (r - 500ft2m)/ṙ

	if τ < 0
		τ = Inf
	end

	pra = length(a_prev) > 1 ? a_prev[1] : a_prev

	return VERT_STATE(h, ḣ₀, ḣ₁, pra, τ)
end

function get_vert_state(p_own::Vector, v_own::Vector, p_int::Vector, v_int::Vector, a_prev::ACTION, dt::Float64)
	h = p_int[3] - p_own[3]
	ḣ₀ = v_own[3]
	ḣ₁ = v_int[3]

	# Figure out tau
	p₁ = [p_int[1], p_int[2]]
	p₀ = [p_own[1], p_own[2]]
	v₁ = [v_int[1], v_int[2]]
	v₀ = [v_own[1], v_own[2]]
	r = norm(p₁ - p₀)
	r_next = norm((p₁ + v₁*dt) - (p₀ + v₀*dt))
	ṙ = r - r_next
	τ = r < 500ft2m ? 0 : (r - 500ft2m)/ṙ

	if τ < 0
		τ = Inf
	end

	pra = length(a_prev) > 1 ? a_prev[1] : a_prev

	return VERT_STATE(h, ḣ₀, ḣ₁, pra, τ)
end

# NOTE: I was dumb with units and I think I need to convert everything horizontal from m to ft
function get_speed_state(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, a_prev::ACTION, dt::Float64)
	p = (int_state.p[1:2] - own_state.p[1:2])*m2ft
	r = norm(p)

	# θv₀ = atan(own_state.v[2], own_state.v[1])
	# rot_mat = [cos(θv₀) -sin(θv₀); sin(θv₀) cos(θv₀)]

	rot_mat = [cos(own_state.h) -sin(own_state.h); sin(own_state.h) cos(own_state.h)]

	p_rot = rot_mat*p
	θ = atan(p_rot[2], p_rot[1])

	v₁_rot = rot_mat*int_state.v[1:2]
	ψ = atan(v₁_rot[2], v₁_rot[1])

	v₀ = norm(own_state.v[1:2])*mps2fps
	v₁ = norm(int_state.v[1:2])*mps2fps

	h = int_state.p[3] - own_state.p[3]
	ḣ = int_state.v[3] - own_state.v[3]
	h_subtract = h < 0 ? -100 : 100
	τ = abs(h) < 100.0 ? 0.0 : (h - h_subtract)/ḣ

	if τ ≤ 0.0
		τ = -τ
	else
		τ = Inf
	end

	# τ = h < 100.0 ? 0.0 : (h - 100.0)/ḣ

	# if τ < 0.0
	# 	τ = Inf
	# end

	pra = length(a_prev) > 1 ? a_prev[2] : a_prev

	return SPEED_STATE(r, θ, ψ, v₀, v₁, pra, τ)
end

# NOTE: I was dumb with units and I think I need to convert everything horizontal from m to ft
function get_speed_state(p_own::Vector, v_own::Vector, p_int::Vector, v_int::Vector, a_prev::ACTION, dt::Float64)
	p = (p_int[1:2] - p_own[1:2])*m2ft
	r = norm(p)

	# θv₀ = atan(own_state.v[2], own_state.v[1])
	# rot_mat = [cos(θv₀) -sin(θv₀); sin(θv₀) cos(θv₀)]
	heading = atan(v_own[2], v_own[1])
	rot_mat = [cos(heading) -sin(heading); sin(heading) cos(heading)]

	p_rot = rot_mat*p
	θ = atan(p_rot[2], p_rot[1])

	v₁_rot = rot_mat*v_int[1:2]
	ψ = atan(v₁_rot[2], v₁_rot[1])

	v₀ = norm(v_own[1:2])*mps2fps
	v₁ = norm(v_int[1:2])*mps2fps

	h = p_int[3] - p_own[3]
	ḣ = v_int[3] - v_own[3]
	h_subtract = h < 0 ? -100 : 100
	τ = abs(h) < 100.0 ? 0.0 : (h - h_subtract)/ḣ

	if τ ≤ 0.0
		τ = -τ
	else
		τ = Inf
	end

	# τ = h < 100.0 ? 0.0 : (h - 100.0)/ḣ

	# if τ < 0.0
	# 	τ = Inf
	# end

	pra = length(a_prev) > 1 ? a_prev[2] : a_prev

	return SPEED_STATE(r, θ, ψ, v₀, v₁, pra, τ)
end

# NOTE: I was dumb with units and I think I need to convert everything horizontal from m to ft
function get_speed_state_intent(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, a_prev::ACTION, dt::Float64)
	p = (int_state.p[1:2] - own_state.p[1:2])*m2ft
	r = norm(p)

	rot_mat = [cos(own_state.h) -sin(own_state.h); sin(own_state.h) cos(own_state.h)]

	p_rot = rot_mat*p
	θ = atan(p_rot[2], p_rot[1])

	v₁_rot = rot_mat*int_state.v[1:2]
	ψ = atan(v₁_rot[2], v₁_rot[1])

	v₀ = norm(own_state.v[1:2])*mps2fps
	v₁ = norm(int_state.v[1:2])*mps2fps

	h = int_state.p[3] - own_state.p[3]
	ḣ = int_state.v[3] - own_state.v[3]
	h_subtract = h < 0 ? -100 : 100
	τ = abs(h) < 100.0 ? 0.0 : (h - h_subtract)/ḣ

	if τ ≤ 0.0
		τ = -τ
	else
		τ = Inf
	end

	pra = length(a_prev) > 1 ? a_prev[2] : a_prev

	# Figure out intent (right now using some simple logic to infer - will see how well it works)
	a₁ = int_state.a[1:2]*mps2fps
	v₁_next = norm(int_state.v[1:2]*mps2fps + a₁) # Assuming dt is 1 just for calculation purposes (does not affect overalls sim)
	a = v₁_next - v₁

	intent = NOMINAL
	if a < -0.08g
		intent = LANDING
	elseif a > 0.08g
		intent = TAKEOFF
	end

	return SPEED_STATE_INTENT(r, θ, ψ, v₀, v₁, pra, τ, intent)
end

function get_mdp_state_turn(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, turn_rate_own::Float64, turn_rate_int::Float64, pra::Int64, dt::Float64)
	h = int_state.p[3] - own_state.p[3]
	ḣ₀ = own_state.v[3]
	ḣ₁ = int_state.v[3]

	# Figure out tau (NOTE: approximating turning by instant heading change)
	p₁ = [int_state.p[1], int_state.p[2]]
	p₀ = [own_state.p[1], own_state.p[2]]
	v₁ = [int_state.v[1], int_state.v[2]]
	v₁rot = rotate_vec(v₁, turn_rate_int*dt)
	v₀ = [own_state.v[1], own_state.v[2]]
	v₀rot = rotate_vec(v₀, turn_rate_own*dt)
	r = norm(p₁ - p₀)
	r_next = norm((p₁ + v₁rot*dt) - (p₀ + v₀rot*dt))
	ṙ = r - r_next
	τ = r < 500ft2m ? 0 : (r - 500ft2m)/ṙ

	if τ < 0
		τ = Inf
	end

	return MDP_STATE(h, ḣ₀, ḣ₁, pra, τ)
end

function dynamics!(ac::AIRCRAFT, action::Int64, dt::Float64)		
	should_print = typeof(ac) == UAM_VERT && action > COC

	# Figure out what action we are actually going to take based on delays
	prev_action = ac.curr_action
	ac.curr_action = action
	if (!ac.alerted) && (ac.init_delay > 0) && (action > COC) # will be dealing with initial delays here
		if ac.init_delay_counter < ac.init_delay
			ac.init_delay_counter += 1
			ac.curr_action = COC
		end
	elseif ac.alerted && (ac.subseq_delay > 0) && (action > COC) && (action != prev_action)
		if ac.subseq_delay_counter == ac.subseq_delay # Need to reset on an action change
			ac.subseq_delay_counter = 1
		elseif ac.subseq_delay_counter < ac.subseq_delay
			ac.subseq_delay_counter += 1
			ac.curr_action = prev_action
		end
	end

	curr_p = ac.curr_phys_state.p
	curr_v = ac.curr_phys_state.v
	curr_a = ac.curr_phys_state.a
	curr_h = ac.curr_phys_state.h

	ac.curr_action > COC ? ac.alerted = true : nothing

	if !ac.alerted || !ac.responsive # Follow flight path
		next_az = ac.z̈[ac.curr_step]
		next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], next_az]
	else # Determine acceleration based on current ra
		# Sample an acceleration
		next_az = rand(acceleration_dist_vert)
		vlow, vhigh = vel_ranges[ac.curr_action]
		if (vlow ≥ curr_v[3]) .| (vhigh ≤ curr_v[3]) # Compliant velocity
        	#println("$(ac.curr_step): $(ac.on_flight_path): $(ac.z̈[ac.curr_step])")
        	if ac.on_flight_path
        		next_az = ac.z̈[ac.curr_step]
        	else
        		next_az = 0.0 # Maybe change this?
        		ac.on_flight_path = false
        	end
	    else
	    	# Figure out how to get out of the velocity range
	    	next_az = abs(vlow) < abs(vhigh) ? -next_az : next_az
	    	if vlow > curr_v[3] + next_az 
		        next_az = vlow - curr_v[3]
		    elseif vhigh < curr_v[3] + next_az
		        next_az = vhigh - curr_v[3]
		    end
		    ac.on_flight_path = false
		end
		next_v_curr_a = curr_v + curr_a*dt
		next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], next_az]
	end

	next_p = curr_p + curr_v*dt + 0.5*next_a*dt^2
	#println(next_p[3])
	next_v = curr_v + next_a*dt
	next_h = norm(next_v) > 1e-9 ? atan(next_v[2], next_v[1]) : curr_h

	ac.curr_phys_state = PHYSICAL_STATE(next_p, next_v, next_a, next_h)

	ac.curr_step += 1
end

function dynamics!(ac::Union{UAM_SPEED, UAM_SPEED_INTENT}, action::Int64, dt::Float64)		
	# Figure out what action we are actually going to take based on delays
	prev_action = ac.curr_action
	ac.curr_action = action
	if (!ac.alerted) && (ac.init_delay > 0) && (action > COC) # will be dealing with initial delays here
		if ac.init_delay_counter < ac.init_delay
			ac.init_delay_counter += 1
			ac.curr_action = COC
		end
	elseif ac.alerted && (ac.subseq_delay > 0) && (action > COC) && (action != prev_action)
		if ac.subseq_delay_counter == ac.subseq_delay # Need to reset on an action change
			ac.subseq_delay_counter = 1
		elseif ac.subseq_delay_counter < ac.subseq_delay
			ac.subseq_delay_counter += 1
			ac.curr_action = prev_action
		end
	end

	curr_p = ac.curr_phys_state.p
	curr_v = ac.curr_phys_state.v
	curr_a = ac.curr_phys_state.a
	curr_h = ac.curr_phys_state.h

	ac.curr_action > COC ? ac.alerted = true : nothing

	if !ac.alerted || !ac.responsive # Follow flight path
		next_az = ac.z̈[ac.curr_step]
		next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], next_az]
	else # Determine acceleration based on current ra
		# Sample acceleration noise
		accel_noise = rand(acceleration_noise_speed)
		accel = (accels_speed[ac.curr_action] + accel_noise)*accels_speed[ac.curr_action] < 0.0 ? 
				0.0 : accels_speed[ac.curr_action] + accel_noise

		curr_speed = norm(curr_v[1:2])
		# Just make sure we do not go out of range 
		# *(may want to add this in speed mdp transition model)*
		if curr_speed + accel > speed_max
			accel = speed_max - curr_speed
		elseif curr_speed + accel < speed_min
			accel = speed_min - curr_speed
		end

		v_angle = atan(curr_v[2], curr_v[1])

		next_a = [accel*cos(v_angle), accel*sin(v_angle), ac.z̈[ac.curr_step]]
	end

	next_p = curr_p + curr_v*dt + 0.5*next_a*dt^2
	next_v = curr_v + next_a*dt
	next_h = norm(next_v[1:2]) > 1e-9 ? atan(next_v[2], next_v[1]) : curr_h

	ac.curr_phys_state = PHYSICAL_STATE(next_p, next_v, next_a, next_h)

	ac.curr_step += 1
end

function dynamics!(ac::Union{UAM_BLENDED, UAM_BLENDED_INTENT}, action::Vector{Int64}, dt::Float64)		
	# Figure out what action we are actually going to take based on delays
	prev_action = ac.curr_action
	ac.curr_action = action
	if (!ac.alerted) && (ac.init_delay > 0) && any(action .> COC) # will be dealing with initial delays here
		if ac.init_delay_counter < ac.init_delay
			ac.init_delay_counter += 1
			ac.curr_action = [COC, COC]
		end
	elseif ac.alerted && (ac.subseq_delay > 0) && any(action .> COC) && any(action .!= prev_action)
		if ac.subseq_delay_counter == ac.subseq_delay # Need to reset on an action change
			ac.subseq_delay_counter = 1
		elseif ac.subseq_delay_counter < ac.subseq_delay
			ac.subseq_delay_counter += 1
			ac.curr_action = prev_action
		end
	end

	curr_p = ac.curr_phys_state.p
	curr_v = ac.curr_phys_state.v
	curr_a = ac.curr_phys_state.a
	curr_h = ac.curr_phys_state.h

	any(ac.curr_action .> COC) ? ac.alerted = true : nothing
	ac.curr_action[1] > COC ? ac.alerted_vert = true : nothing
	ac.curr_action[2] > COC ? ac.alerted_speed = true : nothing

	if !ac.alerted || !ac.responsive # Follow flight path
		next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], ac.z̈[ac.curr_step]]
	else # Determine acceleration based on current ra
		# Deal with vertical first ########################################
		if !ac.alerted_vert
			next_az = ac.z̈[ac.curr_step]
		else
			next_az = rand(acceleration_dist_vert)
			vlow, vhigh = vel_ranges[ac.curr_action[1]]
			if (vlow ≥ curr_v[3]) .| (vhigh ≤ curr_v[3]) # Compliant velocity
	        	if ac.on_flight_path
	        		next_az = ac.z̈[ac.curr_step]
	        	else
	        		next_az = 0.0 # Maybe change this?
	        		ac.on_flight_path = false
	        	end
		    else
		    	# Figure out how to get out of the velocity range
		    	next_az = abs(vlow) < abs(vhigh) ? -next_az : next_az
		    	if vlow > curr_v[3] + next_az 
			        next_az = vlow - curr_v[3]
			    elseif vhigh < curr_v[3] + next_az
			        next_az = vhigh - curr_v[3]
			    end
			    ac.on_flight_path = false
			end
		end
		# Now deal with speed ########################################
		if !ac.alerted_speed
			next_ax = ac.ẍ[ac.curr_step]
			next_ay = ac.ÿ[ac.curr_step]
		else
			# Sample acceleration noise
			accel_noise = rand(acceleration_noise_speed)
			accel = (accels_speed[ac.curr_action[2]] + accel_noise)*accels_speed[ac.curr_action[2]] < 0.0 ? 
					0.0 : accels_speed[ac.curr_action[2]] + accel_noise

			curr_speed = norm(curr_v[1:2])
			# Just make sure we do not go out of range 
			# *(may want to add this in speed mdp transition model)*
			if curr_speed + accel > speed_max
				accel = speed_max - curr_speed
			elseif curr_speed + accel < speed_min
				accel = speed_min - curr_speed
			end

			v_angle = atan(curr_v[2], curr_v[1])
			next_ax = accel*cos(v_angle)
			next_ay = accel*sin(v_angle)
		end
		# Put it all together
		next_a = [next_ax, next_ay, next_az]
	end

	next_p = curr_p + curr_v*dt + 0.5*next_a*dt^2
	next_v = curr_v + next_a*dt
	next_h = norm(next_v[1:2]) > 1e-9 ? atan(next_v[2], next_v[1]) : curr_h

	ac.curr_phys_state = PHYSICAL_STATE(next_p, next_v, next_a, next_h)

	ac.curr_step += 1
end

function reset!(ac::AIRCRAFT)
	ac.ẍ = Vector{Float64}()
	ac.ÿ = Vector{Float64}()
	ac.z̈ = Vector{Float64}()
	ac.curr_action = COC
	ac.tracker = kalman_filter()
	ac.curr_observation = observation_state()
	ac.curr_belief_state = belief_state()
	ac.curr_phys_state = physical_state()
	ac.alerted = false
	ac.init_delay_counter = 1
	ac.subseq_delay_counter = 1
	ac.curr_step = 1
end

function reset!(ac::Union{UAM_VERT, UAM_VERT_PO})
	ac.ẍ = Vector{Float64}()
	ac.ÿ = Vector{Float64}()
	ac.z̈ = Vector{Float64}()
	ac.curr_action = COC
	ac.tracker = kalman_filter()
	ac.curr_observation = observation_state()
	ac.curr_belief_state = belief_state()
	ac.curr_phys_state = physical_state()
	ac.alerted = false
	ac.on_flight_path = true
	ac.init_delay_counter = 1
	ac.subseq_delay_counter = 1
	ac.curr_step = 1
end

function reset!(ac::Union{UAM_BLENDED, UAM_BLENDED_INTENT})
	ac.ẍ = Vector{Float64}()
	ac.ÿ = Vector{Float64}()
	ac.z̈ = Vector{Float64}()
	ac.curr_action = [COC, COC]
	ac.tracker = kalman_filter()
	ac.curr_observation = observation_state()
	ac.curr_belief_state = Vector{BELIEF_STATE}()
	ac.curr_phys_state = physical_state()
	ac.alerted = false
	ac.alerted_vert = false
	ac.alerted_speed = false
	ac.on_flight_path = true
	ac.init_delay_counter = 1
	ac.subseq_delay_counter = 1
	ac.curr_step = 1
end

function reset!(sim::SIMULATION)
	sim.sim_out = pairwise_simulation_output()
	sim.curr_enc = 0
end

function convert_to_grid_state(s::VERT_STATE)
	return [s.h, s.ḣ₀, s.ḣ₁, s.a_prev, s.τ]
end

function convert_to_grid_state(s::SPEED_STATE)
	return [s.r, s.θ, s.ψ, s.v₀, s.v₁, s.a_prev, s.τ]
end

function convert_to_grid_state(s::SPEED_STATE_INTENT)
	return [s.r, s.θ, s.ψ, s.v₀, s.v₁, s.a_prev, s.τ, s.intent]
end

function rotate_vec(v::Vector, θ::Float64)
	rot_mat = [cosd(θ) -sind(θ); sind(θ) cosd(θ)]
	return rot_mat*v
end

