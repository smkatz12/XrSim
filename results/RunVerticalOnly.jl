using XLSX
using Random
Random.seed!(24)

output_filename = "results/Vertical_Only_Res.xlsx"

"""
-------------------------------------------
UAM vs. UAM (EU)
-------------------------------------------
"""

println("Simulating UAM vs. UAM (EU)...")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C7"] = sim.sim_out.nmacs
    sheet["E7"] = sim.sim_out.alerts
end

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam.bin"
sim.acs[1] = uam_vert(q_file = "data_files/closeness_noRev.bin")
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C8"] = sim.sim_out.nmacs
    sheet["E8"] = sim.sim_out.alerts
end

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
sim.enc_file = "data_files/uam_uam.bin"
sim.acs[1] = heuristic_vert()
sim.acs[2] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["I7"] = sim.sim_out.nmacs
    sheet["K7"] = sim.sim_out.alerts
end

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_uam.bin"
sim.acs[1] = uam_vert(q_file = "data_files/closeness_noRev.bin")
sim.acs[2] = uam_vert(q_file = "data_files/closeness_noRev.bin")
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["I8"] = sim.sim_out.nmacs
    sheet["K8"] = sim.sim_out.alerts
end

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
sim.enc_file = "data_files/uam_hd.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["O7"] = sim.sim_out.nmacs
    sheet["Q7"] = sim.sim_out.alerts
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_hd.bin"
sim.acs[1] = uam_vert(q_file = "data_files/closeness_noRev.bin")
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["O8"] = sim.sim_out.nmacs
    sheet["Q8"] = sim.sim_out.alerts
end

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
sim.enc_file = "data_files/uam_suas.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C18"] = sim.sim_out.nmacs
    sheet["E18"] = sim.sim_out.alerts
end

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_suas.bin"
sim.acs[1] = uam_vert(q_file = "data_files/closeness_noRev.bin")
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["C19"] = sim.sim_out.nmacs
    sheet["E19"] = sim.sim_out.alerts
end

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
sim.enc_file = "data_files/uam_manned.bin"
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["I18"] = sim.sim_out.nmacs
    sheet["K18"] = sim.sim_out.alerts
end

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = "data_files/uam_manned.bin"
sim.acs[1] = uam_vert(q_file = "data_files/closeness_noRev.bin")
xr_sim!(sim)

XLSX.openxlsx(output_filename, mode="rw") do xf
    sheet = xf[1]
    sheet["I19"] = sim.sim_out.nmacs
    sheet["K19"] = sim.sim_out.alerts
end

println(sim.sim_out.nmacs)
println(sim.sim_out.alerts)