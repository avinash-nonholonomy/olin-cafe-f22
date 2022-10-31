`include "ft6206_defines.sv"
`include "i2c_types.sv"

`timescale 1ns/1ps
`default_nettype none

module ft6206_controller(clk, rst, ena, scl, sda, touch0, touch1);

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2C_CLK_HZ = 100_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal

parameter DEFAULT_THRESHOLD = 128;
parameter N_RD_BYTES = 16;


parameter DISPLAY_WIDTH = 240;
parameter DISPLAY_HEIGHT = 320;

// Module I/O and parameters
input wire clk, rst, ena;
output wire scl;
inout wire sda;
output touch_t touch0, touch1;

i2c_transaction_t i2c_mode;
wire i_ready;
logic i_valid;
logic [7:0] i_data;
FT6206_register_t active_register; //TODO(avinash) implement smartly
logic o_ready;
wire o_valid;
wire [7:0] o_data;


i2c_controller #(.CLK_HZ(CLK_HZ), .I2C_CLK_HZ(I2C_CLK_HZ)) I2C0 (
  .clk(clk), .rst(rst), 
  .scl(scl), .sda(sda),
  .mode(i2c_mode), .i_ready(i_ready), .i_valid(i_valid), .i_addr(`FT6206_ADDRESS), .i_data(i_data),
  .o_ready(o_ready), .o_valid(o_valid), .o_data(o_data)
);

// Main fsm
enum logic [4:0] {
  S_IDLE = 0,
  S_INIT = 1,
  S_WAIT_FOR_I2C_WR = 2,
  S_WAIT_FOR_I2C_RD = 3,
  S_SET_THRESHOLD_REG = 4,
  S_SET_THRESHOLD_DATA = 5,
  S_TOUCH_START = 6,
  S_GET_REG_REG = 7,
  S_GET_REG_DATA = 8,
  S_GET_REG_DONE = 9,
  S_TOUCH_DONE,
  S_ERROR
} state, state_after_wait;

logic [1:0] num_touches;
touch_t touch0_buffer, touch1_buffer;
logic [$clog2(N_RD_BYTES):0] bytes_counter;

always_ff @(posedge clk) begin
  if(rst) begin
    state <= S_INIT;
    state_after_wait <= S_IDLE;
    bytes_counter <= 0;
    // TODO(avinash) - merge touch0 and touch1 buffers, can get away with less state that way.
    touch0_buffer <= 0;
    touch1_buffer <= 0;
    touch0 <= 0;
    touch1 <= 0;
  end else begin
    case(state)
      S_IDLE : begin
        if(i_ready & ena)
          active_register <= TD_STATUS;
          state <= S_GET_REG_REG;
      end
      S_INIT : begin
        state <= S_SET_THRESHOLD_REG;
      end
      S_SET_THRESHOLD_REG: begin
        state <= S_WAIT_FOR_I2C_WR;
        state_after_wait <= S_SET_THRESHOLD_DATA;
      end
      S_SET_THRESHOLD_DATA: begin
        state <= S_WAIT_FOR_I2C_WR;
        state_after_wait <= S_IDLE;
      end
      S_GET_REG_REG: begin
        state <= S_WAIT_FOR_I2C_WR;
        state_after_wait <= S_GET_REG_DATA;
      end
      S_GET_REG_DATA: begin
        state <= S_WAIT_FOR_I2C_RD;
        state_after_wait <= S_GET_REG_DONE;
      end
      S_GET_REG_DONE: begin
        if(~o_valid) begin
          state <= S_IDLE;
        end
        else begin
          active_register <= active_register.next;
          case(active_register)
            TD_STATUS: begin
              num_touches <= |o_data[3:2] ? 0 : o_data[1:0];
              if(o_data[3:0] == 4'd2) begin
                touch0_buffer.valid <= 1;
                touch1_buffer.valid <= 1;
              end else if (o_data[3:0] == 4'd1) begin
                touch0_buffer.valid <= 1;
                touch1_buffer.valid <= 0;
              end else begin
                touch0.valid <= 0;
                touch1.valid <= 0;
                touch0_buffer.valid <= 0;
                touch1_buffer.valid <= 0;
              end
            end
            P1_XH: begin
              touch0_buffer.x[11:8] <= o_data[3:0];
              touch0_buffer.contact <= o_data[7:6];
            end
            P1_XL : begin
              touch0_buffer.x[7:0] <= o_data;
            end
            P1_YH : begin
              touch0_buffer.y[11:8] <= o_data[3:0];
              touch0_buffer.id <= o_data[7:4];
            end
            P1_YL : begin
              touch0_buffer.y[7:0] <= o_data;
            end
          endcase
          if(active_register == P1_YL) // TODO(avinash) replace constant
            state <= S_TOUCH_DONE;
          else
            state <= S_GET_REG_REG;
        end
      end
      S_TOUCH_DONE: begin
        if(num_touches >= 2'd1) begin
          touch0.valid <= touch0_buffer.valid;
          touch0.x <= DISPLAY_WIDTH - touch0_buffer.x; // fix orientation
          touch0.y <= DISPLAY_HEIGHT - touch0_buffer.y; // fix orientation
          touch0.contact <= touch0_buffer.contact;
          touch0.id <= touch0_buffer.id;
        end
        // See if you can modify the above to do multitouch!
        state <= S_IDLE;
      end      
      S_WAIT_FOR_I2C_WR : begin
        if(i_ready) state <= state_after_wait;
      end
      S_WAIT_FOR_I2C_RD : begin
        if(i_ready & o_valid) state <= state_after_wait;
      end
    endcase
  end
end

always_comb case(state)
  S_IDLE: i_valid = 0;
  S_INIT: i_valid = 0;
  S_RD_DATA: i_valid = 1;
  S_WAIT_FOR_I2C_WR: i_valid = 0;
  S_WAIT_FOR_I2C_RD: i_valid = 0;
  S_SET_THRESHOLD_REG: i_valid = 1;
  S_SET_THRESHOLD_DATA: i_valid = 1;
  S_GET_REG_REG: i_valid = 1;
  S_GET_REG_DATA: i_valid = 1;
  default: i_valid = 0;
endcase 

always_comb case(state)
  S_GET_REG_DATA:  i2c_mode = READ_8BIT;
  default: i2c_mode = WRITE_8BIT_REGISTER;
endcase


always_comb case(state)
  S_SET_THRESHOLD_REG: i_data = THRESHOLD;
  S_SET_THRESHOLD_DATA: i_data = `FT6206_DEFAULT_THRESHOLD;
  S_GET_REG_REG: i_data = active_register;
  default: i_data = 0;
endcase
endmodule