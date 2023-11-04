
# -------------------------------------------------------
# 2.0) Add TB Package Files
# -------------------------------------------------------
#    * ModelSim



# -------------------------------------------------------
# 2.1) Add TB Files
# -------------------------------------------------------
#    * ModelSim
add_sim_file ./modules/nff_cdcc_fedge/sim/nff_cdcc_fedge_tb.vhd



# -------------------------------------------------------
# 1.0) Add SRC Package Files
# -------------------------------------------------------
#    * Vivado
#    * ModelSim


# -------------------------------------------------------
# 1.1) Add SRC HDL Files
# -------------------------------------------------------
#    * Vivado
add_src_file lib_src ./modules/nff_cdcc_fedge/hdl/nff_cdcc_fedge.vhd

#    * ModelSim
add_sim_file ./modules/nff_cdcc_fedge/hdl/nff_cdcc_fedge.vhd


