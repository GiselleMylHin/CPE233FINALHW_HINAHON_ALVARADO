`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/03/2025 09:13:22 PM
// Design Name: 
// Module Name: Branch_Addr_Gen
// Project Name: 
//
//////////////////////////////////////////////////////////////////////////////////


module Branch_Addr_Gen(
    input [31:0] pc,
    input [31:0] j_typ,
    input [31:0] b_typ,
    input [31:0]i_typ,rs1,
    output logic [31:0] jalr,
    output logic [31:0]jal,
    output logic [31:0]branch
    );
    
    always_comb begin
        branch = (pc + $signed(b_typ));         //Branch condition
        jal = ($signed(pc) + $signed(j_typ));   //JAL condition
        jalr = (rs1 + $signed(i_typ));          //JALR condition
    end
endmodule
