update_coordination!(ac::Union{UAM_VERT, UAM_VERT_PO, UAM_SPEED, UAM_SPEED_INTENT}, address::Int) = update_coordination!(ac.coordination, ac.curr_action, address)

function update_coordination!(coord::VERTICAL_COORDINATION, curr_action::Int, address::Int)
    if coord.enabled
        coord.address = address
        if curr_action in [DND, CL250, SCL450] # up sense actions
            coord.own_sense = :up
        elseif curr_action == DNC # down sense action(s)
            coord.own_sense = :down
        else # implicit COC
            coord.own_sense = :none
        end
    end
end

function update_coordination!(coord::SPEED_COORDINATION, curr_action::Int, address::Int)
    if coord.enabled
        coord.address = address
        if curr_action in [WA, SA] # acceleration sense actions
            coord.own_sense = :accel
        elseif curr_action in [WD, SD] # deceleration sense action
            coord.own_sense = :decel
        else # implicit COC
            coord.own_sense = :none
        end
    end
end

# TODO.
# update_coordination!(ac::UAM_BLENDED)
update_coordination!(ac::UNEQUIPPED, address::Int) = nothing


function send_coordination!(aircraft::Vector{AIRCRAFT})
    # NOTE: Assumes single intruder, i.e. no multithreat.
    @assert length(aircraft) == 2

    if aircraft[1] isa UNEQUIPPED || aircraft[2] isa UNEQUIPPED
        # Skip sending coordination to unequipped aircraft
        return
    else
        aircraft[1].coordination.int_sense = aircraft[2].coordination.own_sense
        aircraft[2].coordination.int_sense = aircraft[1].coordination.own_sense

        determine_follower!(aircraft::Vector{AIRCRAFT})
    end
end

"""
`determine_follower!`

Leader/follower commitment:
- First to alert, or tie-break by address.
- `isfollower` is only set when a leader is determined
  - This way, penalties are only applied when `isfollower` is true
"""
function determine_follower!(aircraft::Vector{AIRCRAFT})
    already_determined::Bool = aircraft[1].coordination.isfollower || aircraft[2].coordination.isfollower
    if !already_determined
        if aircraft[1].curr_action != COC && aircraft[2].curr_action != COC
            # Both alerted simultaneously, tie-break by address.
            if aircraft[1].coordination.address < aircraft[2].coordination.address # (which is set by index)
                aircraft[2].coordination.isfollower = true
            else
                aircraft[1].coordination.isfollower = true
            end
        elseif aircraft[1].curr_action != COC && aircraft[2].curr_action == COC
            # Aircraft 1 alerted first, set leader (i.e. set other aircraft as follower).
            aircraft[2].coordination.isfollower = true
        elseif aircraft[1].curr_action == COC && aircraft[2].curr_action != COC
            # Aircraft 2 alerted first, set leader (i.e. set other aircraft as follower).
            aircraft[1].coordination.isfollower = true
        end
        # No alerts, do nothing.
    end
end


"""
`coordination_penalty!`

Applies penalty to complementary actions based on received coordination information.
Used in `select_action` as an online cost to augment the Q-values.
"""
coordination_penalty!(ac::Union{UAM_VERT, UAM_VERT_PO, UAM_SPEED, UAM_SPEED_INTENT}, q::Vector) = coordination_penalty!(ac.coordination, q)

# TODO: 
# function coordination_penalty!(ac::Union{UAM_BLENDED, UAM_BLENDED_INTENT}, q::Vector)
#     # TODO: Different Q-values?
#     coordination_penalty!(ac.speed_coordination, q)
#     coordination_penalty!(ac.vertical_coordination, q)
# end

function coordination_penalty!(coord::VERTICAL_COORDINATION, q::Vector)
    if coord.enabled && coord.isfollower
        # Follower will penalize their conflicting alerts
        # (+1 for off-by-one indexing, where COC=0)
        if coord.int_sense == :up
            q[DND+1] = -Inf
            q[CL250+1] = -Inf
            q[SCL450+1] = -Inf
        elseif coord.int_sense == :down
            q[DNC+1] = -Inf
        end
    end
    return q::Vector
end


function coordination_penalty!(coord::SPEED_COORDINATION, q::Vector)
    if coord.enabled && coord.isfollower
        # Follower will penalize their conflicting alerts
        # (+1 for off-by-one indexing, where COC=0)
        if coord.int_sense == :accel
            q[WA+1] = -Inf
            q[SA+1] = -Inf
        elseif coord.int_sense == :decel
            q[WD+1] = -Inf
            q[SD+1] = -Inf
        end
    end
    return q::Vector
end
