##############################################################
# ks_adder.sdc  
#
# Instructions:
#   Substitute appropriate values for the variables in the "USER-SET PARAMETERS"
#   section (For ex. t=10, a=0, b=5). Every variable directly affects timing analysis:
#       - CLOCK_PERIOD_NS      → timing difficulty
#       - INPUT/OUTPUT delays  → external interface timing
#       - CLOCK_UNCERTAINTY    → jitter/skew margin
#
#   Do NOT modify commands below the variable section.
##############################################################

######################## USER-SET PARAMETERS ########################

# Clock settings
set CLOCK_PERIOD_NS       t          ;# Clock period (ns)
set CLOCK_WAVEFORM_RISE   a             ;# Clock rise edge (ns)
set CLOCK_WAVEFORM_FALL   b             ;# Clock fall edge (ns)

# Input delay values
set INPUT_DELAY_MAX_NS     c          ;# Latest allowed arrival
set INPUT_DELAY_MIN_NS     d          ;# Earliest arrival

# Output delay values
set OUTPUT_DELAY_MAX_NS    e
set OUTPUT_DELAY_MIN_NS    f

# Clock uncertainty
set CLOCK_UNCERTAINTY_NS   j         ;# Jitter/skew allowance

#####################################################################
#                DO NOT MODIFY BELOW THIS LINE
#####################################################################

##############################################################
# Clock definition
##############################################################

create_clock \
    -name clk \
    -period $CLOCK_PERIOD_NS \
    -waveform [list $CLOCK_WAVEFORM_RISE $CLOCK_WAVEFORM_FALL] \
    [get_ports clk]

##############################################################
# Input timing constraints
##############################################################

set_input_delay -clock clk -max $INPUT_DELAY_MAX_NS \
    [get_ports {a[*] b[*] cin}]

set_input_delay -clock clk -min $INPUT_DELAY_MIN_NS \
    [get_ports {a[*] b[*] cin}]

##############################################################
# Output timing constraints
##############################################################

set_output_delay -clock clk -max $OUTPUT_DELAY_MAX_NS \
    [get_ports {sum[*] cout}]

set_output_delay -clock clk -min $OUTPUT_DELAY_MIN_NS \
    [get_ports {sum[*] cout}]

##############################################################
# Clock uncertainty
##############################################################

set_clock_uncertainty $CLOCK_UNCERTAINTY_NS [get_clocks clk]

##############################################################
# Asynchronous reset handling
##############################################################

set_false_path -from [get_ports rst_n]

##############################################################
# End of ks_adder.sdc
##############################################################
