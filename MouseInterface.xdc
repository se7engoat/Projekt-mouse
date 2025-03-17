## Clock signal (PS/2 Clock)
#set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports CLK_MOUSE]
#create_clock -period 20.000 -name ps2_clock_pin -waveform {0.000 5.000} -add [get_ports CLK_MOUSE]

### Data signal (PS/2 Data)
#set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports DATA_MOUSE]
### i think i forgot to add this line before lol
#set_property PULLTYPE PULLUP [get_ports CLK_MOUSE]




# USB (PS/2)
 set_property PACKAGE_PIN C17 [get_ports CLK_MOUSE]                        
    set_property IOSTANDARD LVCMOS33 [get_ports CLK_MOUSE]
    create_clock -period 20.000 -name CLK_MOUSE -waveform {0.000 5.000} -add [get_ports CLK_MOUSE]
    set_property PULLUP true [get_ports CLK_MOUSE]
 set_property PACKAGE_PIN B17 [get_ports DATA_MOUSE]                    
    set_property IOSTANDARD LVCMOS33 [get_ports DATA_MOUSE]    
    set_property PULLUP true [get_ports DATA_MOUSE]
     
# Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]       
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
    create_clock -period 10.000 -name CLK -waveform {0.000 5.000} -add [get_ports CLK]
set_property PACKAGE_PIN U18 [get_ports RESET]     
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]
 
# 7Seg display 
set_property PACKAGE_PIN W7 [get_ports LED_OUT[0]]                    
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[0]]
set_property PACKAGE_PIN W6 [get_ports LED_OUT[1]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[1]]
set_property PACKAGE_PIN U8 [get_ports LED_OUT[2]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[2]]
set_property PACKAGE_PIN V8 [get_ports LED_OUT[3]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[3]]
set_property PACKAGE_PIN U5 [get_ports LED_OUT[4]]              
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[4]]
set_property PACKAGE_PIN V5 [get_ports LED_OUT[5]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[5]]
set_property PACKAGE_PIN U7 [get_ports LED_OUT[6]]              
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[6]]
set_property PACKAGE_PIN V7 [get_ports LED_OUT[7]]                    
    set_property IOSTANDARD LVCMOS33 [get_ports LED_OUT[7]]

set_property PACKAGE_PIN U2 [get_ports SEG_SELECT[0]]                    
    set_property IOSTANDARD LVCMOS33 [get_ports SEG_SELECT[0]]
set_property PACKAGE_PIN U4 [get_ports SEG_SELECT[1]]              
    set_property IOSTANDARD LVCMOS33 [get_ports SEG_SELECT[1]]
set_property PACKAGE_PIN V4 [get_ports SEG_SELECT[2]]     
    set_property IOSTANDARD LVCMOS33 [get_ports SEG_SELECT[2]]
set_property PACKAGE_PIN W4 [get_ports SEG_SELECT[3]]
    set_property IOSTANDARD LVCMOS33 [get_ports SEG_SELECT[3]]
   
   
# LEDS
set_property PACKAGE_PIN L1 [get_ports LED_LIGHTS[15]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[15]]
set_property PACKAGE_PIN P1 [get_ports LED_LIGHTS[14]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[14]]
set_property PACKAGE_PIN N3 [get_ports LED_LIGHTS[13]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[13]]
set_property PACKAGE_PIN P3 [get_ports LED_LIGHTS[12]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[12]]
set_property PACKAGE_PIN U3 [get_ports LED_LIGHTS[11]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[11]]
set_property PACKAGE_PIN W3 [get_ports LED_LIGHTS[10]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[10]]
set_property PACKAGE_PIN V3 [get_ports LED_LIGHTS[9]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[9]]
set_property PACKAGE_PIN V13 [get_ports LED_LIGHTS[8]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[8]]
set_property PACKAGE_PIN V14 [get_ports LED_LIGHTS[7]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[7]]
set_property PACKAGE_PIN U14 [get_ports LED_LIGHTS[6]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[6]]
set_property PACKAGE_PIN U15 [get_ports LED_LIGHTS[5]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[5]]
set_property PACKAGE_PIN W18 [get_ports LED_LIGHTS[4]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[4]]
set_property PACKAGE_PIN V19 [get_ports LED_LIGHTS[3]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[3]]
set_property PACKAGE_PIN U19 [get_ports LED_LIGHTS[2]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[2]]
set_property PACKAGE_PIN E19 [get_ports LED_LIGHTS[1]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[1]]
set_property PACKAGE_PIN U16 [get_ports LED_LIGHTS[0]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED_LIGHTS[0]]
    
