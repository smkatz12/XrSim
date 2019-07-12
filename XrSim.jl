function xr_sim!(sim::SIMULATION)
	# Load in the text file to get dt, num_steps, and all of the encounters
	open(sim.enc_file) do f
		dt = readline(f)
		num_steps = readline(f)
		# For each encounter
		while !eof(f)
			# Make an encounter out of info
			aircraft = sim.acs
			for i = 1:length(aircraft)
				aircraft[i].curr_state = readline(f)
				push!(aircraft[i].phys_states, aircraft[i].curr_state)
				aircraft[i].ẍ = readline(f)
				aircraft[i].ÿ = readline(f)
				aircraft[i].z̈ = readline(f)
			end
			enc = ENCOUNTER(aircraft, dt, num_steps)
			# Simulate the encounter
			simulate_encounter!(enc)
		end
	end
end

# Currently, this does not support multithreat
function simulate_encounter!(enc::ENCOUNTER)
	ac1 = enc.aircraft[1]
	ac2 = enc.aircraft[2]
	# Get initial state (physical and mdp) and set it to current state
	ac1.curr_mdp_state = get_mdp_state(ac1.phys_states[end], ac2.phys_states[end], ac1.actions[end])
	ac2.curr_mdp_state = get_mdp_state(ac2.phys_states[end], ac1.phys_states[end], ac2.actions[end])
	# Get encounter length
	# For each time step in the encounter
	for i = 1:enc.num_steps
		# For each aircraft in the encounter
		for ac in enc.aircrafts
			action = select_action(ac)
			dynamics!(ac, action, enc.dt)
		end
		# get next mdp state - mdp_state(phys_state)
		ac1.curr_mdp_state = get_mdp_state(ac1.phys_states[end], ac2.phys_states[end], ac1.actions[end])
		ac2.curr_mdp_state = get_mdp_state(ac2.phys_states[end], ac1.phys_states[end], ac2.actions[end])
	end
end

function get_mdp_state(own_state::PHYSICAL_STATE, int_state::PHYSICAL_STATE, pra::Int64)
	h = int_state.z - own_state.z
	ḣ₀ = own_state.ż
	ḣ₁ = int_state.ż

	# Figure out τ
	# Shift intruder to be relative to an ownship at the origin
	p₁ = [int_state.x, int_state.y]
	p₀ = [own_state.x, own_state.y]
	p₁shift = p₁ - p₀
	# Rotate intuder velocity to be relative to ownship heading of zero degrees
	v₁ = [int_state.ẋ, int_state.ẏ]
	rot_ang = -atand(own_state.ẏ, own_state.ẋ)
	R = [cosd(rot_ang) -sind(rot_ang); sind(rot_ang) cosd(rot_ang)]
	v₁rot = R*v₁
	# Figure out when y-value is zero now
	τ = -p₁shift[2]/v₁rot[2]

	return MDP_STATE(h, ḣ₀, ḣ₁, pra, τ)
end

function select_action(ac::UNEQUIPPED)
	return COC
end

function select_action(ac::UAM_VERT)
	states, probs = interpolants(ac.grid, ac.curr_mdp_state)
	s = states[argmax(probs)]
	return argmax(probs)
end

function dynamics!(ac::AIRCRAFT, action::Int64, dt::Float64)
	push!(ac.actions, action)
	curr_p = ac.phys_states[end].p
	curr_v = ac.phys_states[end].v
	curr_a = ac.phys_states[end].a

	action > COC ? ac.alerted = true : nothing

	if !ac.alerted # Follow flight path
		next_az = ac.z̈[ac.curr_step]
	else # Determine acceleration based on current ra
		# Sample an acceleration
		next_az = rand(acceleration_dist)
		vlow, vhigh = vel_ranges(action)
		if (vlow ≥ curr_v[3]) .| (vhigh ≤ curr_v[3]) # Compliant velocity
        	next_az = 0
	    elseif vlow > curr_v[3] + next_az 
	        next_az = vlow - curr_v[3]
	    elseif vhigh < curr_v[3] + next_az
	        next_az = vhigh - curr_v[3]
	    end
	    next_a = [ac.ẍ[ac.curr_step], ac.ÿ[ac.curr_step], next_az]
	end
	next_p = curr_p + curr_v*dt + 0.5*next_a*dt^2
	next_v = curr_v + next_a*dt

	push!(ac.phys_states, PHYSICAL_STATE(next_p, next_a, next_v))
	ac.curr_step += 1
end