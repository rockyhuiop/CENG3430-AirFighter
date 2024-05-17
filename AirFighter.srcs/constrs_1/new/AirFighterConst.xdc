set_property PACKAGE_PIN Y21  [get_ports {blue[0]}];  # "VGA-B0" 
set_property PACKAGE_PIN Y20  [get_ports {blue[1]}];  # "VGA-B1" 
set_property PACKAGE_PIN AB20 [get_ports {blue[2]}];  # "VGA-B2" 
set_property PACKAGE_PIN AB19 [get_ports {blue[3]}];  # "VGA-B3" 
set_property PACKAGE_PIN AB22 [get_ports {green[0]}];  # "VGA-G0" 
set_property PACKAGE_PIN AA22 [get_ports {green[1]}];  # "VGA-G1" 
set_property PACKAGE_PIN AB21 [get_ports {green[2]}];  # "VGA-G2" 
set_property PACKAGE_PIN AA21 [get_ports {green[3]}];  # "VGA-G3" 
set_property PACKAGE_PIN V20  [get_ports {red[0]}];  # "VGA-R0" 
set_property PACKAGE_PIN U20  [get_ports {red[1]}];  # "VGA-R1" 
set_property PACKAGE_PIN V19  [get_ports {red[2]}];  # "VGA-R2" 
set_property PACKAGE_PIN V18  [get_ports {red[3]}];  # "VGA-R3" 
set_property PACKAGE_PIN AA19 [get_ports {hsync}];  # "VGA-HS" 
set_property PACKAGE_PIN Y19  [get_ports {vsync}];  # "VGA-VS" 
set_property PACKAGE_PIN T18  [get_ports btnU];  
set_property PACKAGE_PIN R16  [get_ports btnD];  
set_property PACKAGE_PIN N15  [get_ports btnL];  
set_property PACKAGE_PIN R18  [get_ports btnR];  
set_property PACKAGE_PIN P16  [get_ports reset];
set_property PACKAGE_PIN AB6 [get_ports btn1];  # "JC1_N"
set_property PACKAGE_PIN AA4 [get_ports btn3];  # "JC2_N"

set_property PACKAGE_PIN Y11 [get_ports {ssd[6]}];
set_property PACKAGE_PIN AA11 [get_ports {ssd[5]}];
set_property PACKAGE_PIN Y10 [get_ports {ssd[4]}];
set_property PACKAGE_PIN AA9 [get_ports {ssd[3]}];
set_property PACKAGE_PIN W12 [get_ports {ssd[2]}];
set_property PACKAGE_PIN W11 [get_ports {ssd[1]}];
set_property PACKAGE_PIN V10 [get_ports {ssd[0]}];
set_property PACKAGE_PIN W8 [get_ports {sel}];

set_property IOSTANDARD LVCMOS33 [get_ports ssd];
set_property IOSTANDARD LVCMOS33 [get_ports sel];



# All VGA pins are connected by bank 33, so specified 3.3V together. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]; 

set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "clk" 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets reset]

set_property IOSTANDARD LVCMOS25 [get_ports btnU];
set_property IOSTANDARD LVCMOS25 [get_ports btnD];
set_property IOSTANDARD LVCMOS25 [get_ports btnL];
set_property IOSTANDARD LVCMOS25 [get_ports btnR];
set_property IOSTANDARD LVCMOS33 [get_ports btn1];
set_property IOSTANDARD LVCMOS33 [get_ports btn3];
set_property IOSTANDARD LVCMOS25 [get_ports reset];