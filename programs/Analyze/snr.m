sampleRate = 64e6;
bandwidth = 1e6;
t = 1.0/bandwidth;
ipp=1e-3;
window=512;
dc=0.4;
ipps=1000;
heights=bandwidth*ipp*dc;
fftSize = 256;

fid = fopen("binary.dat","r");
data = fread(fid,"int16");
data = reshape(data, 4, length(data)/4);

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

chA = 8*complex(cha,chb);
chB = 8*complex(chc,chd);

tempA = zeros(fftSize,1);
tempB = zeros(fftSize,1);
avgA = zeros(fftSize,1);
avgB = zeros(fftSize,1);

samples=ipps;
for i=1:samples
  tempA = fft(chA(16:end,i),fftSize)/window;
  tempA = tempA .* conj(tempA);
  tempB = fft(chB(16:end,i),fftSize)/window;
  tempB = tempB .* conj(tempB);
  avgA = avgA + tempA;
  avgB = avgB + tempB;
end

avgA = avgA/samples;
avgB = avgB/samples;

ss = bandwidth/fftSize;
x_axis = -1*bandwidth/2.0:ss:bandwidth/2.0;
x_axis = x_axis(1:length(x_axis)-1);

avgA = fftshift(avgA);
log_avgA = 10*log10(avgA/max(avgA));

avgB = fftshift(avgB);
log_avgB = 10*log10(avgB/max(avgB));

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
