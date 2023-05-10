clc
clear all
close all

%% Add all necessary folder paths
addpath(genpath('Developed MOGA'), genpath('MATLAB MOGA'), genpath('Supporting Functions'), genpath('Flight Path Problem'));

%% General Documentation Statement

% Elements of this code were inspired from the GA/MOGA framework developed
% by Dr. Aute and provided to the class. Other elements of the code were
% inspired from MATLAB documentation. Additionally, elements of this code
% were debugged using the OpenAI chatGPT 3.5/4 platform. 

% Author Contact information:
% Jon Gabriel: jgabrie2@umd.edu
% Matthew Weiner: weiner22@umd.edu
% Joe Southgate: jmsouthg@umd.edu


%% Directions For Use

% The below FUNCTION LIBRARY outlines each of the avaiabile test problem
% calling functions that can explored in this code base. 

% The first function library labled "OUR DEVELOPED MOGA" details which
% functions can be called to explore the performance of our developed MOGA
% algorithm on the sesires of test problems. 
% THe second function library titled "MATLAB IMPLEMENTED TEST PROBLEM
% SOLVERS" details the MATLAB MOGA aolved test problem functions

% It is recommended that the user simply copy and paste the function
% associated with the desired test problem and algorithm into the area
% labeled "CALL THE TEST PROBLEM YOU WISH TO RUN", and simply click run.
% Visualizations and data associated with the pareto fronts will displayed
% along with a progress bar detailing the progress of the solver (for our
% implemented solver)

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%% FUNCTION LIBRARY

% TEST PROBLEM ---------> FUNCTION TO CALL

% OUR DEVELOPED MOGA
%******************************************************************
%    OSY       ---------> RUN_OSY(15, 250, 120);
%    CTP       ---------> RUN_CTP(15, 250, 120);
%    TNK       ---------> RUN_TNK(15, 250, 120);
%   ZDT1       ---------> RUN_ZDT1(15, 400, 120);
%   ZDT2       ---------> RUN_ZDT2(15, 400, 120);
%   ZDT3       ---------> RUN_ZDT3(15, 400, 120);
%   TNK MORO   ---------> RUN_TNK_MORO(15, 600, 120);
%******************************************************************

% MATLAB IMPLEMENTED TEST PROBLEM SOLVERS
%******************************************************************
%    OSY       ---------> RunMOGA_OSY();
%    CTP       ---------> RunMOGA_CTP();
%    TNK       ---------> RunMOGA_TNK();
%   ZDT1       ---------> RunMOGA_ZDT1();
%   ZDT2       ---------> RunMOGA_ZDT2();
%   ZDT3       ---------> RunMOGA_ZDT3();
%******************************************************************

%##########################################################################
%% CALL THE TEST PROBLEM YOU WISH TO RUN
RUN_OSY_Obj_First(15, 250, 120);
%##########################################################################
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
