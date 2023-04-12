function Output = objective_functionZDT2(Input)
x1 = Input(1);

F1 = x1; % Min
F2 = 1 - (x1)^2;  %Min

Output = [F1 F2];
