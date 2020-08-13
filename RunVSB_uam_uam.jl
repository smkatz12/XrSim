using XLSX
using Random
Random.seed!(24)

# output_filename = "results/Xr_Results_VSB.xlsx" # comment back in when simulating straight from this script and not from uam_uam_old_vs_expanded_speed.ipynb
q_file = "data_files/test.bin"
q_file_speed = "data_files/test_speed_120.bin" 
# enc_file = "data_files/uam_uam.bin"  # comment back in and update when simulating straight from this script and not from uam_uam_old_vs_expanded_speed.ipynb
# sim_out_to_excel = true  # comment back in when simulating straight from this script and not from uam_uam_old_vs_expanded_speed.ipynb
# sim_out_display_results = true # comment back in when simulating straight from this script and not from uam_uam_old_vs_expanded_speed.ipynb

num_nmacs_unequipped_eu = 0

num_nmacs_h_eu = 0
num_alerts_h_eu = 0

num_nmacs_xr_vert_eu = 0
num_alerts_xr_vert_eu = 0

num_nmacs_xr_speed_eu = 0
num_alerts_xr_speed_eu = 0

num_nmacs_xr_speed_scaling_eu = 0
num_alerts_xr_speed_scaling_eu = 0

num_nmacs_xr_blended_eu = 0
num_alerts_xr_blended_eu = 0

num_nmacs_xr_blended_scaling_eu = 0
num_alerts_xr_blended_scaling_eu = 0

"""
-------------------------------------------
UAM vs. UAM (EU)
-------------------------------------------
"""

println("________Simulating UAM vs. UAM (EU)________")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C6"] = sim.sim_out.nmacs
        sheet["D6"] = sim.sim_out.alerts
    end
end

