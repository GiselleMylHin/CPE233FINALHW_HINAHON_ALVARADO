`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/01/2025 12:22:59 PM
// Module Name: ALU
// Project Name:
// Target Devices:
//
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_FUN,
    output logic [31:0]  RESULT
    );
    
    always_comb begin
    case (ALU_FUN)
        0: RESULT = A + B;                 // add
        1: RESULT = A << B[4:0];           //sll
        2: RESULT = $signed(A) < $signed(B); 
        3: RESULT = A < B; 
        4: RESULT = A ^ B;                 //xor
        5: RESULT = A >> B[4:0];           //srl
        6: RESULT = A | B;                 //or
        7: RESULT = A & B;                 //and
        8: RESULT = $signed(A) - $signed(B);// subtract
        9: RESULT = A;                     //lui copy
        13: RESULT = $signed(A) >>> B[4:0]; //sra
        default: RESULT = 32'hdead;
    endcase 
    end
endmodule
