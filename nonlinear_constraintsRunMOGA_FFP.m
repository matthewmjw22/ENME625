function [C, Ceq] = nonlinear_constraintsRunMOGA_FFP(Input)
pathPoints = Input(1);
W_x = Input(2);
W_y = Input(3);
AirSpeed = Input(4);
sizeX = Input(5);
sizeY = Input(6);
method = Input(7)
integrationFineness = Input(8)


C(1) = ((pathPoints(1, 1) - 10)^2 + (pathPoints(1, 2) - 8)^2) - 3^2;
% Add P * 3^2 to add uncertainty to size of red circle 
C(2) = ((pathPoints(1, 1) - 40)^2 + (pathPoints(1, 2) - 20)^2) - 3^2;

Ceq = [];