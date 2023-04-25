function travelTime = getTimeFromPath(pathPointsIn,W_x,W_y,AirSpeed,sizeX,sizeY,integrationFineness) %#codegen
% This is the main function that actually calculates the line integral
% along the path. This is the objective function for the optimizer.
%
% Copyright 2012-2019 The MathWorks, Inc. 
%

% CODEGEN CHANGE: removed method parameter of waypointsToPath

% If we are called from the optimization routine (caller = "optimizer")
% then we need to interpolate the fine path from the input control points.
if isvector(pathPointsIn)
    pathPoints = [0 sizeY/2; reshape(pathPointsIn,2,[])'; sizeX sizeY/2];
    pathPoints = waypointsToPath(pathPoints,sizeX,sizeY,integrationFineness);
else
    pathPoints = pathPointsIn;
end

dP = diff(pathPoints);

% Interpolate the wind vector field at all the points in pathPoints.
V_wind = [interp2(W_x,pathPoints(1:end-1,1)+1,pathPoints(1:end-1,2)+1,"linear") ...
    interp2(W_y,pathPoints(1:end-1,1)+1,pathPoints(1:end-1,2)+1,"linear")];

% Dot product the wind (V_wind) with the direction vector (dP) to get
% the tailwind/headwind contribution
V_add = (sum(V_wind.*dP,2))./sqrt(sum(dP.^2,2));
dx = sqrt(sum(dP.^2,2))*100; %dx is the length of each subinterval in pathPoints

% CODEGEN CHANGE: Rewrite the vectorized code to get more readable generated C code 

% dt = dx./(AirSpeed+V_add);  %dT = dP/dV
dt = coder.nullcopy(realmax*ones(size(dx)));
for idx = 1:numel(dx)
    dt(idx) = dx(idx) / (AirSpeed + V_add(idx));
end

travelTime = sum(dt);
end