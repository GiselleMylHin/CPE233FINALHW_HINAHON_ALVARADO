`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Zachary Alvarado
// 
// Create Date: 03/03/2025 04:53:19 PM
// Design Name: 
// Module Name: OTTER_MCU
// 
//////////////////////////////////////////////////////////////////////////////////

module OTTER_MCU(
    //inputs:
    input logic CPU_RST, 
    input logic CPU_INTR,
    input logic [31:0] CPU_IOBUS_IN,
    input logic CPU_CLK,
    //outputs
    output logic CPU_IOBUS_WR,
    output logic [31:0] CPU_IOBUS_OUT,
    output logic [31:0] CPU_IOBUS_ADDR
    );  
    
    //instantiating memory
    logic memWE2;
    logic memRDEN1;
    logic memRDEN2;
    logic [31:0] ir;
    logic pcWrite;
    logic regWrite;
    logic reset;
    
    logic csr_WE; 
    //logic mstatus;
    logic int_taken;
    logic mret_exec;
    logic csr_intr;
    logic [31:0] csr_RD_data;
    logic [31:0] alu_result; 
    logic [31:0] mtvec;
    logic [31:0] mepc; 
    logic [31:0] pc;
    
    assign mret_exec = 0;
    assign csr_intr = 32'b0;
    assign mepc = 32'b0;
    assign mtvec = 32'b0;
   
    //CU FSM instantiation
    CU_FSM fsm (
        //inputs
        .RST(CPU_RST),
        .opcode(ir[6:0]),
        .opcode_2(ir[14:12]),
        .clk(CPU_CLK),
        
        //outputs
        .PCWrite(pcWrite),
        .regWrite(regWrite),
        .memWE2(memWE2),
        .memRDEN1(memRDEN1),
        .memRDEN2(memRDEN2),
        .reset(reset),
        .csr_WE(csr_WE),
        .mret_exec(mret_exec)
    );   
    
    //CU DCDR signals
    logic dcdr_br_eq;
    logic dcdr_br_lt;
    logic dcdr_br_ltu; 

    //ALU
    logic [3:0] alu_fun; 
    logic [1:0] alu_srcA; 
    logic [2:0] alu_srcB; 
    logic [2:0] pcSource; 
    logic [1:0] rf_wr_sel;
    
    //CU DCDR instantiation 
    CU_DCDR cu_decoder(
        .opcode(ir[6:0]),
        .opcode2(ir[14:12]), 
        .ir30(ir[30]),
        .int_taken(int_taken),
        .br_eq(dcdr_br_eq),
        .br_lt(dcdr_br_lt),
        .br_ltu(dcdr_br_ltu),
        
        //outputs
        .alu_fun(alu_fun),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .pcSource(pcSource),
        .rf_wr_sel(rf_wr_sel)
    );   
     
    //PC signals
    logic [31:0] nextInstruction; 
    logic [31:0] jalr;
    logic [31:0] branch;
    logic [31:0] jal;
    logic [31:0] pcDin;  
    
    always_comb begin
        //MUX for PC
        case(pcSource)
            3'b000: pcDin = nextInstruction;
            3'b001: pcDin = jalr; 
            3'b010: pcDin = branch; 
            3'b011: pcDin = jal; 
            3'b100: pcDin = mtvec;
            3'b101: pcDin = mepc;
            default: pcDin = 32'hdead;
        endcase
    end 
   
     //PC counter instantiation
     pc_counter PC(
        //inputs
        .PC_WRITE(pcWrite),
        .PC_RST(reset), 
        .PC_DIN(pcDin),
        .clk(CPU_CLK), 
        
        //outputs
        .PC_COUNT(pc)
    );
       
     //plus_4_Adder
    logic [31:0] instructionAddress;
    assign instructionAddress = pc;
    assign nextInstruction = instructionAddress + 4;     
      
    //memory    
    //inputs
    logic [31:0] Din2_memory;
    logic [13:0] pc_to_addr1;
    assign pc_to_addr1 = pc[15:2];
    //outputs
    logic [31:0] Dout2;
    logic [31:0] Dout1_ir; 
    
    //memory instantiation
    Memory Otter_Mem(
        //inputs
        .MEM_CLK(CPU_CLK),
        .MEM_RDEN1(memRDEN1),        
        .MEM_RDEN2(memRDEN2),        
        .MEM_WE2(memWE2),         
        .MEM_ADDR1(pc_to_addr1), 
        .MEM_ADDR2(alu_result), 
        .MEM_DIN2(Din2_memory),  
        .MEM_SIZE(ir[13:12]),   
        .MEM_SIGN(ir[14]),         
        .IO_IN(CPU_IOBUS_IN),   
          
        //outputs
        .IO_WR(CPU_IOBUS_WR),  
        .MEM_DOUT1(Dout1_ir), 
        .MEM_DOUT2(Dout2)
    );
    
    assign ir = Dout1_ir;
    logic [31:0] wd_data;
    
    always_comb begin
    //reg_file MUX
        case(rf_wr_sel)
            2'b00: wd_data = nextInstruction; 
            2'b01: wd_data = csr_RD_data; 
            2'b10: wd_data = Dout2; 
            2'b11: wd_data = alu_result;
            default: wd_data = 32'hdead; 
        endcase
    end       
    
    //reg_file
    logic [4:0] addr1_from_instr;
    assign addr1_from_instr = ir[19:15];
    logic [4:0] addr2_from_instr;
    assign addr2_from_instr = ir[24:20]; 
    logic [4:0] wa_from_instr;
    assign wa_from_instr = ir[11:7];
    
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    assign Din2_memory = rs2_data;     

    //reg_file instantiation
    reg_file register_file (
        .RF_ADR1 (addr1_from_instr),
        .RF_ADR2 (addr2_from_instr), 
        .RF_WA (wa_from_instr), 
        .RF_WD (wd_data), 
        .clk (CPU_CLK), 
        .RF_EN (regWrite), 
        .RF_RS1 (rs1_data), 
        .RF_RS2 (rs2_data)
    );  

    assign CPU_IOBUS_OUT = Din2_memory; 
    
    //IMM GEN signals
    logic [31:0] U_TYPE;
    logic [31:0] I_TYPE;
    logic [31:0] S_TYPE;
    logic [31:0] J_TYPE; 
    logic [31:0] B_TYPE;
    
    //immediate Generator instantiation
    IMM_GEN immediate_generator(
        //inputs
        .INS(ir),
        
        //outputs
        .U_Typ(U_TYPE),
        .I_Typ(I_TYPE),
        .S_Typ(S_TYPE),
        .J_Typ(J_TYPE),
        .B_Typ(B_TYPE)
    );   

    //BAG instantiation
    Branch_Addr_Gen address_Generator(
        //inputs
        .pc(instructionAddress),
        .j_typ(J_TYPE),
        .b_typ(B_TYPE),
        .i_typ(I_TYPE),
        .rs1(rs1_data),
        
        //outputs
        .jalr(jalr),
        .jal(jal),
        .branch(branch)
    ); 
    
    //Branch Condition Generator instantiation
    Branch_Cond_Gen branch_cond_gen(
        //inputs
        .rs1(rs1_data),
        .rs2(rs2_data),
        
        //outputs
        .br_eq(dcdr_br_eq),
        .br_ltu(dcdr_br_ltu),
        .br_lt(dcdr_br_lt)
    );


    logic [31:0] muxA_to_alu;
    
    always_comb begin
        case(alu_srcA)
        2'b00: muxA_to_alu = rs1_data;
        2'b01: muxA_to_alu = U_TYPE; 
        2'b10: muxA_to_alu = ~(rs1_data); 
        default: muxA_to_alu = 32'hdead;
        endcase
    end
    
    logic [31:0] muxB_to_alu;
    
    always_comb begin    
    //MUX for ALU srcB
        case(alu_srcB) 
            3'b000: muxB_to_alu = Din2_memory;
            3'b001: muxB_to_alu = I_TYPE; 
            3'b010: muxB_to_alu = S_TYPE; 
            3'b011: muxB_to_alu = instructionAddress; 
            3'b100: muxB_to_alu = csr_RD_data; 
            default: muxB_to_alu = 32'hdead;
        endcase 
    end
    
    //ALU instantiation   
    ALU alu (
        //inputs
        .A(muxA_to_alu),
        .B(muxB_to_alu),
        .ALU_FUN(alu_fun),
        
        //outputs
        .RESULT(alu_result)
    ); 
    assign CPU_IOBUS_ADDR = alu_result;
    
endmodule
