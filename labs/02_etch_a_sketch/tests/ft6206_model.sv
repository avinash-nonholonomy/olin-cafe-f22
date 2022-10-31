`timescale 1ns / 100ps

`include "i2c_types.sv"
`include "ft6206_defines.sv"

module ft6206_model(rst, scl, sda);

input wire rst;
input wire scl;
inout logic sda;

i2c_transaction_t mode;
wire i_ready;
logic i_valid;
logic [6:0] i_addr;
logic [7:0] i_data;
logic [7:0] o_data;

logic sda_out, sda_oe;
assign sda = sda_oe ? sda_out : 1'bz;

i2c_state_t state;

int reads_attempted = 0;
task update_o_data;
  o_data = reads_attempted + 8'hf0;
  reads_attempted = reads_attempted + 1;
endtask

// Not (easily) synthesizable! Just a quick i2c model)
logic [3:0] bit_counter;
always @(posedge scl or negedge scl or posedge rst) begin // need async reset since running on scl, not system clock
  if(rst) begin
    state <= S_START;
    bit_counter <= 7;
    i_addr <= 0;
    mode <= READ_8BIT;
  end else begin
    // #1;
    if(scl) begin // positive edge states
      case(state)  
        S_ADDR: begin
          if(bit_counter == 0) begin
            state <= S_ACK_ADDR;
            mode <= sda;
          end else begin
            bit_counter <= bit_counter - 1;
            i_addr[0] <= sda;
            i_addr[6:1] <= i_addr[5:0];
          end
        end
        S_ACK_ADDR : begin
          if(i_addr == `FT6206_ADDRESS) begin
`ifdef VERBOSE
            $display("ft6206 model: acknowledging matching address. mode is %b", mode);
`endif
            if(mode == WRITE_8BIT_REGISTER) begin
              state <= S_WR_DATA;
            end else begin
              state <= S_RD_DATA;
              update_o_data;
            end
            bit_counter <= 7;
          end else begin
            $display("ft6206 model: saw incorrect address 0x%h, should be 0x%h. quitting", i_addr, `FT6206_ADDRESS);
            $finish;
            state <= S_START;
          end
        end
        S_WR_DATA : begin // being written to.
          i_data[0] <= sda;
          i_data[7:1] <= i_data[6:0];
          if(bit_counter == 0) begin
            state <= S_ACK_WR;
          end
          else begin
            bit_counter <= bit_counter - 1;
          end
        end
        S_ACK_WR: begin
`ifdef VERBOSE
          $display("ft6206 model: received write of 0x%h", i_data);
`endif
          state <= S_STOP;
        end
        S_RD_DATA : begin
          if(bit_counter == 0) begin
            state <= S_ACK_RD;
          end
          else begin
            bit_counter <= bit_counter - 1;
          end
        end
        S_ACK_RD: begin
`ifdef VERBOSE
          $display("ft6206 model: sent 0x%h as read data", o_data);
`endif
          state <= S_STOP;
        end
        S_STOP: begin
          state <= S_START;
        end
      endcase
    end else begin // negative edge states
      if(state == S_START || state == S_STOP) begin
        if(~sda) begin
          state <= S_ADDR;
          bit_counter <= 7; 
        end
      end
    end
    
  end
end


always_comb begin
  case(state) 
    S_RD_DATA: begin
      sda_oe = 1;
      sda_out = o_data[bit_counter];
    end
    S_ACK_ADDR: begin
      sda_oe = 1;
      sda_out = 0;
    end
    S_ACK_WR : begin
      sda_oe = 1;
      sda_out = 0;
    end
    default: begin
      sda_oe = 0;
      sda_out = 1;
    end
  endcase
end

endmodule
