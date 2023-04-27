function Output = objective_functionRunMOGA_FFP(Input)
pathPoints = Input(1);
W_x = Input(2);
W_y = Input(3);
AirSpeed = Input(4);
sizeX = Input(5);
sizeY = Input(6);
method = Input(7);
integrationFineness = Input(8);

F1 = getTimeFromPath(pathPoints,W_x,W_y,AirSpeed,sizeX,sizeY,method,integrationFineness);
F2 = -(((pathPoints(1, 1) - 10)^2   +    (pathPoints(1, 1) - 40)^2)     +   ((pathPoints(1, 2) - 8)^2   +    (pathPoints(1, 1) - 20)^2));  
%Maximize distance from circle I think You have to make this batched
% Should be pathpoints(i, 1) or pathPoint(i, 2)

Output = [F1 F2];
