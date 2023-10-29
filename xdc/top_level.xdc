# mclk is from the 100 MHz oscillator on Urbana Boad

#set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {clk_100mhz}]
#create_clock -add -name gclk -period 10.000 -waveform {0 4} [get_ports {clk_100mhz}]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# USER GREEN LEDS
# set_property -dict {PACKAGE_PIN C13  IOSTANDARD LVCMOS33} [ get_ports {led[0]} ]
# set_property -dict {PACKAGE_PIN C14  IOSTANDARD LVCMOS33} [ get_ports {led[1]} ]
# set_property -dict {PACKAGE_PIN D14  IOSTANDARD LVCMOS33} [ get_ports {led[2]} ]
# set_property -dict {PACKAGE_PIN D15  IOSTANDARD LVCMOS33} [ get_ports {led[3]} ]
# set_property -dict {PACKAGE_PIN D16  IOSTANDARD LVCMOS33} [ get_ports {led[4]} ]
# set_property -dict {PACKAGE_PIN F18  IOSTANDARD LVCMOS33} [ get_ports {led[5]} ]
# set_property -dict {PACKAGE_PIN E17  IOSTANDARD LVCMOS33} [ get_ports {led[6]} ]
# set_property -dict {PACKAGE_PIN D17  IOSTANDARD LVCMOS33} [ get_ports {led[7]} ]
# set_property -dict {PACKAGE_PIN C17  IOSTANDARD LVCMOS33} [ get_ports {led[8]} ]
# set_property -dict {PACKAGE_PIN B18  IOSTANDARD LVCMOS33} [ get_ports {led[9]} ]
# set_property -dict {PACKAGE_PIN A17  IOSTANDARD LVCMOS33} [ get_ports {led[10]} ]
# set_property -dict {PACKAGE_PIN B17  IOSTANDARD LVCMOS33} [ get_ports {led[11]} ]
# set_property -dict {PACKAGE_PIN C18  IOSTANDARD LVCMOS33} [ get_ports {led[12]} ]
# set_property -dict {PACKAGE_PIN D18  IOSTANDARD LVCMOS33} [ get_ports {led[13]} ]
# set_property -dict {PACKAGE_PIN E18  IOSTANDARD LVCMOS33} [ get_ports {led[14]} ]
# set_property -dict {PACKAGE_PIN G17  IOSTANDARD LVCMOS33} [ get_ports {led[15]} ]

set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {rgb0[0]}];
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {rgb0[1]}];
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {rgb0[2]}];
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {rgb1[0]}];
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports {rgb1[1]}];
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {rgb1[2]}];

## USER PUSH BUTTON
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [ get_ports "sys_rst" ]
# set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [ get_ports "btn[1]" ]
# set_property -dict {PACKAGE_PIN G2  IOSTANDARD LVCMOS33} [ get_ports "btn[2]" ]
# set_property -dict {PACKAGE_PIN H2  IOSTANDARD LVCMOS33} [ get_ports "btn[3]" ]

## USER SLIDE SWITCH
set_property -dict {PACKAGE_PIN G1  IOSTANDARD LVCMOS33} [ get_ports "sw[0]" ]
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [ get_ports "sw[1]" ]
set_property -dict {PACKAGE_PIN F1  IOSTANDARD LVCMOS33} [ get_ports "sw[2]" ]
set_property -dict {PACKAGE_PIN E2  IOSTANDARD LVCMOS33} [ get_ports "sw[3]" ]
set_property -dict {PACKAGE_PIN E1  IOSTANDARD LVCMOS33} [ get_ports "sw[4]" ]
set_property -dict {PACKAGE_PIN D2  IOSTANDARD LVCMOS33} [ get_ports "sw[5]" ]
set_property -dict {PACKAGE_PIN D1  IOSTANDARD LVCMOS33} [ get_ports "sw[6]" ]
set_property -dict {PACKAGE_PIN C2  IOSTANDARD LVCMOS33} [ get_ports "sw[7]" ]
set_property -dict {PACKAGE_PIN B2  IOSTANDARD LVCMOS33} [ get_ports "sw[8]" ]
# set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [ get_ports "sw[9]" ]
# set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [ get_ports "sw[10]" ]
# set_property -dict {PACKAGE_PIN A6  IOSTANDARD LVCMOS33} [ get_ports "sw[11]" ]
# set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33} [ get_ports "sw[12]" ]
# set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [ get_ports "sw[13]" ]
# set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS33} [ get_ports "sw[14]" ]
# set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [ get_ports "sw[15]" ]
#
### USER SEVEN SEGMENT DISPLAY HIGH SIDE DRIVE ACTIVE LOW
# set_property -dict {PACKAGE_PIN B3  IOSTANDARD LVCMOS33} [ get_ports "ss0_an[0]"]
# set_property -dict {PACKAGE_PIN C3  IOSTANDARD LVCMOS33} [ get_ports "ss0_an[1]"]
# set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33} [ get_ports "ss0_an[2]"]
# set_property -dict {PACKAGE_PIN G6  IOSTANDARD LVCMOS33} [ get_ports "ss0_an[3]"]
#
# set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [ get_ports "ss1_an[0]"]
# set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [ get_ports "ss1_an[1]"]
# set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [ get_ports "ss1_an[2]"]
# set_property -dict {PACKAGE_PIN E4  IOSTANDARD LVCMOS33} [ get_ports "ss1_an[3]"]
#
### USER SEVEN SEGMENT DISPLAY LOW SIDE DRIVE ACTIVE LOW
# set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[0]"]
# set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[1]"]
# set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[2]"]
# set_property -dict {PACKAGE_PIN C5  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[3]"]
# set_property -dict {PACKAGE_PIN D7  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[4]"]
# set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[5]"]
# set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS33} [ get_ports "ss0_c[6]"]
##set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS33} [ get_ports "ss0_cdp"]
#
# set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[0]"]
# set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[1]"]
# set_property -dict {PACKAGE_PIN J3  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[2]"]
# set_property -dict {PACKAGE_PIN H4  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[3]"]
# set_property -dict {PACKAGE_PIN F4  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[4]"]
# set_property -dict {PACKAGE_PIN H3  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[5]"]
# set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[6]"]
#set_property -dict {PACKAGE_PIN J4  IOSTANDARD LVCMOS33} [ get_ports "ss1_c[7]"]





set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
