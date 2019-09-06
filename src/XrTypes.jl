
"""
-------------------------------------------
General Types
-------------------------------------------
"""
struct PHYSICAL_STATE
	p::Vector{Float64} # (m, m, ft)
	v::Vector{Float64} # (m/s, m/s, ft/s)
	a::Vector{Float64} # (m/s², m/s², ft/s²)
	h::Float64 # radians
end

abstract type MDP_STATE
end

struct VERT_STATE <: MDP_STATE
	h::Float64
	ḣ₀::Float64
	ḣ₁::Float64
	a_prev::Int64
	τ::Float64
end

struct SPEED_STATE <: MDP_STATE
	r::Float64
	θ::Float64
	ψ::Float64
	v₀::Float64
	v₁::Float64
	a_prev::Int64
	τ::Float64
end

struct BELIEF_STATE
	states::Vector{MDP_STATE}
	probs::Vector{Float64}
end

TRAJECTORY = Vector{PHYSICAL_STATE}
ACTION_SEQUENCE = Vector{Int64}

"""
-------------------------------------------
Constructors
-------------------------------------------
"""
function physical_state(;p = Vector{Float64}(),
						 v = Vector{Float64}(),
						 a = Vector{Float64}(),
						 h = 0.0)
	return PHYSICAL_STATE(p, v, a, h)
end

function vert_state(;h = 0.0, ḣ₀ = 0.0, ḣ₁ = 0.0, a_prev = 1, τ=0.0)
	return VERT_STATE(h, ḣ₀, ḣ₁, a_prev, τ)
end

function speed_state(;r = 0.0, θ = 0.0, ψ = 0.0, v₀=0.0, v₁=0.0, a_prev = 1, τ=0.0)
	return SPEED_STATE(r, θ, ψ, v₀, v₁, a_prev, τ)
end

function belief_state(;states = Vector{MDP_STATE}(), probs = Vector{Float64}())
	return BELIEF_STATE(states, probs)
end

"""
-------------------------------------------
Simulation Objects
-------------------------------------------
"""
abstract type AIRCRAFT
end

mutable struct UNEQUIPPED <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	curr_action::Int64
	curr_belief_state::BELIEF_STATE
	curr_phys_state::PHYSICAL_STATE
	alerted::Bool
	responsive::Bool
	curr_step::Int64
end

mutable struct UAM_VERT <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	curr_action::Int64
	curr_belief_state::BELIEF_STATE
	curr_phys_state::PHYSICAL_STATE
	alerted::Bool
	responsive::Bool
	curr_step::Int64
	grid::RectangleGrid
	qmat::Array{Float64,2}
end

mutable struct UAM_VERT_PO <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	curr_action::Int64
	curr_belief_state::BELIEF_STATE
	curr_phys_state::PHYSICAL_STATE
	alerted::Bool
	responsive::Bool
	curr_step::Int64
	grid::RectangleGrid
	qmat::Array{Float64,2}
end

mutable struct UAM_SPEED <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	curr_action::Int64
	curr_belief_state::BELIEF_STATE
	curr_phys_state::PHYSICAL_STATE
	alerted::Bool
	responsive::Bool
	curr_step::Int64
	grid::RectangleGrid
	qmat::Array{Float64,2}
end

mutable struct HEURISTIC_VERT <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	curr_action::Int64
	curr_belief_state::BELIEF_STATE
	curr_phys_state::PHYSICAL_STATE
	alerted::Bool
	responsive::Bool
	curr_step::Int64
end

abstract type ENCOUNTER_OUTPUT
end

mutable struct PAIRWISE_ENCOUNTER_OUTPUT <: ENCOUNTER_OUTPUT
	ac1_trajectory::TRAJECTORY
	ac2_trajectory::TRAJECTORY
	ac1_actions::ACTION_SEQUENCE
	ac2_actions::ACTION_SEQUENCE
end

mutable struct ENCOUNTER
	aircraft::Vector{AIRCRAFT}
	dt::Float64
	num_steps::Int64
	enc_out::ENCOUNTER_OUTPUT
end

abstract type SIMULATION_OUTPUT
end

mutable struct PAIRWISE_SIMULATION_OUTPUT <: SIMULATION_OUTPUT
	ac1_trajectories::Vector{TRAJECTORY}
	ac2_trajectories::Vector{TRAJECTORY}
	ac1_actions::Vector{ACTION_SEQUENCE}
	ac2_actions::Vector{ACTION_SEQUENCE}
	times::Vector{Float64}
end

mutable struct SMALL_SIMULATION_OUTPUT <: SIMULATION_OUTPUT
	nmacs::Int64
	nmac_inds::Vector{Int64}
	alerts::Int64
	alert_inds::Vector{Int64}
	times::Vector{Float64}
end

mutable struct SIMULATION
	enc_file::String
	acs::Vector{AIRCRAFT}
	sim_out::SIMULATION_OUTPUT
	curr_enc::Int64
end

"""
-------------------------------------------
Constructors
-------------------------------------------
"""
function unequipped(;ẍ = Vector{Float64}(),
					 ÿ = Vector{Float64}(),
					 z̈ = Vector{Float64}(),
					 curr_action = COC,
					 curr_belief_state = belief_state(),
					 curr_phys_state = physical_state(),
					 alerted = false,
					 responsive = true,
					 curr_step = 1)
	return UNEQUIPPED(ẍ, ÿ, z̈, curr_action, curr_belief_state, 
						curr_phys_state, alerted, responsive, curr_step)
