function Output = objective_functionRunMOGA_OSY(Input)
x1 = Input(1);
x2 = Input(2);
x3 = Input(3);
x4 = Input(4);
x5 = Input(5);
x6 = Input(6);

F1 = -(25*(x1-2)^2 + (x2 -2)^2 + (x3-1)^2 + (x4-4)^2 + (x5-1)^2); % Min
F2 = x1^2+x2^2+x3^2+x4^2+x5^2 + x6^2;  %Min

Output = [F1 F2];
