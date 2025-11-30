# OpenLane config for ks_adder

# Top module name
set ::env(DESIGN_NAME) {ks_adder}

# All RTL sources
# (you can also use: set ::env(VERILOG_FILES) "dir::src/*.v")
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock/reset info
set ::env(CLOCK_PORT)   "clk"
set ::env(CLOCK_PERIOD) "10.0"   ;# in ns, change if needed

set ::env(RESET_PORT) "rst_n"
set ::env(RESET_ACTIVE_VALUE) 0  ;# active-low reset

# Stand-alone core
set ::env(DESIGN_IS_CORE) {1}

# ---------- Enable full signoff flow (like spm) ----------

# Needed for parasitics + multi-corner STA steps
set ::env(RUN_SPEF_EXTRACTION) 1

# IR-drop report (uses PDN + activity assumptions)
set ::env(RUN_IRDROP_REPORT) 1

# Magic-based views + GDS/LEF export
set ::env(RUN_MAGIC) 1

# KLayout GDS export
set ::env(RUN_KLAYOUT) 1

# XOR check between Magic GDS and KLayout GDS
set ::env(RUN_KLAYOUT_XOR) 1

# LVS using netgen (layout vs netlist)
set ::env(RUN_LVS) 1

# Magic DRC (signoff DRC)
set ::env(RUN_MAGIC_DRC) 1

# Optional: KLayout DRC (if you want both)
# set ::env(RUN_KLAYOUT_DRC) 1

# ERC / CVC (electrical rule check)
set ::env(RUN_CVC) 1

# ---------- Load tech-specific extra config if present ----------

set tech_specific_config "$::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl"
if { [file exists $tech_specific_config] == 1 } {
    source $tech_specific_config
}
