"""
-------------------------------------------
General Constants
-------------------------------------------
"""
fpm2fps = 1/60
ft2m = 0.3048
m2ft = 3.28084
mps2fps = 3.28084
g = 32.2 #ft/s²
g_mps = 9.81

"""
-------------------------------------------
Advisory Indices
-------------------------------------------
"""
COC = 0
DNC = 1
DND = 2
CL250 = 3
SCL450 = 4

COC = 0
WD = 1
WA = 2
SD = 3
SA = 4

"""
-------------------------------------------
Transition Model Info
-------------------------------------------
"""
# Vertical
vel_ranges = Dict(COC=>(0.0fpm2fps, 0.0fpm2fps),#COC=>(-500.0fpm2fps, 500.0fpm2fps),
                DNC=>(0.0, Inf),
                DND=>(-Inf, 0.0),
                CL250=>(-Inf, 250.0fpm2fps),
                SCL450=>(-Inf, 450.0fpm2fps))

acceleration_dist_vert = Normal(0.15g, 0.02g)

# Speed
accels_speed = Dict(COC=>0.0, WD=>-0.04g_mps, WA=>0.04g_mps, SD=>-0.08g_mps, SA=>0.08g_mps)
acceleration_noise_speed = Normal(0.0, 0.02g_mps)

speed_max = 45.0 # m/s
speed_min = 0.0 # m/s

"""
-------------------------------------------
States
-------------------------------------------
"""
# Vertical
hs   = vcat(LinRange(-600,-400,5),LinRange(-360,-200,5),LinRange(-180,0,10),
            LinRange(20,200,10),LinRange(240,400,5),LinRange(450,600,4))
ḣ₀s = collect(-500:25:500)*fpm2fps
ḣ₁s = collect(-500:25:500)*fpm2fps
a_prevs = collect(0:4) # Check this
τs_vert = collect(0:120)

# Speed
rs = [0.0,25.0,50.0,75.0,100.0,150.0,200.0,300.0,400.0,500.0,510.0,750.0,1000.0,1500.0,2000.0,3000.0,4000.0,5000.0,7000.0,9000.0,11000.0,13000.0,15000.0] #ft
θs = Array(LinRange(-π,π,21))
ψs   = Array(LinRange(-π,π,21))
v₀s = [0.0, 4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0, 36.0].*mps2fps   #ft/s
v₁s = [0.0, 8.0, 16.0, 24.0, 32.0, 40.0].*mps2fps #ft/s
a_prevs = collect(0:4) # Check this (NOTE: this is same as above and has to be)

NOMINAL = 0
LANDING = 1
TAKEOFF = 2

nTau_max = 100
dt_speed_q = 4
τs_speed = collect(0:dt_speed_q:nTau_max)
intents = collect(0:2)

"""
-------------------------------------------
STM Parameters
-------------------------------------------
"""
# https://mode-s.org/decode/adsb/uncertainty.html
# These (NACp's) are in meters!!!!!
NACp_σ = Dict(11=>1.5, 10=>5, 9=>15, 8=>46.5, 7=>92.5, 
			  6=>278, 5=>463, 4=>926, 3=>1852, 2=>3704, 1=>9620)
NACp_σ_vert = Dict(11=>2m2ft, 10=>7.5m2ft, 9=>22.5m2ft, 8=>22.5m2ft, 7=>22.5m2ft, 
			  6=>22.5m2ft, 5=>22.5m2ft, 4=>22.5m2ft, 3=>22.5m2ft, 2=>22.5m2ft, 1=>22.5m2ft)

NACp_dist = Categorical([0.506, 0.403, 0.091])

alt_σ = 4.7 # ft (from csim) # I think is no longer going to be used
vh_σ = 0.5 # m/s (corresponds to NACv = 3) # was 2
vz_σ = 2.5 # ft/s (corresponds to NACv = 3) # was 4

int_ah_σ = 0.04g_mps
int_az_σ = 0.02g

belief_size = 5