read_file -format sverilog {./ECE-551-End-of-Semester-Project/UART/uart_rx.sv ./ECE-551-End-of-Semester-Project/UART/uart_tx.sv ./ECE-551-End-of-Semester-Project/UART/UART.sv ./ECE-551-End-of-Semester-Project/UART/UART_wrapper.sv\
                            ./ECE-551-End-of-Semester-Project/UART/UART_prot.sv ./ECE-551-End-of-Semester-Project/SPI/SPI_RX.sv ./ECE-551-End-of-Semester-Project/Provided/prot_trig.sv ./ECE-551-End-of-Semester-Project/trigger_logic.sv ./ECE-551-End-of-Semester-Project/chnnl_trig.sv ./ECE-551-End-of-Semester-Project/Provided/trigger.sv\
                            ./ECE-551-End-of-Semester-Project/cmd_cfg.sv ./ECE-551-End-of-Semester-Project/capture.sv ./ECE-551-End-of-Semester-Project/channel_sample.sv ./ECE-551-End-of-Semester-Project/Provided/dig_core.sv\
                            ./ECE-551-End-of-Semester-Project/RAMqueue.sv ./ECE-551-End-of-Semester-Project/Provided/clk_rst_smpl.sv ./ECE-551-End-of-Semester-Project/PWM/pwm8.sv ./ECE-551-End-of-Semester-Project/PWM/dual_pwm8.sv\
                            ./ECE-551-End-of-Semester-Project/Provided/LA_dig.sv}
set current_design LA_dig

# instantiates the clk and smpl_clk signals #
create_clock -name "clk400MHz" -period 1 -waveform {0 0.5} {clk400MHz}
create_generated_clock -name "clk" -source [get_port clk400MHz] -divide_by 4 [get_pins iCLKRST/clk]
set_dont_touch_network [get_pins iCLKRST/clk]
create_generated_clock -name "smpl_clk" -source [get_port clk400MHz] -divide_by 1 [get_pins iCLKRST/smpl_clk]
set_dont_touch_network [find port clk400MHz]

set_dont_touch_network [get_pins iCLKRST/rst_n]


# setup pointer that contains all inputs other than clk #
set rst [find port RST_n]
set chn_int [remove_from_collection [all_inputs] [find port RX]]

set chn_inputs_temp [remove_from_collection $chn_int $rst]
set chn_inputs [remove_from_collection $chn_inputs_temp [find port locked]]

# set input delays and drive strength #
set_input_delay -clock smpl_clk 0.25 chn_inputs
set_input_delay -clock clk400MHz 0.25 rst_inputs
set_input_delay -clock clk 0.25 [find port RX]
set_driving_cell -lib_cell NAND2X1_LVT -library saed32lvt_tt0p85v25c [remove_from_collection $chn_inputs [find port rst_n]]

#set false paths
set_false_path -from [get_cell iDIG/iCMD/decimator]
set_false_path -from [get_cell iCOMM/first_byte]


# set output delay and load on all outputs #
set_output_delay -clock clk 0.5 [all_outputs]
set_load 50 [all_outputs]

# set max transition time for all nodes, and set drive for the rst_n signal #
set_drive 0.0001 rst_n
set_max_transition 0.15 [current_design]

# set wire load model #
set_wire_load_model -name 16000 -library saed32lvt_tt0p85v25c

# set clock uncertainty #
set_clock_uncertainty 0.2 iCLKRST/clk

# first compile #
compile -map_effort high
# flatten the design and compiles again #
ungroup -all -flatten
set_fix_hold clk
compile -map_effort high

# generates a min_delay, max_delay, and area report #
report_timing -delay min > min_timing.txt
report_timing -delay max > max_timing.txt


report_area > LA_dig_area.txt

write_sdc LA_dig_new.sdc
write -format verilog LA_dig -output LA_dig.vg
