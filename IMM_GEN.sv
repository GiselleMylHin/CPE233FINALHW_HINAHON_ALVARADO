`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/03/2025 12:26:13 PM
// Design Name: 
// Module Name: IMM_GEN
// Project Name: 
//
//////////////////////////////////////////////////////////////////////////////////


module IMM_GEN(
    input [31:0] INS,
    output logic [31:0] U_Typ,
    output logic [31:0] I_Typ,
    output logic [31:0] S_Typ,
    output logic [31:0] J_Typ,
    output logic [31:0] B_Typ
    );
    
    always_comb
    begin 
        U_Typ = {INS[31:12], 12'b0};                    //U-Type Instruction
        I_Typ = {{21{INS[31]}}, INS[30:20]};            //I-Type Instruction
        S_Typ = {{21{INS[31]}}, INS[30:25], INS[11:7]}; //S-Type Instruction    
        B_Typ = {{20{INS[31]}}, INS[7], INS[30:25], INS[11:8], 1'b0};   //B-Type Instruction
        J_Typ = {{12{INS[31]}}, INS[19:12], {INS[20]}, INS[30:21],1'b0};//J-Type Instruction
    end
endmodule
