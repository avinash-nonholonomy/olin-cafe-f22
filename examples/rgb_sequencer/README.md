# RGB Sequence

This is a guided example to get us used to simulating and synthesizing sequential logic and finite state machines. The goal is a circuit where the RGB LED color changes each time we hit the button. To do this, we will need:
- [ ] a debouncer - to make sure we don't catch spurious edges from a button.
- [ ] an edge detector - to detect when the button goes from unpressed to pressed.
- [ ] a rgb sequence FSM (finite state machine) that changes the colors.

If it all works, each time you press the button the LED will change its color.