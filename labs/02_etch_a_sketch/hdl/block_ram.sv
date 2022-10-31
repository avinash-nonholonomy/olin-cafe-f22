// Based on UG901 - The Vivado Synthesis Guide
`timescale 1ns / 100ps
`default_nettype none

module block_ram(clk, rd_addr, rd_data, wr_ena, wr_addr, wr_data);

parameter W = 8; // Width of each row of  the memory
parameter L = 32; // Length fo the memory
parameter INIT = "zeros.memh";

input wire clk;
input wire [$clog2(L)-1:0] rd_addr, wr_addr;
output logic [W-1:0] rd_data;
input wire wr_ena;
input wire [W-1:0] wr_data;

logic [W-1:0] ram [0:L-1];
initial begin
  $display("Initializing block rom from file %s.", INIT);
  $readmemh(INIT, ram); // Initializes the ROM with the values in the init file.
end

always_ff @(posedge clk) begin : synthesizable_rom
  rd_data <= ram[rd_addr];
  if(wr_ena) begin
    ram[wr_addr] <= wr_data;
  end
end

`ifdef SIMULATION
task dump_memory(string out_fn);
$writememh(out_fn, ram);
endtask
`endif

endmodule
