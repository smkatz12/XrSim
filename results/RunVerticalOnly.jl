using XLSX
using Random
Random.seed!(24)

output_filename = "results/Vertical_Only_Res.xlsx"
q_file = "data_files/test.bin"

num_nmacs_h = 0
num_alerts_h = 0

num_nmacs_xr = 0
num_alerts_xr = 0

"""
-------------------------------------------
UAM vs. UAM (EU)
-------------------------------------------
"""

println("Simulating UAM vs. UAM (EU)...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam_fixed_v2.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C7"] = sim.sim_out.nmacs
    sheet["D7"] = sim.sim_out.alerts
    sheet["C11"] = sim.sim_out.nmacs/sheet["C6"]
end

num_nmacs_h += sim.sim_out.nmacs
num_alerts_h += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam_fixed_v2.bin"
sim.acs[1] = uam_vert(q_file = q_file)
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C8"] = sim.sim_out.nmacs
    sheet["D8"] = sim.sim_out.alerts
    sheet["C12"] = sim.sim_out.nmacs/sheet["C6"]
end

num_nmacs_xr += sim.sim_out.nmacs
num_alerts_xr += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

"""
-------------------------------------------
UAM vs. UAM (EE)
-------------------------------------------
"""

println("Simulating UAM vs. UAM (EE)...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam_fixed_v2.bin"
sim.acs[1] = heuristic_vert()
sim.acs[2] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["G7"] = sim.sim_out.nmacs
    sheet["H7"] = sim.sim_out.alerts
    sheet["G11"] = sim.sim_out.nmacs/sheet["G6"]
end

num_nmacs_h += sim.sim_out.nmacs
num_alerts_h += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam_fixed_v2.bin"
sim.acs[1] = uam_vert(q_file = q_file)
sim.acs[2] = uam_vert(q_file = q_file)
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["G8"] = sim.sim_out.nmacs
    sheet["H8"] = sim.sim_out.alerts
    sheet["G12"] = sim.sim_out.nmacs/sheet["G6"]
end

num_nmacs_xr += sim.sim_out.nmacs
num_alerts_xr += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

"""
-------------------------------------------
UAM vs. Hobby Drone
-------------------------------------------
"""

println("Simulating UAM vs. Hobby Drone...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_hd_fixed_v2.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

num_nmacs_h += sim.sim_out.nmacs
num_alerts_h += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["K7"] = sim.sim_out.nmacs
    sheet["L7"] = sim.sim_out.alerts
    sheet["K11"] = sim.sim_out.nmacs/sheet["K6"]
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_hd_fixed_v2.bin"
sim.acs[1] = uam_vert(q_file = q_file)
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["K8"] = sim.sim_out.nmacs
    sheet["L8"] = sim.sim_out.alerts
    sheet["K12"] = sim.sim_out.nmacs/sheet["K6"]
end

num_nmacs_xr += sim.sim_out.nmacs
num_alerts_xr += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

"""
-------------------------------------------
UAM vs. sUAS
-------------------------------------------
"""

println("Simulating UAM vs. sUAS...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_suas_fixed_v2.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C18"] = sim.sim_out.nmacs
    sheet["D18"] = sim.sim_out.alerts
    sheet["C22"] = sim.sim_out.nmacs/sheet["C17"]
end

num_nmacs_h += sim.sim_out.nmacs
num_alerts_h += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_suas_fixed_v2.bin"
sim.acs[1] = uam_vert(q_file = q_file)
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C19"] = sim.sim_out.nmacs
    sheet["D19"] = sim.sim_out.alerts
    sheet["C23"] = sim.sim_out.nmacs/sheet["C17"]
end

num_nmacs_xr += sim.sim_out.nmacs
num_alerts_xr += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

"""
-------------------------------------------
UAM vs. Manned
-------------------------------------------
"""

println("Simulating UAM vs. Manned...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_manned_fixed_v2.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["G18"] = sim.sim_out.nmacs
    sheet["H18"] = sim.sim_out.alerts
    sheet["G22"] = sim.sim_out.nmacs/sheet["G17"]
end

num_nmacs_h += sim.sim_out.nmacs
num_alerts_h += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_manned_fixed_v2.bin"
sim.acs[1] = uam_vert(q_file = q_file)
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["G19"] = sim.sim_out.nmacs
    sheet["H19"] = sim.sim_out.alerts
    sheet["G23"] = sim.sim_out.nmacs/sheet["G17"]
end

num_nmacs_xr += sim.sim_out.nmacs
num_alerts_xr += sim.sim_out.alerts
println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

"""
-------------------------------------------
Overall
-------------------------------------------
"""

# Fill this in if you want to
XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["K18"] = num_nmacs_h
    sheet["L18"] = num_alerts_h
    sheet["K19"] = num_nmacs_xr
    sheet["L19"] = num_alerts_xr
    sheet["K22"] = num_nmacs_h/sheet["K17"]
    sheet["K23"] = num_nmacs_xr/sheet["K17"]
end