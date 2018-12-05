function c = conv_fft(a, b)
% convolution in frequency domain..faster in Matlab
L = numel(a) + numel(b) - 1;
K = 2^nextpow2(L);

c = ifft(fft(a, K) .* fft(b, K));
c = c(1:L);
