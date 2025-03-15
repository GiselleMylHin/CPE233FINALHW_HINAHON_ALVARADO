`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Giselle Hinahon & Zachary Alvarado
// 
// Create Date: 03/03/2025 05:05:49 PM
// Design Name: 
// Module Name: OTTER_MCU_TB
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU_TB();
    logic RST_TB;
    logic INTR_TB;
    logic [31:0] IOBUS_IN_TB;
    logic CLK_TB;
    logic IOBUS_WR_TB;
    logic [31:0] IOBUS_OUT_TB;
    logic [31:0] IOBUS_ADDR_TB;
    
    assign INTR_TB = 0;
    assign IOBUS_IN_TB = 32'b0;
    
    
    
    OTTER_MCU UUT(.CPU_RST(RST_TB), .CPU_INTR(INTR_TB), .CPU_CLK(CLK_TB), .CPU_IOBUS_IN(IOBUS_IN_TB), .CPU_IOBUS_WR(IOBUS_WR_TB), .CPU_IOBUS_OUT(IOBUS_OUT_TB), .CPU_IOBUS_ADDR(IOBUS_ADDR_TB));
    
    initial begin
        CLK_TB = 0;
        RST_TB=1;
        #10
        RST_TB=0;
    end
    
    always begin
        #5 CLK_TB = ~CLK_TB;
    end

endmodule
