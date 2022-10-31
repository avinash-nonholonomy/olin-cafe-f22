`timescale 1ns / 100ps

`include "spi_types.sv"

module test_spi_controller;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter MAX_CYCLES = 5000;
//Module I/O and parameters
logic clk, rst;
wire sclk, csb, mosi;
logic miso;
spi_transaction_t spi_mode;
wire i_ready;
logic i_valid;
logic [15:0] i_data;
logic o_ready;
wire o_valid;
wire [23:0] o_data;
logic [23:0] response;

spi_controller UUT(
    .clk(clk), .rst(rst), .sclk(sclk), .csb(csb), .mosi(mosi), .miso(miso),
    .spi_mode(spi_mode), .i_ready(i_ready), .i_valid(i_valid), .i_data(i_data),
    .o_ready(o_ready), .o_valid(o_valid), .o_data(o_data)
);

// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

int errors = 0;
initial begin
  // Collect waveforms
  $dumpfile("spi_controller.fst");
  $dumpvars(0, UUT);
  
  // Initialize module inputs.
  clk = 0;
  rst = 1;
  i_valid = 0;
  o_ready = 1;
  miso = 0;
  spi_mode = WRITE_8_READ_8;

  // Assert reset for long enough.
  repeat(2) @(negedge clk);
  rst = 0;

  // Test write 8 mode (no read):
  $display("----------------------------------------------------------------");
  $display("-- Write 8 test (no read)                                     --");
  $display("----------------------------------------------------------------");
  spi_mode = WRITE_8;
  for (int i = 0; i < 4; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i + 8'b1010_1010; 
    $display("\nWriting 0x%h to the SPI Device.", i_data[7:0]);
    i_valid = 1;
    for (int j = 0; j < 8; j = j + 1) begin
      @(negedge sclk);
      i_valid = 0;
    end
  end

  // Test write 16 mode (no read):
  $display("----------------------------------------------------------------");
  $display("-- Write 16 test (no read)                                    --");
  $display("----------------------------------------------------------------");
  spi_mode = WRITE_16;
  for (int i = 0; i < 4; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i + 16'b0101_0101_1010_1010; 
    $display("\nWriting 0x%h to the SPI Device.", i_data[7:0]);
    i_valid = 1;
    for (int j = 0; j < 16; j = j + 1) begin
      @(negedge sclk);
      i_valid = 0;
    end
  end

// Enable this if you'd like to test a read/write SPI primary controller, 
// but remember it is not required for this lab!
`ifdef SPI_READ_WRITE_IMPLEMENTED
  // Test write 8 read 8 mode. Testbench simulates a SPI device that computes -1*input.
  $display("----------------------------------------------------------------");
  $display("-- Write 8 Read 8                                             --");
  $display("----------------------------------------------------------------");
  spi_mode = WRITE_8_READ_8;
  for (int i = 0; i < 10; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i + 1; i_data[15:8] = 0;
    response = ~i_data + 1;
    $display("\n@%10t: Writing %d to the SPI Device, expecting %d as the response.", $time, i_data[7:0], response[7:0]);
    i_valid = 1;
    for (int j = 0; j < 8; j = j + 1) begin
      @(negedge sclk);
      i_valid = 0;
    end
    for (int j = 0; j < 8; j = j + 1) begin
      miso = response[8-1-j];
      @(negedge sclk);
    end
    while(~o_valid) @(negedge clk);
    $display("  Received 0x%h as the response.", o_data);
    if( o_data[7:0] !== response[7:0] ) begin
      errors = errors + 1;
      $display("  !ERROR! Rx'd %b, wanted %b", o_data[7:0], response[7:0]);
    end
    @(negedge clk);
  end

  // Test write 8 read 16 mode:  Testbench simulates a SPI device that computes the square of a number
  $display("----------------------------------------------------------------");
  $display("-- Write 8 Read 16                                            --");
  $display("----------------------------------------------------------------");
  spi_mode = WRITE_8_READ_16;
  for (int i = 0; i < 10; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i + 1;
    response = i_data*i_data;
    $display("\n@%10t: Writing %d to the SPI Device, expecting %d as the response.", $time, i_data[7:0], response[15:0]); 
    i_valid = 1;
    for (int j = 0; j < 8; j = j + 1) begin
      @(negedge sclk);
      i_valid = 0;
    end
    for (int j = 0; j < 16; j = j + 1) begin
      miso = response[16-1-j];
      @(negedge sclk);
    end
    while(~o_valid) @(negedge clk);
    $display("  Received 0x%h as the response.", o_data);
    if( o_data[15:0] !== response[15:0] ) begin
      errors = errors + 1;
      $display("  !ERROR! Rx'd %b, wanted %b", o_data[15:0], response[15:0]);
    end
    @(negedge clk);
  end

  // Test write 8 read 24 mode:  Testbench simulates a SPI device that computes the cube of a number
  spi_mode = WRITE_8_READ_24;
  for (int i = 0; i < 10; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i + 1;
    response = i_data*i_data*i_data;
    $display("\nWriting %d to the SPI Device, expecting %d as the response.", i_data[7:0], response[23:0]);
    i_valid = 1;
    for (int j = 0; j < 8; j = j + 1) begin
      @(negedge sclk);
      i_valid = 0;
    end
    for (int j = 0; j < 24; j = j + 1) begin
      miso = response[24-1-j];
      @(negedge sclk);
    end
    while(~o_valid) @(negedge clk);
    $display("  Received %d as the response.", o_data);
    if( o_data !== response ) begin
      errors = errors + 1;
      $display("  !ERROR! Rx'd %d, wanted %d", o_data[23:0], response[23:0]);
    end
    @(negedge clk);
  end
`endif // SPI_READ_WRITE_IMPLEMENTED

  
  if(errors) begin
    $display("#########################################################");
    $display("## Failure, found %d errrors...", errors);
    $display("#########################################################");
  end else begin
    $display("#########################################################");
    $display("## Success!!!");
    $display("#########################################################");
  end
  $finish;
end

// Put a timeout to make sure the simulation doesn't run forever;
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule
