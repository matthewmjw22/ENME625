function [C, Ceq] = nonlinear_constraintsRunMOGA_OSY(Input)
x1 = Input(1);
x2 = Input(2);
x3 = Input(3);
x4 = Input(4);
x5 = Input(5);
x6 = Input(6);

C(1) = 1 - (x1+x2)/2;
C(2) = (x1 + x2)/6 -1;
C(3) =(x2-x1)/2 - 1;
C(4) = (x1 - 3*x2)/2 -1;
C(5) =((x3-3)^2 + x4)/4 -1;
C(6) = 1 - ((x5 - 3)^2 + x6)/4;
Ceq = [];