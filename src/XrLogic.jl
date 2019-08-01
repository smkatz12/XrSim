function select_action(ac::UNEQUIPPED)
	return COC
end

function select_action(ac::UAM_VERT)
	states, probs = interpolants(ac.grid, convert_to_grid_state(ac.curr_mdp_state))
	s = states[argmax(probs)]
	return argmax(ac.qmat[s,:]) - 1 # Off by 1 due to indexing at 1
end

function select_action(ac::HEURISTIC_VERT)
	mdp_state = ac.curr_mdp_state
	return heuristic_vert(mdp_state)
end

function heuristic_vert(s::MDP_STATE)
	# Decide whether or not to alert

	vertical_go = false
	vτ = Inf
	# Compute time to loss of vertical separation
	# If already lost, set vertical_go to true
	# If diverging, set vertical_go to false
	# Otherwise actually calculate it and decide
	if abs(s.h) > 120
		vertical_go = true
		vτ = 0
	else
		diverging = (s.h < 0 && s.ḣ₀ > 0 && s.ḣ₁ < 0) || (s.h > 0 && s.ḣ₀ < 0 && s.ḣ₁ > 0)
		if !diverging
			vτ = s.h/(s.ḣ₀ - s.ḣ₁) # Check this!
			vτ ≤ 35 ? vertical_go = true : nothing
		end
	end
	# Determine horizontal_go
	horizontal_go = s.τ ≤ 35 ? true : false

	# If vertical and horizontal go, decide what alert to issue
	if horizontal_go && vertical_go
		# If below issue climb
		if s.h < 0 # Intruder is below
			# Which climb depends on τ
			return (s.τ ≤ 20 && s.a_prev ≥ CL250) ? SCL450 : CL250
		# If above
		else
			# Determine if crossing seems possible
			time_to_cross = 450*60/h # Multiply by 60 nto go from minutes to seconds
			time_to_450 = (450 - s.ḣ₀)/0.15g # Time to actually get to strong climb
			crossing_time = time_to_cross + time_to_450 + 5 # 5 second buffer
			# If so
			if crossing_time ≤ s.τ
				# go for climb (strong if possible)
				return s.a_prev ≥ CL250 ? SCL450 : CL250
			# if not
			else
				# go with do not climb
				return DNC
			end
		end
	end
	return COC
end