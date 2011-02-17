num_fft_points = 512;

x              = load('data/output.dat');
x_fft          = fft(x,num_fft_points);
x_fft          = fftshift( x_fft .* conj( x_fft ) );
x_fft          = x_fft/max(x_fft);

y              = load('data/golden_output.dat');
y_fft          = fft(y,num_fft_points);
y_fft          = fftshift( y_fft .* conj( y_fft ) );
y_fft          = y_fft/max(y_fft);

clf;
plot(10*log10(x_fft));
hold on;
plot(10*log10(y_fft),'r');

