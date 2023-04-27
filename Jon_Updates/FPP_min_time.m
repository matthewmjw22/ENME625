function travelTime = getTimeFromPath(pathPoints,W_x,W_y,AirSpeed,sizeX,sizeY,method,integrationFineness)
% This is the main function that actually calculates the line integral
% along the path. This is the objective function for the optimizer.

% If we are called from the optimization routine (caller = "optimizer")
% then we need to interpolate the fine path from the input control points.
if isvector(pathPoints)
    pathPoints = [0 sizeY/2; reshape(pathPoints,2,[])'; sizeX sizeY/2];
    pathPoints = waypointsToPath(pathPoints,method,sizeX,sizeY,integrationFineness);
end

dP = diff(pathPoints);

% Interpolate the wind vector field at all the points in pathPoints.
V_wind = [interp2(W_x,pathPoints(1:end-1,1)+1,pathPoints(1:end-1,2)+1,"linear") ...
    interp2(W_y,pathPoints(1:end-1,1)+1,pathPoints(1:end-1,2)+1,"linear")];

% Dot product the wind (V_wind) with the direction vector (dP) to get
% the tailwind/headwind contribution
V_add = (sum(V_wind.*dP,2))./sqrt(sum(dP.^2,2));
dx = sqrt(sum(dP.^2,2))*100; %dx is the length of each subinterval in pathPoints
dt = dx./(AirSpeed+V_add);  %dT = dP/dV
travelTime = sum(dt);
end
% calculateTimeIntermediate

function totalTime = calculateTimeIntermediate(x,W_x,W_y,x0,y0,AirSpeed,sizeX,sizeY,method,integrationFineness)
% This calculates the time starting from a specified start point (x0,y0)
% It is used in the time-dependent version of this optimization problem.

L = numel(x);
X_points = linspace(x0,sizeX,L+2)';

points = [X_points [y0; x; sizeY/2]];

PointList = [interp1(X_points,points(:,1),linspace(x0,sizeX,integrationFineness)',method,"extrap") ...
    interp1(X_points,points(:,2),linspace(x0,sizeX,integrationFineness)',method,"extrap")];

PointList(PointList < 0) = 0;
PointList(:,1) = min(PointList(:,1),sizeX);
PointList(:,2) = min(PointList(:,2),sizeY);

dP = diff(PointList);

V_wind = [interp2(W_x,PointList(1:end-1,1)+1,PointList(1:end-1,2)+1,"linear")...
    interp2(W_y,PointList(1:end-1,1)+1,PointList(1:end-1,2)+1,"linear")];

% Dot product the wind (V_wind) with the direction vector (dP)
V_add = (sum(V_wind.*dP,2))./sqrt(sum(dP.^2,2));

dx = sqrt(sum(dP.^2,2)); % dx is the length of each subinterval in plist
dT = dx./(AirSpeed+V_add);  % dT = dP/dV
totalTime = 100*sum(dT);