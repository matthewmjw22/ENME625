function [C, Ceq] = nonlinear_constraintsRunMOGA_CTP_batch(Input)
[num_inputs, num_vars] = size(Input);
C = zeros(num_inputs, 1);
Ceq = [];

for i = 1:num_inputs
    x1 = Input(i, 1);
    x2 = Input(i, 2);
    x3 = Input(i, 3);
    x4 = Input(i, 4);
    x5 = Input(i, 5);
    x6 = Input(i, 6);
    x7 = Input(i, 7);
    x8 = Input(i, 8);
    x9 = Input(i, 9);
    x10 = Input(i, 10);

    C(i, 1) = -(cos(-.2*pi)*(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))*(1 - sqrt(x1/(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))))) -1) - sin(-.2*pi)*x1    -     0.2*abs(sin(10*pi*(sin(-.2*pi)*(abs(1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25) -1) + cos(-.2*pi)*x1)^1))^6);                        
end