x = [32768 20628 0 -6282 0 3135 0 -1681 0 873 0 -412 0 165 0 -49];
y = fft(x,256);
y = y .* conj(y);
y = y/max(y);
y = fftshift(10*log10(y));
xa = -pi:2*pi/256:pi-pi/256;

plot(xa,y);
grid on;
title('USRP 31-tap halfband compensation filter - frequency domain');
xlabel('fractional frequency (f/f_s)');
ylabel('normalized magnitude (dB)');
print -deps 'hb.eps';

plot(x/32768);
grid on;
title ('USRP 31-tap halfband compensation filter - time domain')
xlabel('time samples (n)');
ylabel('normalized magnitude \abs(A)')
print -deps 'hb-time.eps';

