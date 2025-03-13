## Clock signal (PS/2 Clock)
#set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports CLK_MOUSE]
#create_clock -period 20.000 -name ps2_clock_pin -waveform {0.000 5.000} -add [get_ports CLK_MOUSE]

### Data signal (PS/2 Data)
#set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports DATA_MOUSE]
### i think i forgot to add this line before lol
#set_property PULLTYPE PULLUP [get_ports CLK_MOUSE]


### Seven-Segment Display

### SEG_SELECT_IN (2-bit input)
### SEG_SELECT_IN (2-bit input)
#set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_IN[1] }]
#set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_IN[0] }]

### BIN_IN (4-bit input) - Assigned to switches SW3 - SW0
#set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { BIN_IN[3] }]
#set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports { BIN_IN[2] }]
#set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports { BIN_IN[1] }]
#set_property -dict { PACKAGE_PIN T5 IOSTANDARD LVCMOS33 } [get_ports { BIN_IN[0] }]

### DOT_IN (1-bit input)
#set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { DOT_IN }]

### SEG_SELECT_OUT (4-bit output)
#set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_OUT[3] }]
#set_property -dict { PACKAGE_PIN U3 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_OUT[2] }]
#set_property -dict { PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_OUT[1] }]
#set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports { SEG_SELECT_OUT[0] }]

### HEX_OUT (8-bit output) - Assigned to LED pins
#set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[7] }]
#set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[6] }]
#set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[5] }]
#set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[4] }]
#set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[3] }]
#set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[2] }]
#set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[1] }]
#set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { HEX_OUT[0] }]
## T16 DNE

#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseStatus[3]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseStatus[2]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseStatus[1]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseStatus[0]}]


#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[7]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[6]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[5]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[4]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[3]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[2]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[1]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseX[0]}]


#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[7]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[6]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[5]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[4]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[3]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[2]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[1]}]
#set_property -dict { PACKAGE_PIN xx IOSTANDARD LVCMOS33 } [get_ports {MouseY[0]}]


#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {MouseZ[0]}]

#set_property IOSTANDARD LVCMOS33 [get_ports SendInterrupt]


# USB (PS/2)
 set_property PACKAGE_PIN C17 [get_ports CLK_MOUSE]                        
    set_property IOSTANDARD LVCMOS33 [get_ports CLK_MOUSE]
    set_property PULLUP true [get_ports CLK_MOUSE]
 set_property PACKAGE_PIN B17 [get_ports DATA_MOUSE]                    
    set_property IOSTANDARD LVCMOS33 [get_ports DATA_MOUSE]    
    set_property PULLUP true [get_ports DATA_MOUSE]
     
# Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]       
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property PACKAGE_PIN U18 [get_ports RESET]     
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]
 
# 7Seg display 
set_property PACKAGE_PIN W7 [get_ports LED[0]]                    
    set_property IOSTANDARD LVCMOS33 [get_ports LED[0]]
set_property PACKAGE_PIN W6 [get_ports LED[1]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED[1]]
set_property PACKAGE_PIN U8 [get_ports LED[2]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED[2]]
set_property PACKAGE_PIN V8 [get_ports LED[3]]     
    set_property IOSTANDARD LVCMOS33 [get_ports LED[3]]
set_property PACKAGE_PIN U5 [get_ports LED[4]]              
    set_property IOSTANDARD LVCMOS33 [get_ports LED[4]]
set_property PACKAGE_PIN V5 [get_ports LED[5]]
    set_property IOSTANDARD LVCMOS33 [get_ports LED[5]]
set_property PACKAGE_PIN U7 [get_ports LED[6]]              
    set_property IOSTANDARD LVCMOS33 [get_ports LED[6]]
set_property PACKAGE_PIN V7 [get_ports LED[7]]                    
    set_property IOSTANDARD LVCMOS33 [get_ports LED[7]]

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
    
# Switches
#set_property PACKAGE_PIN R2 [get_ports SWITCHES[15]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[15]]
#set_property PACKAGE_PIN T1 [get_ports SWITCHES[14]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[14]]
#set_property PACKAGE_PIN U1 [get_ports SWITCHES[13]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[13]]
#set_property PACKAGE_PIN W2 [get_ports SWITCHES[12]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[12]]
#set_property PACKAGE_PIN R3 [get_ports SWITCHES[11]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[11]]
#set_property PACKAGE_PIN T2 [get_ports SWITCHES[10]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[10]]
#set_property PACKAGE_PIN T3 [get_ports SWITCHES[9]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[9]]
#set_property PACKAGE_PIN V2 [get_ports SWITCHES[8]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[8]]
#set_property PACKAGE_PIN W13 [get_ports SWITCHES[7]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[7]]
#set_property PACKAGE_PIN W14 [get_ports SWITCHES[6]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[6]]
#set_property PACKAGE_PIN V15 [get_ports SWITCHES[5]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[5]]
#set_property PACKAGE_PIN W15 [get_ports SWITCHES[4]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[4]]
#set_property PACKAGE_PIN W17 [get_ports SWITCHES[3]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[3]]
#set_property PACKAGE_PIN W16 [get_ports SWITCHES[2]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[2]]
#set_property PACKAGE_PIN V16 [get_ports SWITCHES[1]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[1]]
#set_property PACKAGE_PIN V17 [get_ports SWITCHES[0]]
#    set_property IOSTANDARD LVCMOS33 [get_ports SWITCHES[0]]
