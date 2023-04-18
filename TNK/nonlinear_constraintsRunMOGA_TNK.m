function [C, Ceq] = nonlinear_constraintsRunMOGA_TNK(Input)
x1 = Input(1);
x2 = Input(2);


C(1) = -(x1^2 + x2^2 -1 - 0.1*cos(16*atan(x1/x2)));
C(2) = (x1 - 0.5)^2 + (x2 - 0.5)^2 -0.5;

Ceq = [];