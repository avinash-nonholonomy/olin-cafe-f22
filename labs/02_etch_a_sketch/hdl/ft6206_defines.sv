// Based on FT6x06 Application Note
// and some defines from: https://github.com/adafruit/Adafruit_FT6206

`ifndef FT6206_DEFINES_H
`define FT6206_DEFINES_H

// From Section 8.1 of the Datasheet

`define FT6206_ADDRESS (7'h38)
`define FT6206_DEFAULT_THRESHOLD (8'd128)

/* 
const logic [7:0] FT6206_NUM_X = 8'h33;
const logic [7:0] FT6206_NUM_Y = 8'h34;

const logic [7:0] DEVICE_MODE_WORKING = 8'b0000_0000;
const logic [7:0] DEVICE_MODE_FACTORY = 8'b0100_0000;
*/

`define FT6206_BITS 12

typedef enum logic [7:0] {
  NO_GESTURE = 8'h00,
  MOVE_UP = 8'h10,
  MOVE_RIGHT = 8'h14,
  MOVE_DOWN = 8'h18,
  MOVE_LEFT = 8'h1c,
  ZOOM_IN = 8'h48,
  ZOOM_OUT = 8'h49
} FT6206_gesture_t;

typedef enum logic [1:0] {
  PRESS_DOWN = 2'b00,
  LIFT_UP = 2'b01,
  CONTACT = 2'b10,
  NO_EVENT = 2'b11
} FT6206_contact_t;

typedef struct packed {
  logic valid;
  logic [11:0] x;
  logic [11:0] y;
  logic [7:0] weight;
  logic [3:0] area;
  logic [3:0] id;
  // Note: icarus doesn't support structs too well, so can't nest in gesture_t and contact_t.
  logic [1:0] contact;
  logic [7:0] gesture;
} touch_t;

task print_touch(input touch_t t);
  $display("touch bus decoded: valid = %b", t.valid);
  if(t.valid) begin
    $display("  x = %d, y = %d, weight = %d, area = %d", t.x, t.y, t.weight, t.area);
  end
endtask


typedef enum logic [7:0] {
  DEVICE_MODE = 8'h00, // bits[6:4] = device_mode[2:0]. Writing zero triggers a data burst? //TODO(avinash) verify
  GEST_ID = 8'h01,
  TD_STATUS = 8'h02, // {4'b0000, n_touches[3:0]}
  // First touch position:
  P1_XH = 8'h03, // {event_flag[1:0], 2'bxx, x_position[11:8]}
  P1_XL = 8'h04, // x_position[7:0]
  P1_YH = 8'h05, // {touch_id[3:0], y_position[11:8] }
  P1_YL = 8'h06, // y_position[7:0]
  P1_WEIGHT = 8'h07, // weight[7:0]
  P1_MISC = 8'h08, // {area[3:0], 4'b0000}
  // Second touch position:
  P2_XH = 8'h09, // {event_flag[1:0], 2'bxx, x_position[11:8]}
  P2_XL = 8'h0a, // x_position[7:0]
  P2_YH = 8'h0b, // {touch_id[3:0], y_position[11:8] }
  P2_YL = 8'h0c, // y_position[7:0]
  P2_WEIGHT = 8'h0d, // weight[7:0]
  P2_MISC = 8'h0e, // {area[3:0], 4'b0000}

  THRESHOLD = 8'h80, // touch detection threshold, 128 is reasonable
  TH_DIFF = 8'h85, // filter function coefficient. Changing seems risky
  CTRL = 8'h86, // {switches mode for active/monitor automatic switching}
  TIME_ENTER_MONITOR = 8'h87, // time between going for active to monitor if there aren't any touch events
  PERIOD_ACTIVE = 8'h88, // report rate in active mode
  PERIOD_MONITOR = 8'h89, // report rate in monitor mode
  CHIP_ID = 8'ha3
} FT6206_register_t;

/* Notes on interfacing
- Start by writing 8'h0... (sets you into working mode)
- 



*/



`endif // FT6206_DEFINES_H