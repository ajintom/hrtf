clear all
close all

az = 0;
el = 0;

h = rand(1,64); % impulse response

fs = 1000;
Nfft = 128;
[H,F] = freqz(h,1,Nfft,fs);
semilogx(F,mag2db(abs(H))); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - monaural')

s = h';

offset = 0;
figure;
theta = linspace(1,250,15);
phi = linspace(1,150,15);
for i=1:length(theta)
    b = model(s,theta(i),el);
    [H1,F] = freqz(b(:,1),1,Nfft,fs);
    semilogx(F,offset+mag2db(abs(H1))); grid on;
    hold on
    offset = offset + 30;
end

xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - binaural left ear')

figure;
for i=1:length(theta)
    b = model(s,theta(i),el);
    [H2,F] = freqz(b(:,2),1,Nfft,fs);
    semilogx(F,offset+mag2db(abs(H2))); grid on;
    hold on
    offset = offset + 30;
end

xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - binaural right ear')