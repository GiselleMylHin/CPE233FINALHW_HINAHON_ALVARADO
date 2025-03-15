`timescale 1ns / 1ps
module SevSegDisp(

    input CLK,            // 100 MHz
    input MODE,           // 0 - Hex, 1 - Decimal
    input [15:0] DATA_IN,
    output [7:0] CATHODES,
    output [3:0] ANODES
    );

    logic [15:0] BCD_Val;
    logic [15:0] Hex_Val;
    
    // decimal values are converted to binary code decimal for displaying
    BCD BCDMod (.HEX(DATA_IN), .THOUSANDS(BCD_Val[15:12]),
                .HUNDREDS(BCD_Val[11:8]), .TENS(BCD_Val[7:4]),
                .ONES(BCD_Val[3:0]));
    
    // Cathode driver displays all values as 4-bit hex
    CathodeDriver CathMod (.HEX(Hex_Val), .CLK(CLK), .CATHODES(CATHODES),
                            .ANODES(ANODES));
    
    // MUX to switch between HEX and BCD input for Hex and Decimal display
    always_comb begin
        if (MODE == 1'b1)
            Hex_Val = BCD_Val;
        else
            Hex_Val = DATA_IN;
    end
    
    
endmodule
