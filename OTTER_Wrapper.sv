module OTTER_Wrapper(
   input CLK,
   input BTNC,
   input [15:0] SWITCHES,
   output logic [15:0] LEDS,
   output [7:0] CATHODES,
   output [3:0] ANODES
   );

    localparam SWITCHES_AD = 32'h11000000;
           
    localparam LEDS_AD      = 32'h11000020;
    localparam SSEG_AD      = 32'h11000040;     
    
   // signals for connecting OTTER_MCU to OTTER_wrapper 
   logic [31:0] IOBUS_out,IOBUS_in,IOBUS_addr;
   logic IOBUS_wr;
   
   logic s_interrupt;
   logic s_reset;
   logic sclk = 1'b0;   
   
   logic [15:0]  r_SSEG;

   
   // connecting Signals
   assign s_reset = BTNC;
   
   //setting clock Divider to create 50 MHz Clock
   always_ff @(posedge CLK) begin
       sclk <= ~sclk;
   end

   // instantiate OTTER_CPU
   OTTER_MCU MCU (.CPU_RST(s_reset),.CPU_INTR(s_interrupt), .CPU_CLK(sclk),  
                   .CPU_IOBUS_OUT(IOBUS_out),.CPU_IOBUS_IN(IOBUS_in),
                   .CPU_IOBUS_ADDR(IOBUS_addr),.CPU_IOBUS_WR(IOBUS_wr));

   // instantiate seven segment display 
   SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
                          
   // Connect Board peripherals (Memory Mapped IO devices) to IOBUS 
   // ouput MUX and registers 
    always_ff @ (posedge sclk)
    begin
        if(IOBUS_wr)
            case(IOBUS_addr)
                LEDS_AD: LEDS <= IOBUS_out[15:0];    
                SSEG_AD: r_SSEG <= IOBUS_out[15:0];
            endcase
    end
    
    // Input MUX
    always_comb
    begin
        case(IOBUS_addr)
            SWITCHES_AD: IOBUS_in = {16'b0,SWITCHES};
            default: IOBUS_in = 32'b0;
        endcase
    end
   endmodule
