`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/02/2025 09:12:53 AM
// Design Name: 
// Module Name: pc_counter
// Project Name: 
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_counter(
    input PC_WRITE,
    input PC_RST, 
    input [31:0] PC_DIN, 
    input clk, 
    output logic [31:0] PC_COUNT
    );
    
    always_ff @ (posedge clk) //always block for PC_COUNT, increments
    begin
        if (PC_RST == 1)
            begin   
            PC_COUNT <= 32'b0;
            end
        else if (PC_WRITE == 1)
            begin 
            PC_COUNT <= PC_DIN;
            end 
        else
            begin
            PC_COUNT <= PC_COUNT; 
            end
    end  
endmodule
