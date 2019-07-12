
"""
-------------------------------------------
General Types
-------------------------------------------
"""
struct PHYSICAL_STATE
	p::Vector{Float64}
	v::Vector{Float64}
	a::Vector{Float64}
end

struct MDP_STATE
	h::Float64
	ḣ₀::Float64
	ḣ₁::Float64
	a_prev::Int64
	τ::Float64
end

"""
-------------------------------------------
Simulation Objects
-------------------------------------------
"""
mutable struct ENCOUNTER
	aircraft::Vector{AIRCRAFT}
	dt::Int64
	num_steps::Int64
end

abstract type AIRCRAFT
end

mutable struct UNEQUIPPED <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	actions::Vector{Int64}
	curr_mdp_state::MDP_STATE
	phys_states::Vector{PHYSICAL_STATE}
	alerted::Bool
	curr_step::Int64
end

mutable struct UAM_VERT <: AIRCRAFT
	ẍ::Vector{Float64}
	ÿ::Vector{Float64}
	z̈::Vector{Float64}
	actions::Vector{Int64}
	curr_mdp_state::MDP_STATE
	phys_states::Vector{PHYSICAL_STATE}
	alerted::Bool
	curr_step::Int64
	qmat::Array{Float64,2}
	grid::RectangleGrid
end

mutable struct SIMULATION
	enc_file::String
	acs::Vector{AIRCRAFT}
end