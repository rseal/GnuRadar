N  = 1024*4;
n  = 1:N; %time series
A  = 2^11;   %test signal amplitude
fs = 64e6;  %sample rate
fd = 50.1024e6;  %test signal frequency
f  = fd/fs; %normalized frequency
fddc = -14.0e6; %ddc frequency
f2 = fddc/fs; %normalized ddc frequency

w_var = .00025;                %noise variance
w = w_var*randn(1,N);      %noise vector
sig = A*e.^(j*(2*pi*n*f) + w); %test signal
%sig = fixed(20,0,sig);
ddc = e.^-j*(2*pi*n*f2);
%ddc = fixed(24,0,ddc);
sig_ddc = sig.*ddc;

%sig_ddc = fixed(32,0,sig_ddc);
%i_ddc = cos(2*pi*n*f2);
%q_ddc = -sin(2*pi*n*f2);
%i_sig = sig.*i_ddc;
%q_sig = sig.*q_ddc;
%hold off;
%clf;
% plot(i_sig,'r'); 
% hold on;
% plot(q_sig,'b');
% rxx = zeros(1,n);
% for k=1:N
%   rx_temp = 0;
%   for l=1:N-k
%     rx_temp = rx_temp + i_sig(k)*q_sig(l);
%   end
%   rxx(k) = rx_temp;
% end

fftx = fft(sig_ddc,N);
px = fftx .* conj(fftx);
ppx = 10*log10(px/max(px));
plot(ppx);
%plot(rxx);