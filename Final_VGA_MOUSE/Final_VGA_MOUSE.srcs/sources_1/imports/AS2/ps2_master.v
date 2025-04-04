module ps2_master
(	
    input wire        i_sys_clk,      // System clock (50MHz typical)
    input wire        i_ps2_clk,      // PS2 device clock input
    input wire        i_sys_rst_n,    // Active-low system reset
    input wire        i_tx_en,        // Transmit enable signal
    input wire [7:0]  i_tx_data,      // Parallel data to transmit
    output reg        o_rx_en,        // Received data valid pulse
    output wire [7:0] o_rx_data,      // Received parallel data
    inout wire        o_ps2_clk,      // Bidirectional PS2 clock line
    inout wire        o_ps2_data      // Bidirectional PS2 data line
);

// Transmit FSM control signals
reg [3:0]  tx_fsm_state;             // Transmit state machine register
reg [3:0]  prev_tx_state;            // Previous transmit state for edge detection
reg [29:0] low_valid_shift;          // Shift register for clock line control
reg [7:0]  tx_data_buffer;           // Transmit data holding register
reg        serial_tx_data;           // Serialized transmit data output
wire       parity_bit;               // Calculated parity bit (odd parity)
wire       clk_out_enable;           // PS2 clock line output enable

// Receive logic signals
reg        prev_ps2_clk;             // Previous PS2 clock state for edge detection
reg        rx_start_detect;          // Start bit detection flag
reg [3:0]  rx_fsm_state;             // Receive state machine register
reg [7:0]  rx_data_buffer;           // Received data shift register
reg        rx_parity_reg;            // Accumulated parity during reception

// Parity generation: Odd parity for transmitted data
assign parity_bit = ~(^tx_data_buffer);

