`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/02/2025 11:25:13 AM
// Module Name: reg_file
// Project Name:
// 
//////////////////////////////////////////////////////////////////////////////////

module reg_file(
    input [4:0] RF_ADR1,
    input [4:0] RF_ADR2,
    input [4:0] RF_WA,
    input logic [31:0] RF_WD,
    input RF_EN,
    input clk,
    output logic [31:0] RF_RS1,
    output logic [31:0] RF_RS2
    );
    
    logic [31:0] ram [0:31];     
    
    //reading from registers
    initial begin
    //initialize registers and their location
    for (int i=0; i<32; i=i+1) begin 
       ram[i]=32'b0; 
    end
    end  
  
    //Reading from ADR1
    assign RF_RS1 = ram[RF_ADR1];  //from adr1 
    assign RF_RS2 = ram[RF_ADR2];  //from adr2
 
    //Writing to WD_AD
    always_ff @(posedge clk)
    begin
    if (RF_EN ==1 && RF_WA != 5'b0)begin //if enable = 1 && not writing to x0
        ram[RF_WA]<= RF_WD;
        end
    end
    
endmodule
