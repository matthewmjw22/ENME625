function Output = objective_functionZDT1(Input)
x1 = Input(1);

F1 = x1; % Min
F2 = 1 - sqrt(x1);  %Min

Output = [F1 F2]
