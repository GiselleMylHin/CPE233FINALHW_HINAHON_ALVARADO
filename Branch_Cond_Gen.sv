`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Zachary Alvarado
// 
// Create Date: 03/02/2025 03:28:14 PM
// Design Name: 
// Module Name: Branch_Cond_Gen
// Project Name:
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////


module Branch_Cond_Gen(
    input [31:0] rs1,
    input [31:0] rs2,
    output logic br_eq,
    output logic br_ltu,
    output logic br_lt
    );
 
    assign br_eq =(rs1==rs2);                       //Equals Branch
    assign br_ltu = (rs1 < rs2);                    //Less Than Unsigned Branch
    assign br_lt = ($signed(rs1) < $signed(rs2));   //Less Than Signed Branch
endmodule
