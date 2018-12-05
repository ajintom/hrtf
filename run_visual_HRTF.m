clear all
close all

az = 0;
el = 0;

h = rand(1,64); % impulse response

fs = 1000;
Nfft = 128;

% [H,F] = freqz(h,1,Nfft,fs);
% semilogx(F,mag2db(abs(H))); grid on;
% xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
% title('Frequency response - monaural')

s = h';

Ntheta = 15;
theta = linspace(1,150,Ntheta);
H1 = zeros(Ntheta,Nfft);
phi = linspace(1,150,15);
for i=1:length(theta)
    b = model(s,theta(i),el);
    [H1(i,:),F] = freqz(b(:,1),1,Nfft,fs);
end

xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - binaural left ear')

[xtheta,xfft] = meshgrid(1:Ntheta,1:Nfft);

surf(20*xtheta, log(xfft),-40+mag2db(abs(H1')));

