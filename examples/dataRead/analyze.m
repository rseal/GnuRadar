fid = fopen("binary.dat","r");
data = fread(fid,"int16");
grid on;
hold on;
plot(data(1:4:4000));
plot(data(2:4:4000));
plot(data(3:4:4000));
plot(data(4:4:4000));

