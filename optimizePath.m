function [optimalWayPoints] = optimizePath(W_y, W_x, numWayPoints, integrationFineness, AirSpeed, sizeX, sizeY) %#codegen
% This function sets up the arguments and calls the optimization solver 
% fmincon to find an optimal path.
%
% Copyright 2012-2019 The MathWorks, Inc. 
%

objectiveFun = @(P) getTimeFromPath(P,W_x,W_y,AirSpeed,sizeX,sizeY,integrationFineness);
%% 
% Set optimization options

% CODEGEN CHANGE: use optimoptions function to set options
% and constant for MaxFunctionEvaluations
opts = optimoptions("fmincon","Algorithm","sqp","MaxFunctionEvaluations",3000,...
    "Display","none");
%% 
% Use straight-line waypoints for the initial point

xWayPoints = linspace(0,sizeX,numWayPoints+2)';
yWayPoints = sizeY/2 * ones(numWayPoints+2,1);
ipt = [xWayPoints(2:end-1)'; yWayPoints(2:end-1)'];
ipt = ipt(:);
%% 
% Specify lower and upper bounds on the waypoints.

lb = zeros(size(ipt(:)));
ub = reshape([sizeX*ones(1,numWayPoints); sizeY*ones(1,numWayPoints)],[],1);
%% 
% Do the optimization

optimalWayPoints = fmincon(objectiveFun,ipt(:),[],[],[],[],lb,ub,[],opts);
optimalWayPoints = [0 sizeY/2; reshape(optimalWayPoints,2,[])'; sizeX sizeY/2];
end