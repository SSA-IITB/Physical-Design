##############################################################
# wallace.sdc — SDC for 32x32 Wallace multiplier
#
# Edit ONLY the USER-SET PARAMETERS section below to run simulations.
# Ports expected at top-level:
#   - clk            (clock)
#   - a[31:0]        (multiplicand)
#   - b[31:0]        (multiplier)
#   - out[63:0]      (registered 64-bit output)
#
# This SDC is compatible with OpenSTA/OpenLane (uses a*, b*, out* syntax).
##############################################################

######################## USER-SET PARAMETERS ########################
# Clock
set CLOCK_PERIOD_NS       10.0        ;# clock period in ns (10 ns => 100 MHz)
set CLK_WAVE_RISE_NS      0.0
set CLK_WAVE_FALL_NS      [expr {$CLOCK_PERIOD_NS/2.0}]

# Input delays (external -> capture)
set INPUT_DELAY_MAX_NS    2.0         ;# worst-case external arrival to inputs
set INPUT_DELAY_MIN_NS    0.0         ;# earliest arrival (hold)

# Output delays (internal launch -> external capture)
set OUTPUT_DELAY_MAX_NS   2.0
set OUTPUT_DELAY_MIN_NS   0.0

# Clock uncertainty / jitter (reduces available timing budget)
set CLOCK_UNCERT_NS       0.05        ;# 50 ps

#################################################################
# DO NOT MODIFY BELOW THIS LINE (unless you know what you're doing)
#################################################################

##############################################################
# Primary clock definition
# - create_clock defines the timing reference used by STA.
# - waveform uses rise and fall so tools compute launch/capture edges.
##############################################################
create_clock -name clk \
    -period $CLOCK_PERIOD_NS \
    -waveform [list $CLK_WAVE_RISE_NS $CLK_WAVE_FALL_NS] \
    [get_ports clk]

##############################################################
# Input timing constraints
# - Model external input arrival windows relative to clk.
# - Use OpenSTA-safe port wildcards (a*, b*, etc.).
##############################################################

# a[31:0] inputs
set_input_delay -clock clk -max $INPUT_DELAY_MAX_NS [get_ports a*]
set_input_delay -clock clk -min $INPUT_DELAY_MIN_NS [get_ports a*]

# b[31:0] inputs
set_input_delay -clock clk -max $INPUT_DELAY_MAX_NS [get_ports b*]
set_input_delay -clock clk -min $INPUT_DELAY_MIN_NS [get_ports b*]

# No explicit cin in this design; if you add external control inputs, add them here.

##############################################################
# Output timing constraints
# - out[63:0] is registered on clk at the output stage (we model external capture).
##############################################################
set_output_delay -clock clk -max $OUTPUT_DELAY_MAX_NS [get_ports out*]
set_output_delay -clock clk -min $OUTPUT_DELAY_MIN_NS [get_ports out*]

##############################################################
# Clock uncertainty (jitter + skew margin)
# - Increasing this makes timing closure harder (safe margin).
##############################################################
set_clock_uncertainty $CLOCK_UNCERT_NS [get_clocks clk]

##############################################################
# Input transition times (slew assumptions)
# - Affects cell delay lookup & buffer insertion decisions.
# - Numeric-first format is used for compatibility.
##############################################################
# a bus slew
set_input_transition 0.8 -min  -rise [get_ports a*]
set_input_transition 0.8 -min  -fall [get_ports a*]
set_input_transition 0.8 -max  -rise [get_ports a*]
set_input_transition 0.8 -max  -fall [get_ports a*]

# b bus slew
set_input_transition 0.8 -min  -rise [get_ports b*]
set_input_transition 0.8 -min  -fall [get_ports b*]
set_input_transition 0.8 -max  -rise [get_ports b*]
set_input_transition 0.8 -max  -fall [get_ports b*]

##############################################################
# Asynchronous reset handling
# - If a reset pin exists (rst or rst_n), mark paths launched from/to it as false paths
#   so reset toggles do not create spurious timing violations.
##############################################################
if {[llength [get_ports rst]]} {
    set_false_path -from [get_ports rst]
    set_false_path -to   [get_ports rst]
}
if {[llength [get_ports rst_n]]} {
    set_false_path -from [get_ports rst_n]
    set_false_path -to   [get_ports rst_n]
}

##############################################################
# Notes:
# - To relax timing, increase CLOCK_PERIOD_NS or increase INPUT_DELAY_MAX_NS / OUTPUT_DELAY_MAX_NS.
# - For deterministic experiments, change only one USER variable at a time.
# - If your tool complains about port names, verify top-level port names in the Verilog
#   (a, b, clk, out). If ports are named differently, update the get_ports patterns.
##############################################################

# End of wallace.sdc
