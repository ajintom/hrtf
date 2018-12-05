% plots HRTF and HRIR response of the model

clear all
close all

az = 120;
el = 30;

h = rand(1,64); % impulse response

fs = 1000;
Nfft = 128;
[H,F] = freqz(h,1,Nfft,fs);
semilogx(F,mag2db(abs(H))); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - monaural')

s = h';
b = model(s, az,el); 

[H1,F] = freqz(b(:,1),1,Nfft,fs);
[H2,F] = freqz(b(:,2),1,Nfft,fs);
figure;
semilogx(F,10+mag2db(abs(H1))); grid on;
hold on
semilogx(F,mag2db(abs(H2))); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency response - binaural')

imp = [zeros(1,50) 1 zeros(1,100)];
si = imp';
bi = model(si, az,el); 
figure;
plot(bi(:,1)); 
hold on
plot(bi(:,2)); 
xlabel('Time(samples)'); ylabel('Magnitude');
title('Impulse response - binaural')
