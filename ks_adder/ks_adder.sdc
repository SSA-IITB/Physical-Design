##############################################################
# ks_adder.sdc
# Simple, working SDC. Edit ONLY the USER-SET PARAMETERS block.
##############################################################

######################## USER-SET PARAMETERS ########################
# Clock (ns)
set CLOCK_PERIOD_NS         10.0      ;# target clock period
set CLOCK_WAVEFORM_RISE_NS  0.0       ;# clock rise position
set CLOCK_WAVEFORM_FALL_NS  5.0       ;# clock fall position

# Clock uncertainty (jitter + reconvergence component)
set CLOCK_JITTER_NS         0.02      ;# source jitter
set CLOCK_RECONV_NS         0.03      ;# reconvergence estimate

# Input / output external delays (ns)
set INPUT_DELAY_MAX_NS      0.5
set INPUT_DELAY_MIN_NS      0.0
set OUTPUT_DELAY_MAX_NS     0.5
set OUTPUT_DELAY_MIN_NS     0.0

# Clock latencies (ns)
set CLK_SOURCE_LATENCY_NS    0.0
set CLK_INSERTION_LATENCY_NS 0.0
###################################################################

# --------------------- DO NOT EDIT BELOW --------------------------

# Create primary clock on top port 'clk'
create_clock -name clk -period $CLOCK_PERIOD_NS \
    -waveform [list $CLOCK_WAVEFORM_RISE_NS $CLOCK_WAVEFORM_FALL_NS] \
    [get_ports clk]

# Clock source latency (model clock generator)
# (using -source is supported)
set_clock_latency -source $CLK_SOURCE_LATENCY_NS [get_clocks clk]

# Clock insertion latency (CTS / distribution)
set_clock_latency $CLK_INSERTION_LATENCY_NS [get_clocks clk]

# Combined clock uncertainty (jitter + reconvergence)
set combined_clk_unc [expr {$CLOCK_JITTER_NS + $CLOCK_RECONV_NS}]
set_clock_uncertainty $combined_clk_unc [get_clocks clk]

# Input delays (external)
set_input_delay -clock clk -max $INPUT_DELAY_MAX_NS \
    [get_ports {a[*] b[*] cin}]
set_input_delay -clock clk -min $INPUT_DELAY_MIN_NS \
    [get_ports {a[*] b[*] cin}]

# Output delays (external)
set_output_delay -clock clk -max $OUTPUT_DELAY_MAX_NS \
    [get_ports {sum[*] cout}]
set_output_delay -clock clk -min $OUTPUT_DELAY_MIN_NS \
    [get_ports {sum[*] cout}]

# Asynchronous reset: do not create timing paths through reset pin
set_false_path -from [get_ports rst_n]
set_false_path -to   [get_ports rst_n]

# Placeholder for generated clocks (uncomment if needed)
# create_generated_clock -name clk_div2 -source [get_pins divider/CLK] -divide_by 2 [get_pins divider/Q]

##############################################################
# End of ks_adder.sdc
##############################################################
