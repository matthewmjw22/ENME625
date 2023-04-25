% MEX code generation for optimizePath

% Use these types to make code as readable and simple as possible.
dblMatType = coder.typeof(double(1), [Inf, Inf], [1, 1]);
dblSclType = coder.typeof(double(1), [1, 1], [0, 0]);
charVecType = coder.typeof(char(1), [1, Inf], [1, 1]); % first dimension can be as large as we want

% Generate a MEX file
cfg = coder.config('mex');

codegen -config cfg optimizePath ...
    -args {dblMatType, dblMatType, dblSclType, dblSclType, dblSclType, dblSclType, dblSclType } -report