`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Aidan Stutz
// 
// Create Date: 11/07/2023 03:34:08 PM
// Design Name: 
// Module Name: CU_FSM
// Project Name: 
// 
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input RST,
    input INTR,
    input [6:0] opcode,
    input [2:0] opcode_2,
    input clk,
    output logic PCWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken,
    output logic mret_exec
    );
    
    typedef enum{ST_INIT, ST_FETCH, ST_EXEC, ST_WB} STATES;
    STATES PS, NS; 
    
    always_ff@(posedge clk) begin 
    if (RST == 1'b1)begin 
        PS <= ST_INIT; 
    end
    else begin 
        PS <= NS; 
    end
    end 
    
    always_comb begin
    //declare variables 
    PCWrite = 1'b0; 
    regWrite = 1'b0; 
    reset = 1'b0; 
    memWE2 = 1'b0; 
    memRDEN1 = 1'b0; 
    memRDEN2 = 1'b0;
    csr_WE = 1'b0;
    int_taken = 1'b0; 
    mret_exec = 1'b0;
    NS = ST_FETCH; 
    
    //present State case
    case(PS)
        ST_INIT: begin 
            NS = ST_FETCH; 
            reset = 1'b1; 
        end 
            
        ST_FETCH: begin 
            NS = ST_EXEC; 
            memRDEN1 = 1'b1; 
        end
        
        ST_WB: begin 
            PCWrite = 1'b1; 
            regWrite = 1'b1; 
            begin
                NS = ST_FETCH; 
            end
        end
        
        ST_EXEC: begin 
        PCWrite = 1'b1; 
            case(opcode) 
            7'b1110011:
                begin 
                case(opcode_2) 
                    3'b000: begin 
                        PCWrite = 1; 
                        mret_exec = 1; 
                        begin
                            NS = ST_FETCH; 
                                end
                    end 
                    3'b011: begin 
                        regWrite = 1; 
                        PCWrite = 1; 
                        begin
                            NS = ST_FETCH; 
                                end
                    end
                    3'b010: begin 
                        regWrite = 1;
                        PCWrite = 1;
                        begin
                            NS = ST_FETCH;
                               end
                    end  
                     
                    3'b001: begin 
                        regWrite = 1;
                        PCWrite = 1;

                        begin
                            NS = ST_FETCH;
                            end
                     end
                    
                endcase
                end
            
            7'b0110111: //lui
                begin 
                    regWrite = 1; 
                    PCWrite = 1;
                begin
                    NS = ST_FETCH; 
                end
                end
            7'b0010111: //auipc 
                begin
                regWrite = 1; 
                PCWrite = 1; 
                begin
                    NS = ST_FETCH; 
                end
                end
            7'b1101111: //jal
                begin 
                regWrite = 1; 
                PCWrite = 1; 
                begin
                    NS = ST_FETCH; 
                end
                end
            7'b1100111: // jalr type
                begin 
                regWrite = 1; 
                PCWrite = 1; 
                begin
                    NS = ST_FETCH; 
                end
                end
            7'b1100011: //b-type
                begin 
                    NS = ST_FETCH;
                PCWrite = 1; 
                end
            7'b0110011: //rtype
                begin 
                regWrite = 1; 
                PCWrite =1; 
                    NS = ST_FETCH; 
                end
            7'b0010011: //itype
                begin
                regWrite = 1; 
                PCWrite = 1; 
                    NS = ST_FETCH; 
                end
            7'b0100011: //stype
                begin
                memWE2 = 1; 
                PCWrite = 1; 
                    NS = ST_FETCH; 
                end
            7'b0000011:
                begin//load 
                NS = ST_WB; 
                memRDEN2 = 1; 
                PCWrite = 0;
                end
                
            default: 
                begin NS = ST_FETCH; end 
           
            endcase
            end
        
        default: 
            NS = ST_FETCH; 
        
    endcase
    end
endmodule


