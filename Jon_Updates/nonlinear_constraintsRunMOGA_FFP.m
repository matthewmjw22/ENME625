function [C, Ceq] = nonlinear_constraintsRunMOGA_FFP(Input)
x = [8.33 16.667 25 33.33 41.667];
y1 = Input(1);
y2 = Input(2);
y3 = Input(3);
y4 = Input(4);
y5 = Input(5);



C = [];
% C(1) = -((x - 25)^2 + (y - 12)^2) - 3^2;
 C(1) = -((x(1) - 10)^2 + (y1 - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(2) = -((x(1) - 40)^2 + (y1 - 20)^2) - 3^2;

 C(3) = -((x(2) - 10)^2 + (y2 - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(4) = -((x(2) - 40)^2 + (y2 - 20)^2) - 3^2;

 C(5) = -((x(3) - 10)^2 + (y3 - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(6) = -((x(3) - 40)^2 + (y3 - 20)^2) - 3^2;

 C(7) = -((x(4) - 10)^2 + (y4 - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(8) = -((x(4) - 40)^2 + (y4 - 20)^2) - 3^2;

 C(9) = -((x(5) - 10)^2 + (y5 - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(10) = -((x(5) - 40)^2 + (y5 - 20)^2) - 3^2;

Ceq = [];