num_nmacs_unequipped_eu += sim.sim_out.nmacs
if sim_out_display_results
    println("Unequipped NMACs : ", sim.sim_out.nmacs)
    println("Unequipped Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = heuristic_vert()
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C7"] = sim.sim_out.nmacs
        sheet["D7"] = sim.sim_out.alerts
        sheet["C15"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_h_eu += sim.sim_out.nmacs
num_alerts_h_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Hueristic NMACs : ", sim.sim_out.nmacs)
    println("Hueristic Alerts : ",sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_vert(q_file = q_file)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C8"] = sim.sim_out.nmacs
        sheet["D8"] = sim.sim_out.alerts
        sheet["C16"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_xr_vert_eu += sim.sim_out.nmacs
num_alerts_xr_vert_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Vertical NMACs : ", sim.sim_out.nmacs)
    println("Vertical Alerts : ",sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_speed(q_file = q_file_speed)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C9"] = sim.sim_out.nmacs
        sheet["D9"] = sim.sim_out.alerts
        sheet["C17"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_xr_speed_eu += sim.sim_out.nmacs
num_alerts_xr_speed_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Speed NMACs : ",sim.sim_out.nmacs)
    println("Speed Alerts : ",sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_speed(q_file = q_file_speed)
sim.acs[1].perform_scaling = true
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C10"] = sim.sim_out.nmacs
        sheet["D10"] = sim.sim_out.alerts
        sheet["C18"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_xr_speed_scaling_eu += sim.sim_out.nmacs
num_alerts_xr_speed_scaling_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Speed w/ Scaling NMACs : ", sim.sim_out.nmacs)
    println("Speed w/ Scaling Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C11"] = sim.sim_out.nmacs
        sheet["D11"] = sim.sim_out.alerts
        sheet["C19"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_xr_blended_eu += sim.sim_out.nmacs
num_alerts_xr_blended_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Blended NMACs : ", sim.sim_out.nmacs)
    println("Blended Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
sim.acs[1].perform_scaling = true
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["C12"] = sim.sim_out.nmacs
        sheet["D12"] = sim.sim_out.alerts
        sheet["C20"] = sim.sim_out.nmacs/sheet["C6"]
    end
end

num_nmacs_xr_blended_scaling_eu += sim.sim_out.nmacs
num_alerts_xr_blended_scaling_eu += sim.sim_out.alerts
if sim_out_display_results
    println("Blended w/ Scaling NMACs : ", sim.sim_out.nmacs)
    println("Blended w/ Scaling Alerts : ", sim.sim_out.alerts)
    println()
end

"""
-------------------------------------------
UAM vs. UAM (EE)
-------------------------------------------
"""
num_nmacs_unequipped_ee = 0

num_nmacs_h_ee = 0
num_alerts_h_ee = 0

num_nmacs_xr_vert_ee = 0
num_alerts_xr_vert_ee = 0

num_nmacs_xr_speed_ee = 0
num_alerts_xr_speed_ee = 0

num_nmacs_xr_speed_scaling_ee = 0
num_alerts_xr_speed_scaling_ee = 0

num_nmacs_xr_blended_ee = 0
num_alerts_xr_blended_ee = 0

num_nmacs_xr_blended_scaling_ee = 0
num_alerts_xr_blended_scaling_ee = 0

println("________Simulating UAM vs. UAM (EE)________")

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G6"] = sim.sim_out.nmacs
        sheet["H6"] = sim.sim_out.alerts
    end
end

num_nmacs_unequipped_ee += sim.sim_out.nmacs
if sim_out_display_results
    println("Unequipped NMACs : ", sim.sim_out.nmacs)
    println("Unequipped Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = heuristic_vert()
sim.acs[2] = heuristic_vert()
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G7"] = sim.sim_out.nmacs
        sheet["H7"] = sim.sim_out.alerts
        sheet["G15"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_h_ee += sim.sim_out.nmacs
num_alerts_h_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Hueristic NMACs : ", sim.sim_out.nmacs)
    println("Hueristic Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_vert(q_file = q_file)
sim.acs[2] = uam_vert(q_file = q_file)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G8"] = sim.sim_out.nmacs
        sheet["H8"] = sim.sim_out.alerts
        sheet["G16"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_xr_vert_ee += sim.sim_out.nmacs
num_alerts_xr_vert_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Vertical NMACs : ", sim.sim_out.nmacs)
    println("Vertical Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_speed(q_file = q_file_speed)
sim.acs[2] = uam_speed(q_file = q_file_speed)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G9"] = sim.sim_out.nmacs
        sheet["H9"] = sim.sim_out.alerts
        sheet["G17"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_xr_speed_ee += sim.sim_out.nmacs
num_alerts_xr_speed_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Speed NMACs : ", sim.sim_out.nmacs)
    println("Speed Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_speed(q_file = q_file_speed)
sim.acs[1].perform_scaling = true
sim.acs[2] = uam_speed(q_file = q_file_speed)
sim.acs[2].perform_scaling = true
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G10"] = sim.sim_out.nmacs
        sheet["H10"] = sim.sim_out.alerts
        sheet["G18"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_xr_speed_scaling_ee += sim.sim_out.nmacs
num_alerts_xr_speed_scaling_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Speed w/ Scaling NMACs : ", sim.sim_out.nmacs)
    println("Speed w/ Scaling Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
sim.acs[2] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G11"] = sim.sim_out.nmacs
        sheet["H11"] = sim.sim_out.alerts
        sheet["G19"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_xr_blended_ee += sim.sim_out.nmacs
num_alerts_xr_blended_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Blended NMACs : ", sim.sim_out.nmacs)
    println("Blended Alerts : ", sim.sim_out.alerts)
    println()
end

sim = simulation()
sim.sim_out = small_simulation_output()
sim.enc_file = enc_file
sim.acs[1] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
sim.acs[1].perform_scaling = true
sim.acs[2] = uam_blended(q_file_vert = q_file, q_file_speed = q_file_speed)
sim.acs[2].perform_scaling = true
xr_sim!(sim)

if sim_out_to_excel
    XLSX.openxlsx(output_filename, mode="rw") do xf
        sheet = xf[1]
        sheet["G12"] = sim.sim_out.nmacs
        sheet["H12"] = sim.sim_out.alerts
        sheet["G20"] = sim.sim_out.nmacs/sheet["G6"]
    end
end

num_nmacs_xr_blended_scaling_ee += sim.sim_out.nmacs
num_alerts_xr_blended_scaling_ee += sim.sim_out.alerts
if sim_out_display_results
    println("Blended w/ Scaling NMACs : ", sim.sim_out.nmacs)
    println("Blended w/ Scaling Alerts : ", sim.sim_out.alerts)
    println()
end
