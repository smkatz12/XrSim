# NOTE: this is mixed feet and meters 
# (vertical stuff is ft, ft/s and horizontal stuff is m, m/s)
# :(
function make_observation!(ac::AIRCRAFT)
	true_p = ac.curr_phys_state.p
	true_v = ac.curr_phys_state.v
	μ = [true_p; true_v]
	Σ = zeros(6,6)
	# Need to make sure to square everything to convert it all to variance
	Σ[1,1] = Σ[2,2] = (NACp_σ[ac.NACp])^2
	Σ[3,3] = (NACp_σ_vert[ac.NACp])^2
	Σ[4,4] = Σ[5,5] = vh_σ^2
	Σ[6,6] = vz_σ^2
	samp = rand(MvNormal(μ, Σ))
	ac.curr_observation = OBSERVATION_STATE(samp[1:3], samp[4:6])
end

function update_belief!(ac1::AIRCRAFT, ac2::AIRCRAFT, dt)
	typeof(ac1) != UNEQUIPPED ? update_tracker!(ac1, ac2, dt) : nothing
	typeof(ac2) != UNEQUIPPED ? update_tracker!(ac2, ac1, dt) : nothing
	typeof(ac1) != UNEQUIPPED ? update_tracked_belief!(ac1, dt) : nothing
	typeof(ac2) != UNEQUIPPED ? update_tracked_belief!(ac2, dt) : nothing
end

# State for kalman filter is ac1 pos, ac1 vel, ac2 pos, ac2vel
function update_tracker!(ac1::AIRCRAFT, ac2::AIRCRAFT, dt)
	# Current estimates
	μb = ac1.tracker.μb
	Σb = ac1.tracker.Σb

	# Get vector of current accelerations
	a = [ac1.curr_phys_state.a; zeros(3)] #ac2.curr_phys_state.a]

	# Get the current observation
	o = [ac1.curr_observation.p; ac1.curr_observation.v; ac2.curr_observation.p; ac2.curr_observation.v]

	# Get observation noise model
	Σo = zeros(12, 12)
	Σo[1,1] = Σo[2,2] = (NACp_σ[ac1.NACp])^2
	Σo[3,3] = (NACp_σ_vert[ac1.NACp])^2
	Σo[4,4] = Σo[5,5] = Σo[10,10] = Σo[11,11] = vh_σ^2
	Σo[6,6] = Σo[12,12] = vz_σ^2
	Σo[7,7] = Σo[8,8] = (NACp_σ[ac2.NACp])^2
	Σo[9,9] = (NACp_σ_vert[ac2.NACp])^2

	# Get transition matrices
	Ts = Matrix{Float64}(I, 12, 12)
	Ts[1:3, 4:6] = dt.*Matrix{Float64}(I, 3, 3)
	Ts[7:9, 10:12] = dt.*Matrix{Float64}(I, 3, 3)
	dt_id = dt.*Matrix{Float64}(I, 3, 3)
	Ta = [zeros(3,3) zeros(3,3); dt_id zeros(3,3); zeros(3,3) zeros(3,3); zeros(3,3) dt_id]

	# Dynamics noise
	int_Σ = zeros(6,6)
	int_Σ[1,1] = int_Σ[2,2] = (0.5int_ah_σ*dt^2)^2
	int_Σ[3,3] = (0.5int_az_σ*dt^2)^2
	int_Σ[4,4] = int_Σ[5,5] = (int_ah_σ*dt)^2
	int_Σ[6,6] = (int_az_σ*dt)^2
	int_Σ[1,4] = int_Σ[2,5] = int_Σ[4,1] = int_Σ[5,2] = (0.5int_ah_σ^2*dt^2)^2
	int_Σ[3,6] = int_Σ[6,3] = (0.5int_az_σ^2*dt^3)^2
	Σs = [zeros(6,6) zeros(6,6); zeros(6,6) int_Σ]

	# Propagate dynamics
	μp = Ts*μb + Ta*a
	Σp = Ts*Σb*Ts' + Σs # Going to assume no noise in the dynamics

	# Kalman update equations but Os is just the 6x6 identity
	# so I am not including it
	K = Σp/(Σp + Σo)
	new_μb = μp + K*(o - μp)
	new_Σb = (Matrix{Float64}(I, 12, 12) - K)*Σp
	#Fixing PSD issues
	new_Σb = round.(new_Σb, digits=8)
	ac1.tracker = KALMAN_FILTER(new_μb, new_Σb)
end

function update_tracked_belief!(ac::AIRCRAFT, dt)
	μb, Σb = ac.tracker.μb, ac.tracker.Σb
	samples = rand(MvNormal(μb, Σb), belief_size)
	update_belief_states!(ac, samples, dt)
end

function update_belief_states!(ac::Union{UNEQUIPPED, HEURISTIC_VERT, UAM_VERT}, samples, dt)
	μb, Σb = ac.tracker.μb, ac.tracker.Σb
	dist = MvNormal(μb, Σb)
	states = Vector{MDP_STATE}()
	probs = zeros(belief_size)
	for i = 1:belief_size
		probs[i] = pdf(dist, samples[:,i])
		p_own = samples[1:3, i]
		v_own = samples[4:6, i]
		p_int = samples[7:9, i]
		v_int = samples[10:12, i]
		push!(states, get_vert_state(p_own, v_own, p_int, v_int, ac.curr_action, dt))
	end
	# Normalize the probabilities
	probs ./= sum(probs)
	ac.curr_belief_state = BELIEF_STATE(states, probs)
end

function update_belief_states!(ac::UAM_SPEED, samples, dt)
	μb, Σb = ac.tracker.μb, ac.tracker.Σb
	dist = MvNormal(μb, Σb)
	states = Vector{MDP_STATE}()
	probs = zeros(belief_size)
	for i = 1:belief_size
		probs[i] = pdf(dist, samples[:,i])
		p_own = samples[1:3, i]
		v_own = samples[4:6, i]
		p_int = samples[7:9, i]
		v_int = samples[10:12, i]
		push!(states, get_speed_state(p_own, v_own, p_int, v_int, ac.curr_action, dt))
	end
	# Normalize the probabilities
	probs ./= sum(probs)
	ac.curr_belief_state = BELIEF_STATE(states, probs)
end

function update_belief_states!(ac::UAM_BLENDED, samples, dt)
	μb, Σb = ac.tracker.μb, ac.tracker.Σb
	dist = MvNormal(μb, Σb)
	v_states = Vector{MDP_STATE}()
	s_states = Vector{MDP_STATE}()
	probs = zeros(belief_size)
	for i = 1:belief_size
		probs[i] = pdf(dist, samples[:,i])
		p_own = samples[1:3, i]
		v_own = samples[4:6, i]
		p_int = samples[7:9, i]
		v_int = samples[10:12, i]
		push!(v_states, get_vert_state(p_own, v_own, p_int, v_int, ac.curr_action, dt))
		push!(s_states, get_speed_state(p_own, v_own, p_int, v_int, ac.curr_action, dt))
	end
	# Normalize the probabilities
	probs ./= sum(probs)
	ac.curr_belief_state = [BELIEF_STATE(v_states, probs), BELIEF_STATE(s_states, probs)]
end