end

function uam_vert(;ẍ = Vector{Float64}(),
				   ÿ = Vector{Float64}(),
				   z̈ = Vector{Float64}(),
				   curr_action = COC,
				   curr_belief_state = belief_state(),
				   curr_phys_state = physical_state(),
				   alerted = false,
				   responsive = true,
				   curr_step = 1,
				   q_file = "data_files/xr_vert.bin",
				   grid = RectangleGrid(hs, ḣ₀s, ḣ₁s, a_prevs, τs_vert))
	s = open(q_file)
	m = read(s, Int)
	n = read(s, Int)
	qmat = Mmap.mmap(s, Matrix{Float64}, (m,n))
	return UAM_VERT(ẍ, ÿ, z̈, curr_action, curr_belief_state, curr_phys_state, 
						alerted, responsive, curr_step, grid, qmat)
end

function uam_vert_po(;ẍ = Vector{Float64}(),
				   ÿ = Vector{Float64}(),
				   z̈ = Vector{Float64}(),
				   curr_action = COC,
				   curr_belief_state = belief_state(),
				   curr_phys_state = physical_state(),
				   alerted = false,
				   responsive = true,
				   curr_step = 1,
				   q_file = "data_files/xr_vert.bin",
				   grid = RectangleGrid(hs, ḣ₀s, ḣ₁s, a_prevs, τs_vert))
	s = open(q_file)
	m = read(s, Int)
	n = read(s, Int)
	qmat = Mmap.mmap(s, Matrix{Float64}, (m,n))
	return UAM_VERT_PO(ẍ, ÿ, z̈, curr_action, curr_belief_state, curr_phys_state, 
						alerted, responsive, curr_step, grid, qmat)
end

function uam_speed(;ẍ = Vector{Float64}(),
				   ÿ = Vector{Float64}(),
				   z̈ = Vector{Float64}(),
				   curr_action = COC,
				   curr_belief_state = belief_state(),
				   curr_phys_state = physical_state(),
				   alerted = false,
				   responsive = true,
				   curr_step = 1,
				   q_file = "data_files/xr_speed.bin",
				   grid = RectangleGrid(rs, θs, ψs, v₀s, v₁s, a_prevs, τs_speed))
	s = open(q_file)
	m = read(s, Int)
	n = read(s, Int)
	qmat = Mmap.mmap(s, Matrix{Float64}, (m,n))
	return UAM_SPEED(ẍ, ÿ, z̈, curr_action, curr_belief_state, curr_phys_state, 
						alerted, responsive, curr_step, grid, qmat)
end

function heuristic_vert(;ẍ = Vector{Float64}(),
				   ÿ = Vector{Float64}(),
				   z̈ = Vector{Float64}(),
				   curr_action = COC,
				   curr_belief_state = belief_state(),
				   curr_phys_state = physical_state(),
				   alerted = false,
				   responsive = true,
				   curr_step = 1)
	return HEURISTIC_VERT(ẍ, ÿ, z̈, curr_action, curr_belief_state, curr_phys_state, 
						alerted, responsive, curr_step)
end

function pairwise_simulation_output(;ac1_trajectories = Vector{TRAJECTORY}(),
									 ac2_trajectories = Vector{TRAJECTORY}(),
									 ac1_actions = Vector{ACTION_SEQUENCE}(),
									 ac2_actions = Vector{ACTION_SEQUENCE}(),
									 times = Vector{Float64}())
	return PAIRWISE_SIMULATION_OUTPUT(ac1_trajectories, ac2_trajectories,
										ac1_actions, ac2_actions, times)
end

function small_simulation_output(;nmacs = 0,
								nmac_inds = Vector{Int64}(), 
								alerts = 0,
								alert_inds = Vector{Int64}(),
								times = Vector{Float64}())
	return SMALL_SIMULATION_OUTPUT(nmacs, nmac_inds, alerts, alert_inds, times)
end

function pairwise_encounter_output(;ac1_trajectory = TRAJECTORY(),
									 ac2_trajectory = TRAJECTORY(),
									 ac1_actions = ACTION_SEQUENCE(),
									 ac2_actions = ACTION_SEQUENCE())
	return PAIRWISE_ENCOUNTER_OUTPUT(ac1_trajectory, ac2_trajectory,
										ac1_actions, ac2_actions)
end

function simulation(;enc_file = "test.txt",
					 acs = [unequipped(), unequipped()],
					 sim_out = pairwise_simulation_output(),
					 curr_enc = 0)
	return SIMULATION(enc_file, acs, sim_out, curr_enc)
end

"""
-------------------------------------------
Other Stuff
-------------------------------------------
"""
function copy(s::PHYSICAL_STATE)
	return PHYSICAL_STATE(s.p, s.v, s.a)
end

function reset!(sim_out::PAIRWISE_SIMULATION_OUTPUT)
	sim_out.ac1_trajectories = Vector{TRAJECTORY}()
	sim_out.ac2_trajectories = Vector{TRAJECTORY}()
	sim_out.ac1_actions = Vector{ACTION_SEQUENCE}()
	sim_out.ac2_actions = Vector{ACTION_SEQUENCE}()
	sim_out.times = Vector{Float64}()
end

function reset!(sim_out::SMALL_SIMULATION_OUTPUT)
	sim_out.nmacs = 0
	sim_out.nmac_inds = Vector{Int64}()
	sim_out.alerts = 0
	sim_out.alert_inds = Vector{Int64}()
	sim_out.times = Vector{Float64}()
end