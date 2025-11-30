# -------------------------------------------------------------
# OpenLane config for clocked full adder (fa)
# -------------------------------------------------------------

# Top module name
set ::env(DESIGN_NAME) "fa"

# RTL source files
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock definition (REAL clock)
set ::env(CLOCK_PORT)   "clk"
set ::env(CLOCK_PERIOD) "10.0"  ;# ns

# This is a tiny block → better to treat as standalone core
set ::env(DESIGN_IS_CORE) 1

# -------------------------------------------------------------
# Floorplan & PDN settings (important for tiny blocks)
# -------------------------------------------------------------

# Use absolute die size to avoid auto-shrinking/pitch issues
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 50 50"     ;# 50µm × 50µm core area

# Low utilization gives tools freedom for CTS + routing
set ::env(FP_CORE_UTIL) 20

# Disable PDN auto-adjust (forces valid pitch)
set ::env(FP_PDN_AUTO_ADJUST) 0

# Safe pitches for sky130 (min allowed ~6.6µm)
set ::env(FP_PDN_VPITCH) 10
set ::env(FP_PDN_HPITCH) 10

# -------------------------------------------------------------
# Flow switches (lightweight but complete)
# -------------------------------------------------------------

# Enable CTS (needed since we have clk)
set ::env(RUN_CTS) 1

# Multi-corner STA is fine
set ::env(RUN_STA) 1

# Keep flow simple:
set ::env(RUN_SPEF_EXTRACTION) 0
set ::env(RUN_IRDROP_REPORT)   0
set ::env(RUN_CVC)             0
set ::env(RUN_KLAYOUT_XOR)     0
set ::env(RUN_KLAYOUT_DRC)     0

# Standard signoff
set ::env(RUN_MAGIC)        1
set ::env(RUN_MAGIC_DRC)    1
set ::env(RUN_KLAYOUT)      1
set ::env(RUN_LVS)          1

# -------------------------------------------------------------
# Tech-specific config (safe to keep)
# -------------------------------------------------------------

set tech_cfg "$::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl"
if { [file exists $tech_cfg] } {
    source $tech_cfg
}
