N  = 100;
n  = 1:N; %time series
A  = 1.0;   %test signal amplitude
fs = 64e6;  %sample rate
fd = 50e6;  %test signal frequency
f  = fd/fs; %normalized frequency
fddc = 14.0e6; %ddc frequency
f2 = fddc/fs; %normalized ddc frequency

w_var = .01;                %noise variance
w = w_var*randn(1,N);      %noise vector
%sig = A*sin(2*pi*n*f) + w; %test signal
sig = w;
i_ddc = cos(2*pi*n*f2);
q_ddc = -sin(2*pi*n*f2);
i_sig = sig.*i_ddc;
q_sig = sig.*q_ddc;
hold off;
clg;
% plot(i_sig,'r'); 
% hold on;
% plot(q_sig,'b');
rxx = zeros(1,n);
for k=1:N
  rx_temp = 0;
  for l=1:N-k
    rx_temp = rx_temp + i_sig(k)*q_sig(l);
  end
  rxx(k) = rx_temp;
end

%plot(sig);
plot(rxx);