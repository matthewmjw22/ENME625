function pathPoints = waypointsToPath(p,sizeX,sizeY,fineness) %#codegen
% Interpolate the curve based on the discrete waypoints to generate a
% continuous path.
%
% Copyright 2012-2019 The MathWorks, Inc. 
%
% CODEGEN CHANGE: use "pchip" for the method parameter 
nP = size(p,1);
pathPoints = [interp1(1:nP,p(:,1),linspace(1,nP,fineness)',"pchip","extrap")...
    interp1(1:nP,p(:,2),linspace(1,nP,fineness)',"pchip","extrap")];

% Do not leave the box
pathPoints(:,1) = min(pathPoints(:,1),sizeX);
pathPoints(:,1) = max(pathPoints(:,1),0);
pathPoints(:,2) = min(pathPoints(:,2),sizeY);
pathPoints(:,2) = max(pathPoints(:,2),0);
end