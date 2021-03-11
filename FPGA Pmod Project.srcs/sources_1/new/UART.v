`timescale 1ns / 1ps

module UART(
    input clk, btn0, btn1, [7:0]sw,
    output reg TxD);

reg [3:0]bitCounter;            // Used to handle total bit transmission.
reg [13:0]counter;              // counter = clk / baud = 10415.
reg state, nextState;           // State holders for transmit.
reg [9:0]rightShiftRegister;    // UART data to shift out.
reg shift, load, clear;         // Needed signals for data handling.

// UART Transmit Handler
always @(posedge clk) begin
    if (btn0) begin             // btn0 will act as a reset switch.
        state <= 0;             // When state = 0, nothing will happen.
        counter <= 0;           // Reset the baud counter to 0.
        bitCounter <= 0;        // Reset the bit transmit counter.
        end
    else begin
        counter <= counter + 1;         // This counter generates the baud.
        if (counter >= 10415) begin     // If the counter reaches 9600 baud:
            state <= nextState;         // Swap states.
            counter <= 0;               // Reset the baud counter.
            
            if (load)                                   // load is altered later in the code.
                rightShiftRegister <= {1'b1, sw, 1'b0}; // StartBit, data, StopBit.
            if (clear)              // clear is altered later in the code.
                bitCounter <= 0;    // Reset the bitCounter.
            if (shift) begin                                    // shift is altered later in the code.
                rightShiftRegister <= rightShiftRegister >> 1;  // Shift the data as it is transmitted.
                bitCounter <= bitCounter + 1;                   // Increment the bitCounter.
                end
            end
        end
end

// Transmit, Don't Transmit State Handler
always @(posedge clk) begin
    load <= 0;
    shift <= 0;
    clear <= 0;
    TxD <= 1;       // TxD is mapped to the USB-RS232 Interface (active low).
    
    case (state)
        0: begin                // Don't Transmit State.
            if (btn1) begin     // btn1 acts as the transmit event trigger.
                nextState <= 1;
                load <= 1;      // Prepare to load data to transmit.
                shift <= 0;     // Not prepared to shift yet.
                clear <= 0;     // Do not clear counters.
                end
            else begin
                nextState <= 0;
                TxD <= 1;       // Don't want to transmit anything.
                end
        end
        1: begin                        // Transmit State.
            if (bitCounter >= 10) begin // See if transmission is complete.
                nextState <= 0;         
                clear <= 1;             // Want to clear counters.
                end
            else begin                          // Transmission not finished.
                nextState <= 1;                 // Remain in transmit state.
                TxD <= rightShiftRegister[0];   // Shift data to TxD.
                shift <= 1;                     // Continue shifting data.
                end
            end
        default: nextState <= 0;    // Just catches the default case.
    endcase
end

endmodule
