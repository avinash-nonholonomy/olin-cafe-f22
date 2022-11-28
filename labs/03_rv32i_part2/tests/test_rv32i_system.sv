`timescale 1ns/1ps
`default_nettype none
`define SIMULATION


module test_rv32i_system;

// Make sure to adjust this to a number appropriate for the .s file being run.
// For most, 10 to 100 cycles is plenty, but for peripherals.s it will need to
// about 1_500_000 (and take a long time) to fully complete. See Makefile
// for how to do this differently for each test.
`ifndef MAX_CYCLES
`define MAX_CYCLES 100
`endif

logic sysclk;
logic [1:0] buttons;
wire [1:0] leds;
wire [2:0] rgb;
wire [3:0] interface_mode;
wire backlight, display_rstb, data_commandb;
wire display_csb, spi_clk, spi_mosi;
logic spi_miso;
wire [31:0] gpio;

rv32i_system UUT(
  .sysclk(sysclk), .buttons(buttons), .leds(leds), .rgb(rgb),
  .interface_mode(interface_mode), .backlight(backlight), 
  .display_rstb(display_rstb), .data_commandb(data_commandb), 
  .display_csb(display_csb), 
  .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_clk(spi_clk),
  .gpio(gpio)
);


initial begin
  $dumpfile("rv32i_system.fst");
  $dumpvars(0, UUT);

  sysclk = 0;
  buttons = 2'b01;
  spi_miso = 0;
  repeat (2) @(negedge sysclk);
  buttons = 2'b00;
  repeat (`MAX_CYCLES) @(posedge sysclk);
  @(negedge sysclk);
  
  $display("Ran %d cycles, finishing.", `MAX_CYCLES);

  UUT.MMU.dump_memory("mmu");

  $finish;
end

always #5 sysclk = ~sysclk;

// Force end the solution if an infinite loop lasts too long.
parameter INFINITE_LOOP_LENGTH=10;
logic [31:0] PC_buffer [$:INFINITE_LOOP_LENGTH];
logic all_equal = 1'b1;
always @(posedge sysclk) begin
  if(~UUT.CORE.rst) begin
    if(UUT.CORE.state == UUT.CORE.S_FETCH) begin
        PC_buffer.push_back(UUT.CORE.PC_REGISTER.q);
        if(PC_buffer.size() == INFINITE_LOOP_LENGTH) begin
          all_equal = 1'b1;
          for(int i = 0; i < INFINITE_LOOP_LENGTH; i++) begin
            all_equal = all_equal & (PC_buffer[0] == PC_buffer[i]);
          end
          if(all_equal) begin
            $display("!!! Infinite loop detected (over %3d iterations) - ending sim !!!", INFINITE_LOOP_LENGTH);
            $finish;
          end
          PC_buffer.delete(0);
        end
    end

  end
end


endmodule
