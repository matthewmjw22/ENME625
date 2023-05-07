function Output = objective_functionZDT3(Input)
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
x11 = Input(11);
x12 = Input(12);
x13 = Input(13);
x14 = Input(14);
x15 = Input(15);
x16 = Input(16);
x17 = Input(17);
x18 = Input(18);
x19 = Input(19);
x20 = Input(20);
x21 = Input(21);
x22 = Input(22);
x23 = Input(23);
x24 = Input(24);
x25 = Input(25);
x26 = Input(26);
x27 = Input(27);
x28 = Input(28);
x29 = Input(29);
x30 = Input(30);



g = 1 + (9/29)*sum(Input(2:30));
F1 = x1; % Min
F2 = (1 - sqrt(x1/g) - (x1/g)*sin(10*pi*x1))*g;  %Min
Output = [F1 F2];
