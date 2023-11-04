

# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/memristor_ctrl/sim/memristor_ctrl_tb.vhd


# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/memristor_ctrl/hdl/memristor_ctrl.vhd


