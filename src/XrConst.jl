"""
-------------------------------------------
General Constants
-------------------------------------------
"""
fpm2fps = 1/60
ft2m = 0.3048
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

"""
-------------------------------------------
Transition Model Info
-------------------------------------------
"""
vel_ranges = Dict(COC=>(0.0fpm2fps, 0.0fpm2fps),#COC=>(-500.0fpm2fps, 500.0fpm2fps),
                DNC=>(0.0, Inf),
                DND=>(-Inf, 0.0),
                CL250=>(-Inf, 250.0fpm2fps),
                SCL450=>(-Inf, 450.0fpm2fps))

acceleration_dist = Normal(0.15g, 0.02g)

"""
-------------------------------------------
States
-------------------------------------------
"""
hs   = vcat(LinRange(-600,-400,5),LinRange(-360,-200,5),LinRange(-180,0,10),
            LinRange(20,200,10),LinRange(240,400,5),LinRange(450,600,4))
ḣ₀s = collect(-500:25:500)*fpm2fps
ḣ₁s = collect(-500:25:500)*fpm2fps
a_prevs = collect(0:4) # Check this
τs = collect(0:100)

"""
-------------------------------------------
Encounter viewer stuff
-------------------------------------------
"""
sc = ["ra_1={mark=none},ra_2={mark=o,blue},ra_3={mark=o,red},ra_4={mark=halfcircle*,red},ra_5={mark=*,red}"]
ra_dict = Dict(0=>"ra_1", 1=>"ra_2", 2=>"ra_3", 3=>"ra_4", 4=>"ra_5")