// PS2 bus control logic
assign clk_out_enable = (rx_fsm_state != 0 || tx_fsm_state != 0 || low_valid_shift != 0);
assign o_ps2_clk = (clk_out_enable) ? ((low_valid_shift != 0) ? 1'b0 : i_ps2_clk) : 1'bz;
assign o_ps2_data = (rx_fsm_state == 12) ? 1'b0 :     // ACK bit during reception
                   (tx_fsm_state != 0) ? serial_tx_data : 1'bz;  // Data during transmission

assign o_rx_data = rx_data_buffer;  // Connect receive buffer to output

//--------------------------------------------------------------
// Clock Line Control Logic
// Generates low pulse timing for clock inhibition during transmission
//--------------------------------------------------------------
always @(negedge i_sys_clk or negedge i_sys_rst_n) begin
    if (!i_sys_rst_n) begin
        prev_tx_state <= 0;
        low_valid_shift <= 0;
    end else begin
        prev_tx_state <= tx_fsm_state;  // Track state transitions
        // Create 30-cycle low pulse after transmission completion
        low_valid_shift <= {low_valid_shift[28:0], 
                          ((prev_tx_state == 11) && (tx_fsm_state == 0))};
    end
end

//--------------------------------------------------------------
// Start Bit Detection
// Detects falling edge on PS2 clock when bus is idle
//--------------------------------------------------------------
always @(posedge i_ps2_clk or negedge i_sys_rst_n) begin
    if (!i_sys_rst_n) begin
        prev_ps2_clk <= 1;
        rx_start_detect <= 0;
    end else begin
        prev_ps2_clk <= o_ps2_clk;  // Clock line state tracking
        // Detect start condition: clock low when in idle state
        rx_start_detect <= (rx_fsm_state == 0) ? 
                         ((o_ps2_clk == 0 && tx_fsm_state == 0) ? 1 : 0) : 0;
    end
end

//--------------------------------------------------------------
// Transmit Data Latching
// Captures parallel data when transmission is initiated
//--------------------------------------------------------------
always @(negedge i_ps2_clk or negedge i_sys_rst_n) begin
    if (!i_sys_rst_n) begin
        tx_data_buffer <= 0;
    end else begin
        // Latch new data or hold current value
        tx_data_buffer <= i_tx_en ? i_tx_data : tx_data_buffer;
    end
end

//--------------------------------------------------------------
// Transmit State Machine
// Serializes data with start bit, 8 data bits, parity, and stop bit
//--------------------------------------------------------------
always @(negedge i_ps2_clk or negedge i_sys_rst_n) begin
    if (!i_sys_rst_n) begin
        tx_fsm_state <= 0;
        serial_tx_data <= 1;  // Idle high state
    end else begin
        case (tx_fsm_state)
            // IDLE state: wait for transmit enable
            0: begin
                serial_tx_data <= 1;
                tx_fsm_state <= i_tx_en ? 1 : 0;
            end
            // START bit
            1: begin
                serial_tx_data <= 0;  // Start bit (low)
                tx_fsm_state <= 2;
            end
            // Data bits 0-7 (LSB first)
            2: begin serial_tx_data <= tx_data_buffer[0]; tx_fsm_state <= 3; end
            3: begin serial_tx_data <= tx_data_buffer[1]; tx_fsm_state <= 4; end
            4: begin serial_tx_data <= tx_data_buffer[2]; tx_fsm_state <= 5; end
            5: begin serial_tx_data <= tx_data_buffer[3]; tx_fsm_state <= 6; end
            6: begin serial_tx_data <= tx_data_buffer[4]; tx_fsm_state <= 7; end
            7: begin serial_tx_data <= tx_data_buffer[5]; tx_fsm_state <= 8; end
            8: begin serial_tx_data <= tx_data_buffer[6]; tx_fsm_state <= 9; end
            9: begin serial_tx_data <= tx_data_buffer[7]; tx_fsm_state <= 10; end
            // PARITY bit (odd)
            10: begin
                serial_tx_data <= parity_bit;
                tx_fsm_state <= 11;
            end
            // STOP bit (low) and return to idle
            11: begin
                serial_tx_data <= 0;  // Stop bit (low)
                tx_fsm_state <= 0;
            end
        endcase
    end
end

//--------------------------------------------------------------
// Receive State Machine
// Handles data reception with parity checking and ACK generation
//--------------------------------------------------------------
always @(negedge i_ps2_clk or negedge i_sys_rst_n) begin
    if (!i_sys_rst_n) begin
        rx_fsm_state <= 0;
        rx_data_buffer <= 0;
        rx_parity_reg <= 0;
        o_rx_en <= 0;
    end else begin
        o_rx_en <= 0;  // Default clear valid pulse
        
        case (rx_fsm_state)
            // IDLE: Wait for start condition
            0: begin
                rx_data_buffer <= 0;
                rx_parity_reg <= 0;
                if (rx_start_detect) rx_fsm_state <= 1;
            end
            // Verify START bit (low)
            1: begin
                rx_fsm_state <= (o_ps2_data == 0) ? 2 : 0;
            end
            // Shift in data bits 0-7 (LSB first)
            2: begin rx_data_buffer[0] <= o_ps2_data; rx_parity_reg <= o_ps2_data; rx_fsm_state <= 3; end
            3: begin rx_data_buffer[1] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 4; end
            4: begin rx_data_buffer[2] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 5; end
            5: begin rx_data_buffer[3] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 6; end
            6: begin rx_data_buffer[4] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 7; end
            7: begin rx_data_buffer[5] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 8; end
            8: begin rx_data_buffer[6] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 9; end
            9: begin rx_data_buffer[7] <= o_ps2_data; rx_parity_reg <= rx_parity_reg ^ o_ps2_data; rx_fsm_state <= 10; end
            // Verify PARITY bit (odd)
            10: begin
                rx_fsm_state <= (~rx_parity_reg == o_ps2_data) ? 11 : 11;  // Parity check
            end
            // Verify STOP bit (low)
            11: begin
                rx_fsm_state <= (o_ps2_data == 0) ? 12 : 12;  // Always proceed
            end
            // Generate ACK pulse
            12: begin
                o_rx_en <= 1;  // Data valid pulse
                rx_fsm_state <= 13;
            end
            // Return to IDLE
            13: rx_fsm_state <= 0;
        endcase
    end
end

endmodule