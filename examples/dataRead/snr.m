sampleRate = 64e6;
bandwidth = 500e3;
t = 1.0/bandwidth;
ipp=1e-3;
window=512;
dc=0.4;
ipps=1000;
heights=bandwidth*ipp*dc;
fftSize = 8192;

fid = fopen("binary.dat","r");
data = fread(fid,"int16");
data = reshape(data, 4, length(data)/4);

offset = 1;

#i and q channels 1 and 2
ch0 = data(1,:);
ch1 = data(2,:);
ch2 = data(3,:);
ch3 = data(4,:);

length(ch0)
length(ch0)/window

cha = reshape(ch0,window,length(ch0)/window);
chb = reshape(ch1,window,length(ch1)/window);
chc = reshape(ch2,window,length(ch2)/window);
chd = reshape(ch3,window,length(ch3)/window);

chA = complex(cha,chb);
chB = complex(chc,chd);

tempA = zeros(fftSize,1);
tempB = zeros(fftSize,1);
avgA = zeros(fftSize,1);
avgB = zeros(fftSize,1);

for i=1:1000
  tempA = fft(chA(20:end,i),fftSize);
  tempA = tempA .* conj(tempA);
  tempB = fft(chB(20:end,i),fftSize);
  tempB = tempB .* conj(tempB);
  avgA = avgA + tempA;
  avgB = avgB + tempB;
end
 
ss = 2*bandwidth/fftSize;
x_axis = -1*bandwidth:ss:bandwidth;
x_axis = x_axis(1:length(x_axis)-1);

avgA = fftshift(avgA);
avgA = avgA/window;
log_avgA = 10*log10(avgA);
log_avgA = log_avgA - max(log_avgA);

avgB = fftshift(avgB);
avgB = avgB/window;
log_avgB = 10*log10(avgB);
log_avgB = log_avgB - max(log_avgB);

plot(x_axis,log_avgA);
title("Signal=50.2MHz,Sample Rate=64MSPS,DDC=-14.0MHz,Integration=1 sec");
grid on;
xlabel("Frequency (Hz)");
ylabel("dB");

print -deps "snrA.eps"

plot(x_axis,log_avgB);
title("Signal=50.02MHz,Sample Rate=64MSPS,DDC=-14.0MHz,Integration=1 sec");
grid on;
xlabel("Frequency (Hz)");
ylabel("dB");

print -deps "snrB.eps"
