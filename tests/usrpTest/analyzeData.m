x0 = load testdata0.dat;
x1 = load testdata1.dat;
x2 = load testdata2.dat;
x3 = load testdata3.dat;
x4 = load testdata4.dat;
x5 = load testdata5.dat;
x6 = load testdata6.dat;
x7 = load testdata7.dat;
x8 = load testdata8.dat;
x9 = load testdata9.dat;

x_a = zeros(1,length(x0)*2);
x_b = zeros(1,length(x0)*2);
x_c = zeros(1,length(x0)*2);

for i=1:length(x0)
   x_a(i) = x0(i);
end

for i=length(x0)+1:length(x0)*2
   x_a(i) = x1(i-length(x0));
end

for i=1:length(x0)
   x_b(i) = x2(i);
end

for i=length(x0)+1:length(x0)*2
   x_b(i) = x3(i-length(x0));
end

for i=1:length(x0)
   x_c(i) = x4(i);
end

for i=length(x0)+1:length(x0)*2
   x_c(i) = x5(i-length(x0));
end

plot(x_a);
hold on;
plot(x_b);
hold on;
plot(x_c);


