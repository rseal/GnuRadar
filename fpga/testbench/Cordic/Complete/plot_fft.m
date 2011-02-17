
y      = load('data/output.dat');

offset = 10;
y      = y(offset:end);

y_fft  = fft(y,1024);

y_fft  = fftshift( y_fft .* conj(y_fft) )

plot(10*log10(y_fft))

