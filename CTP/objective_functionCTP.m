function Output = objective_functionCTP(Input)
x1 = Input(1);
x2 = Input(2);
x3 = Input(3);
x4 = Input(4);
x5 = Input(5);
x6 = Input(6);
x7 = Input(7);
x8 = Input(8);
x9 = Input(9);
x10 = Input(10);


F1 = x1;
F2 = abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))*(1 - sqrt(x1/(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25)))));

Output = [F1 F2];
