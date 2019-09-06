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
accels_speed = Dict(COC=>0.0, WD=>-0.04g, WA=>0.04g, SD=>-0.08g, SA=>0.08g)
acceleration_noise_speed = Normal(0.0, 0.02g)

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

nTau_max = 60
dt_speed_q = 4
τs_speed = collect(0:dt_speed_q:nTau_max)