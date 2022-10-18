# Homework 4
The written portion is available [here](https://docs.google.com/document/d/1XybXmTD5-NTJ1gfLq3tYb-wUUDJGZS8xgO912DLf50Q/edit?usp=sharing)

Add a pdf of your written answers to this folder, then use `make clean` then `make submission` to submit!

A description of how you implemented the modules (you can include pictures or reference notes in your homework pdf)
A description of how you tested the mux32.
How to run your tests

32-Bit Adder:

To create the module for this adder, I began with a 1-bit adder that I could later expand on. For the 1-bit adder, the adder takes two one-bit inputs to add as well as a carry-in, which I called Cin, and has two outputs: S, representing the sum, and Cout, which is the carry-out bit that allows for the complete sum to be read. I set the input wires to be equivalent to a, b, and Cin, which represents the two numbers we are summing and the carry-in bit. I set the output logic to be equivalent to S and Cout, which represent the sum and the carry-out bit. The logic equations that represent a full adder are the following:
 
S = A XOR B XOR C
Cout = AB + ACin + BCin

I ran these equations in an always_comb statement with my inputted variables and then ended the module.

For the 32-bit adder, I created an N-bit adder with a parameter that can be changed. The N-bit adder also has the same inputs and outputs, but the two numbers being inputted must be arrays of length N so they can hold the right number of bits that need to be summed. The output S must also be an array of length N for the same reason and remains a logic value, but Cout must be set as a wire since it will be inputted into the next adder. I also instantiated a wire called carries which has a length of N+1 as it is used to use Cout as the input to the next adders Cin. By assigning the first value of carries to Cin, when I instantiate the 1-bit adder in a for loop that iterates through a value i until i sweeps from 0 to N I can input the proper bits into each adder as a, b, Cin, S, and Cout values need to be called from the right index in each of their arrays. Cout will be equivalent to carries[i+1] while Cin is carries[i] since Cout is the same as the next Cin.

32:1 MUX:

To create a 32:1 MUX, by creating a 2:1 MUX I can build off of it to eventually create a 32:1 multiplexor. I created a module for my 2:1 by setting three input wires and one logic output. I used the built-in multiplexor operation in Verilog to set out = select ? in1 : in0. For the next module I created a 4 to 1 by using two 2 to 1 multiplexors and having both of them have the same select signal but varying inputs, resulting in 4 total outputs. A third 2 to 1 was used to gather the outputs from each of those two multiplexors and a second select signal was used to choose which input will be outputted. An internal wire of length two was needed to carry the output signal from each of the first two multiplexors into the inputs of the third multiplexor. The same pattern was repeated for a 8 to 1, 16 to 1, and finally 32 to 1 multiplexor. For the 32 to 1 multiplexor, there were a total of 32 a inputs, 32 b inputs, 5 select signals, and an N-length logic output. 
To create a 32:1 MUX, by creating a 2:1 MUX I can build off of it to eventually create a 32:1 multiplexor. I created a module for my 2:1 by setting three input wires and one logic output. I used the built-in multiplexor operation in Verilog to set out = select ? in1 : in0. For the next module I created a 4 to 1 by using two 2 to 1 multiplexors and having both of them have the same select signal but varying inputs, resulting in 4 total outputs. A third 2 to 1 was used to gather the outputs from each of those two multiplexors and a second select signal was used to choose which input will be outputted. A The same pattern was repeated for a 8 to 1, 16 to 1, and finally 32 to 1 multiplexor. For the 32 to 1 multiplexor, there were a total of 32 a inputs, 32 b inputs, 5 select signals, and an N-length logic output. 

Testing the 32 to 1 MUX:

To test the MUX, I needed to create the proper inputs and outputs, which included 5 select logic values, 32 d logic values which represent the inputs, 32 y values representing the expecting output, and 32 result values representing what the code outputted. In a for loop that ran 32 times, I chose 32 random values of d that maxxed out at the largest 32 bit integer. For each value in d, I then ran through a for loop in which the select signal is equivalent to i, which is the variable keeping track of the indices of d, and if y and result are not equal an error is thrown.

Running the Tests:

To run the tests, I first added the proper calls the the Makefile including defining the source files for the adder and MUX functions. I then called 3 test functions that I had written: testing the 1-bit adder, the 32-bit adder, and the 32:1 MUX. To run a test on any of the above three functions, in terminal you can run:

`make [name of test file]`

For example:

`make test_mux` would run the tests written for the MUX.