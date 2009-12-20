sampleRate = 64e6;
bandwidth = 500e3;
t = 1.0/bandwidth;
ipp=4e-3;
window=466;
dc=0.4;
ipps=250;
heights=bandwidth*ipp*dc;
fftSize = 8192;
numch = 1;

fid = fopen("binary.dat","r");
data = fread(fid,"int16");
data = reshape(data, numch*2, length(data)/(numch*2));

offset = 1;

#i and q channels 1 and 2
ch0 = data(1,:);
ch1 = data(2,:);
%ch2 = data(3,:);
%ch3 = data(4,:);

length(ch0)
length(ch0)/window

%ch0 = ch0(1:2400*window);
%ch1 = ch1(1:2400*window);
%ch2 = ch2(1:2400*window);
%ch3 = ch3(1:2400*window);

%ch0 = reshape(ch0,window,length(ch0)/window);
%ch1 = reshape(ch1,length(ch1)/window,window);
%ch2 = reshape(ch2,length(ch2)/window,window);
%ch3 = reshape(ch3,length(ch3)/window,window);

% chA = complex(ch0,ch3);
% chB = complex(ch1,ch2);

% tempA = zeros(fftSize,1);
% tempB = zeros(fftSize,1);
% avgA = zeros(fftSize,1);
% avgB = zeros(fftSize,1);

% for i=1:window
% 	tempA = fft(chA(:,i),fftSize);
% 	tempA = tempA .* conj(tempA);
% 	tempB = fft(chB(:,i),fftSize);
% 	tempB = tempB .* conj(tempB);
% 	avgA = avgA + tempA;
% 	avgB = avgB + tempB
% end

% ss = 2*bandwidth/fftSize;
% x_axis = -1*bandwidth:ss:bandwidth;
% x_axis = x_axis(1:length(x_axis)-1);

% avgA = fftshift(avgA);
% avgA = avgA/window;
% log_avgA = 20*log10(avgA);
% log_avgA = log_avgA - max(log_avgA);

% avgB = fftshift(avgB);
% avgB = avgB/window;
% log_avgB = 20*log10(avgB);
% log_avgB = log_avgB - max(log_avgB);

% plot(x_axis,log_avgA);
% title("Signal=50.2MHz,Sample Rate=64MSPS,DDC=-14.0MHz,Integration=1 sec");
% grid on;
% xlabel("Frequency (Hz)");
% ylabel("dB");

% print -deps "snr-50.2.eps"

% plot(x_axis,log_avgB);
% title("Signal=50.02MHz,Sample Rate=64MSPS,DDC=-14.0MHz,Integration=1 sec");
% grid on;
% xlabel("Frequency (Hz)");
% ylabel("dB");

% print -deps "snr-50.02.eps"
