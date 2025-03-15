`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/03/2025 04:10:56 PM
// Design Name: 
// Module Name: CU_DCDR
// Project Name: 
//
//////////////////////////////////////////////////////////////////////////////////


module CU_DCDR(
    input [6:0] opcode,
    input [2:0] opcode2, 
    input ir30,
    input int_taken,
    input br_eq,
    input br_lt,
    input br_ltu,
    output logic [3:0] alu_fun,
    output logic [1:0] alu_srcA,
    output logic [2:0] alu_srcB,
    output logic [2:0] pcSource,
    output logic [1:0] rf_wr_sel
    );
    
    always_comb begin 
        pcSource = 3'b0; 
        alu_srcA = 2'b0; 
        alu_srcB = 4'b0; 
        rf_wr_sel = 2'b00;
        alu_fun = 4'b0000;
    
    if (int_taken) //Check for Interrupt
        pcSource = 4;
    else
        case (opcode)
            //CSR
            7'b1110011:
                begin 
                case(opcode2)           
                    3'b000: //mret
                    begin 
                        pcSource = 3'h5; 
                    end
                    
                    3'b001: //csrrw 
                    begin
                        pcSource = 3'b0; 
                        alu_srcA = 2'b0; 
                        alu_fun = 4'b1001;
                        rf_wr_sel = 1;
                    end
                    
                    3'b011: //csrrc
                    begin 
                        rf_wr_sel = 1;
                        alu_fun = 4'b0111;
                        pcSource = 0;
                        alu_srcA = 2;
                        alu_srcB = 4;
                    end 
                    
                    3'b010: //csrrs
                    begin 
                        rf_wr_sel = 1;
                        alu_fun = 4'b0110;
                        pcSource = 0;
                        alu_srcA = 0;
                        alu_srcB = 4;
                    end 
                endcase    
                end  
                
            //lui (U-Type)
            7'b0110111: 
                begin 
                    alu_fun = 4'b1001; 
                    alu_srcA = 2'b1; 
                    pcSource = 3'b0; 
                    rf_wr_sel = 2'b11; 
                end
            
            //auipc (U-type)    
            7'b0010111: 
                begin
                    alu_srcA = 2'b1; 
                    alu_srcB = 3'b011; 
                    alu_fun = 4'b0;
                    rf_wr_sel = 2'b11; 
                end
                
            //jal    
            7'b1101111: 
                begin 
                    rf_wr_sel = 2'b0; 
                    pcSource = 3'b11;
                end
            
            // jalr type    
            7'b1100111: 
                begin 
                    rf_wr_sel = 2'b0; 
                    pcSource = 3'b01; 
                end
                
            //stype    
            7'b0100011: 
                begin
                    alu_srcA = 2'b00; 
                    alu_srcB = 2'b10; 
                    pcSource = 3'b00; 
                end
                
            //load     
            7'b0000011:
                begin
                    alu_srcB = 1'b1; 
                    rf_wr_sel = 2'b10; 
                end    
                
            7'b1100011: //b-type
                begin 
                case (opcode2)
                3'b000: //equal branch
                    begin 
                    if (br_eq)
                        pcSource = 3'b10;
                    else
                        pcSource = 3'b00;
                    end
                3'b001: //bne
                    begin
                    if (br_eq == 0)
                        pcSource = 3'b10;
                    else
                        pcSource = 3'b00;
                    end
                3'b100: //blt
                    begin 
                    if (br_lt)
                        pcSource = 3'b10; 
                    else 
                        pcSource = 3'b00; 
                    end
                3'b101: //bge 
                    begin 
                    if (br_lt == 0 | br_eq == 1)
                        pcSource = 3'b10; 
                    else 
                        pcSource = 3'b00;
                    end
                3'b110: //bltu
                    begin 
                    if (br_ltu) 
                        pcSource = 3'b10; 
                    else 
                        pcSource = 3'b00; 
                    end
                3'b111: //bgue
                    begin 
                    if (br_ltu == 0) 
                        pcSource = 3'b10; 
                    else
                        pcSource = 3'b00; 
                    end
                endcase
                end
                
            7'b0110011: //rtype/oprg3
                begin 
                case (opcode2) 
                3'b000: //add/sub
                    case (ir30)
                        1'b0: //add
                        begin 
                            rf_wr_sel =2'b11; 
                        end 
                        1'b1: //sub
                        begin 
                            alu_fun = 4'b1000; 
                            rf_wr_sel = 2'b11; 
                        end 
                    endcase
                3'b001: //sll
                    begin 
                        alu_fun = 4'b0001; 
                        rf_wr_sel = 2'b11; 
                    end
                3'b010: //slt
                    begin 
                        alu_fun = 4'b0010; 
                        rf_wr_sel = 2'b11; 
                    end 
                3'b011: //sltu
                   begin 
                        alu_fun = 4'b0011; 
                        rf_wr_sel = 2'b11; 
                   end
               3'b100: //xor
                   begin 
                        alu_fun = 4'b0100; 
                        rf_wr_sel = 2'b11; 
                   end
               3'b110: //or
                   begin 
                        alu_fun = 4'b0110; 
                        rf_wr_sel = 2'b11; 
                   end
                   
               3'b101: //sra/srl
                begin 
                    case(ir30)
                    1'b1: begin //sra
                        alu_fun = 4'b1101; 
                        rf_wr_sel = 2'b11; 
                        end
                    1'b0: //srl
                    begin
                        alu_fun = 4'b0101; 
                        rf_wr_sel = 2'b11; 
                    end 
                    endcase
               end
               3'b111: // and 
               begin 
                alu_fun = 4'b0111; 
                rf_wr_sel = 2'b11; 
               end 
              endcase
              end    
                
            7'b0010011: //itype/opimm
                begin
                case (opcode2) 
                3'b111: //andi
                begin
                    alu_fun = 4'b0111;
                    alu_srcB = 2'b01; 
                    rf_wr_sel = 2'b11; 
                end 
                
                3'b000: //addi
                begin
                    alu_fun = 4'b0000;
                    alu_srcA= 1'b0; 
                    alu_srcB= 2'b01; 
                    rf_wr_sel = 2'b11; 
                end 
                
                3'b110: //ori
                begin 
                    alu_fun = 4'b0110; 
                    alu_srcB= 2'b01; 
                    rf_wr_sel = 2'b11;
                end
                
                3'b001: //slli
                begin
                    alu_fun = 4'b0001; 
                    alu_srcB = 2'b01; 
                    rf_wr_sel= 2'b11;
                end
                
                3'b010: //slti
                begin   
                    alu_fun = 4'b0010; 
                    alu_srcB = 2'b01; 
                    rf_wr_sel = 2'b11;
                end  
                
                3'b011: //sltiu
                begin 
                    alu_fun = 4'b0011; 
                    alu_srcB = 2'b01; 
                    rf_wr_sel = 2'b11; 
                end
                
                3'b100: //xor
                begin 
                    alu_fun = 4'b0100; 
                    alu_srcB = 2'b01; 
                    rf_wr_sel = 2'b11; 
                end
                3'b101: //srai/srli
                begin 
                    case(ir30) 
                    1'b1: //srai
                    begin 
                        alu_fun = 4'b1101; 
                        alu_srcB = 2'b01; 
                        rf_wr_sel = 2'b11;
                    end
                    
                    1'b0: //srli
                    begin 
                        alu_fun = 4'b0101; 
                        alu_srcB = 2'b01; 
                        rf_wr_sel = 2'b11; 
                    end
                    endcase
                end
                endcase
                end
        endcase      
        end
endmodule
