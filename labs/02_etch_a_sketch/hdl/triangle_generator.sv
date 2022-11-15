// Generates "triangle" waves (counts from 0 to 2^N-1, then back down again)
// The triangle should increment/decrement only if the ena signal is high, and hold its value otherwise.

module triangle_generator(clk, rst, ena, out);

parameter N = 8;
input wire clk, rst, ena;
output logic [N-1:0] out;

typedef enum logic {COUNTING_UP = 1'b1, COUNTING_DOWN = 1'b0} state_t;
state_t state, next_state;
logic [N-1:0] mux_state, counter_plus;
logic count_is_max, count_is_zero;

always_comb begin : counter_cl
    //Behavioral mux to switch between +1 and -1
    case(state)
        COUNTING_UP : mux_state = 1;
        COUNTING_DOWN : mux_state = -1;
        default:        mux_state = 0;
    endcase

    //make an adder 
    counter_plus = out + mux_state;

end

always_ff @(posedge clk) begin : counter_r //Counter register

    if(rst)  out <= 0; 
    else if(ena) out <= counter_plus;

end

always_ff @(posedge clk) begin : state_ff //FSM 

    if(rst) state <= COUNTING_UP; 
    else state <= next_state; 

end

always_comb begin: next_state_comb

    count_is_max = (counter_plus == {N{1'b1}});
    count_is_zero = (counter_plus == 0);

    case(state)
        COUNTING_DOWN: begin
            if(count_is_zero) next_state = COUNTING_UP;
        end
        COUNTING_UP: begin
            if(count_is_max) next_state = COUNTING_DOWN ;
        end
        default: next_state = COUNTING_UP;
        
    endcase

end



endmodule

// module triangle_generator(clk, rst, ena, out);

// parameter N = 8;
// input wire clk, rst, ena;
// output logic [N-1:0] out;

// typedef enum logic {COUNTING_UP, COUNTING_DOWN} state_t;
// state_t state;

// always_ff @(posedge clk) begin
//     if (rst) begin
//         out <= 0;
//         state <= COUNTING_UP;
//     end 
//     else if (ena) begin
//         case(state)
//             COUNTING_UP: begin
//                 out <= out + 1;
//                 if (&out[N-1:1]&~out[0]) begin
//                     state <= COUNTING_DOWN;
//                 end
//             end
//             COUNTING_DOWN: begin
//                 out <= out - 1;
//                 if (&({~out[N-1:1],out[0]})) begin
//                     state <= COUNTING_UP;
//                 end
//             end
//         endcase
//     end
// end


// endmodule