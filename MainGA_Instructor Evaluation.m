% ENME 625 Multidisciplinary Optimization Spring 2020
% University of Maryland College Park

% Genetic Algorithm (GA) Project
% Main Function template for assessing project codes.

% This template code is mean't to faciliate instructor evaluation
% The individual test functions could be called in any order.

% Last Update 20200420 : Azarm, SA, Aute VC., 

function m = MainGA_InstructorEvaluation()
m=0;
% This is the main function
% Add individual methods here to run the test problems.

% MUST have functions to run the test problems individually.

% Your testing can be conducted in any order.

% FIRST SET Example function calls
% Below example runs the test problem-1. 
% It should show the final Pareto plot.
% You can also include the Pareto metric(s) values as a part of the chart
% title, to faciliate ease of use.


 RunMOGA_ZDT1();
 
 % Other test problem functions will look as follows.
 % You may implement these in any order.
 
% RunMOGA_ZDT2();
% RunMOGA_ZDT3();
% RunMOGA_OSY();
% RunMOGA_TNK();
% RunMOGA_CTP();

% This is the robust version
%RunRMOGA_TNK()
%RunRMOGA_FPP()


% SECOND EXAMPLE

% This function takes a numeric argument for statistical analysis on the
% algorithm.
% For example the below call could run your MOGA 15 times for the ZDT1 test
% problem, and show results (descriptive statistics for the two objectives) on the screen.
% For this method, you may want to suppress the generation of any
% intermediate plots.
 RunMOGA_ZDT1(15);



% ADDITIONAL TIPS
% 1: If you are using local files/folders to store any intermediate data or
% output files, make sure you use relative paths, that way, when the
% instructors run your scripts, we do not face "file/folder not found"
% errors; as your computer file paths will be different than ours.


%2: If you wish to time your code, you can use the built-in tic and toc
% functions in Matlab. This may come-in handy if you are trying out
% different non-dominated sorting methods, or different algorithm settings.


%3: Make sure your code is well documented, especially the functions for
% non-dominated sorting and the pareto metrics.


end