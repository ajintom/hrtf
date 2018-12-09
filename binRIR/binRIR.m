clear all
close all
clc

% plot settings
x0=0;
y0=0;
width=1500;
height=200;
pos = 170;
p = -200;

% ------------------------ inits, loading IRs, applying crossover, adjust listener-src distance in IR ---------------------

direct_sound_distance_recording=7.5; % Distance between sound source and listener 
direct_sound_time_frame=0.005; % time frame in seconds after the maximum of the direct sound that shall be assigned to the direct sound
early_reflection_time=0.15; % defines the time frame in which early reflections are detected. Reduce for rooms with very short RT60
fs=48000;

% Load signal to binauralise
[sig,sf] = audioread('audio_drum.wav');
% [sig,sf] = audioread('audio_bday.wav');
% [sig,sf] = audioread('audio_sax.m4a');

% Load mono IR and convert to 48kHz : http://www.cksde.com/p_6_250.htm
[mon_ir, mon_ir_fs]=audioread('IR_bighall1.wav');
% [mon_ir, mon_ir_fs]=audioread('IR_dubwise.wav');
% [mon_ir, mon_ir_fs]=audioread('IR_minicave.wav');
mon_ir = mon_ir(:,1);
if (fs ~= mon_ir_fs)
    mon_ir=resample(mon_ir,double(fs),double(floor(mon_ir_fs)));
    disp '---mor_ir_fs changed to 48kHz---'
end

% reflection pattern adapted from rectangular room
reflection_indices.az=[0        -40.6013   10.3048 -274.7636  -17.1027  -40.6013         0 -274.7636 -266.8202  -58.5704 -145.1755 -260.5377 -194.4703];
reflection_indices.el=[90.0000   92.0652   92.4954   92.6401   86.2525  143.6983   23.3941  140.0207   93.2641  121.3566   90.4852 93.7756   93.8129];


% Load binaural noise
[binauralNoise, noise_FS]=audioread('BinauralWhiteNoise_KU100_Artificial.wav');
if (noise_FS ~= fs)
    warning 'sampling_rates do not match'
end

% Load HRIRs
load('HRIR_L2702_SFD.mat'); % far-field
load('HRIR_L2702_SFD_NF050.mat'); %near-field 0.5 m
load('HRIR_L2702_SFD_NF075.mat'); %near-field 0.75 m
load('HRIR_L2702_SFD_NF100.mat'); %near-field 1 m
load('HRIR_L2702_SFD_NF150.mat'); %near-field 1.5 m

figure;plot(mon_ir)
xlabel('Time samples'); ylabel('Amplitude');
title('Mono impulse response');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);

% mon_ir adjusting to match source-listener distance
[not_relevant mon_ir_max_pos]=max(mon_ir);
if mon_ir_max_pos<direct_sound_distance_recording *fs/340
    mon_ir=[zeros(floor(direct_sound_distance_recording *fs/340-mon_ir_max_pos+fs/1000),1)' mon_ir']';
else
    mon_ir=mon_ir(floor(mon_ir_max_pos-direct_sound_distance_recording *fs/340+fs/1000):length(mon_ir));
end

% hold on 
% plot(mon_ir)

% mon_ir -> next higher 2^x
recmax=2^floor(log2(length(mon_ir)));
if recmax/fs<0.5
    recmax=recmax*2;
end
if recmax< length(mon_ir)
    mon_ir=mon_ir(1:recmax);  
else
    mon_ir(length(mon_ir)+1:recmax)=0;    
end

% cross-over at 200Hz
Rp=1;
Rs=30;                                         
Wp=real(185/double(fs)*2);
Ws=real(235/double(fs)*2);
[n,Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[B_l,A_l]=cheby2(n,Rs,Wn);
mon_ir_low=filter(B_l,A_l,mon_ir);

% mon_ir above 200Hz
Wp=215/double(fs)*2;
Ws=165/double(fs)*2;
[n,Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[B_h,A_h]=cheby2(n,Rs,Wn,'high');
mon_ir=filter(B_h,A_h,mon_ir);

% figure;plot(mon_ir)

% ---------------------------------------- creating diffuse binaural reverb ----------------------------------------

framelength=1*floor(fs/1500); % 32 samples for 48kHz
bin_noise_seq_length=1*floor(fs/375); % corresponds to 128 samples at 48kHz

bin_ir_dif=zeros(length(mon_ir)+bin_noise_seq_length,2);
start_noise_seq=1;
end_noise_seq=bin_noise_seq_length;
hanning_noise=hanning(bin_noise_seq_length);
hanning_frame=hanning(framelength);

for k=1:framelength:length(mon_ir)-(framelength-1)
    start_noise_seq=start_noise_seq+bin_noise_seq_length;
    end_noise_seq=end_noise_seq+bin_noise_seq_length;
    if end_noise_seq>length(binauralNoise)
        start_noise_seq=floor(rand(1)*bin_noise_seq_length)+1;
        end_noise_seq=start_noise_seq+bin_noise_seq_length-1;
    end
    bin_ir_dif(k:k+framelength+bin_noise_seq_length-2,1)=bin_ir_dif(k:k+framelength+bin_noise_seq_length-2,1)+conv(mon_ir(k:k+framelength-1).*hanning_frame,binauralNoise(start_noise_seq:end_noise_seq,1).*hanning_noise);
    bin_ir_dif(k:k+framelength+bin_noise_seq_length-2,2)=bin_ir_dif(k:k+framelength+bin_noise_seq_length-2,2)+conv(mon_ir(k:k+framelength-1).*hanning_frame,binauralNoise(start_noise_seq:end_noise_seq,2).*hanning_noise);
end  

% could normalize?
bin_ir_dif=bin_ir_dif(length(bin_ir_dif)-length(mon_ir)+1:length(bin_ir_dif),:);

% ---------------------------------------- IR for Direct sound and reflections ----------------------------------------

% -- determine position of direct sound in mon_ir --

% startinddex is max of mor_ir

[Y,startindex] = max(abs(mon_ir));
direct_sound_time_frame=direct_sound_time_frame+startindex/fs;
mon_ir_er = mon_ir;%(1:startindex+floor(early_reflection_time*1.5*fs)); % ----- adapt ------

% get weighting function
weighting_function = w_func(fs,mon_ir_er,direct_sound_time_frame, 0.5, 0.7);

% diffuse IR used hereafter for bin_dir_er
bin_ir_diff = bin_ir_dif;%(1:startindex+floor(early_reflection_time*1.5*fs),:); % ----- adapt ------

bin_ir_diff(:,1)=bin_ir_diff(:,1).*sqrt(1-weighting_function);
bin_ir_diff(:,2)=bin_ir_diff(:,2).*sqrt(1-weighting_function);
% figure; plot(bin_ir_diffuse)
% title('Estimated diffuse part')

% Geometric part IR to be conv with HRIR
mon_ir_geo=mon_ir_er.*weighting_function;    


% -- estimate minima and maxima --

delta=0.1;
[maxima minima]=peakdet(weighting_function,delta); 

figure;
findpeaks(mon_ir,fs,'MinPeakHeight',0.3);
xlabel('Time samples'); ylabel('Amplitude');
title('Peaks of geometric reflections');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);

figure;
extend = 1000;
plot(weighting_function(minima(1,1)-extend:minima(length(minima)-1,1)+extend)); hold on;
plot(minima(:,1)-minima(1,1)+extend,minima(:,2),'r^','markerfacecolor',[1 0 0])
xlabel('Time samples'); ylabel('Amplitude');
title('Minima of weighting function');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);


% set the last minimum to the end of the weighting_function 
if (minima(size(minima,1),1)<=(maxima(size(maxima,1),1)))
    minima(size(minima,1)+1,1)=length(weighting_function);
end

% -- convolve section between minimas with HRIR of refl directions --

num_refl = length(reflection_indices.az);

kk = 0; 
ind_refl = 0;
beg = 1;            % first frame beginning
fin = minima(1,1);  % first frame finish
HRIR_len = 128;
bin_dir_er = zeros(length(mon_ir)+HRIR_len-1 , 2);

while (kk<=size(minima,1))&& (fin<length(mon_ir_er))
    
    if (kk>1)
        beg = minima(kk-1,1)+1;
        fin = minima(kk,1);
    end
    
    kk = kk + 1; 
    ind_refl = mod(ind_refl,num_refl)+1;
    
    az = mod(reflection_indices.az(ind_refl),360);
    el = mod(reflection_indices.el(ind_refl),360);
    
    % ideally choose based on direct_sound_distance_recording
    HRIR = getHRIR(HRIR_L2702_SFD, az , el ,'DEG');
   
    clear out
    out(:,1)=conv(HRIR(:,1),mon_ir_geo(beg:fin));
    out(:,2)=conv(HRIR(:,2),mon_ir_geo(beg:fin));
    bin_dir_er(beg:HRIR_len+fin-1,:) = bin_dir_er(beg:HRIR_len+fin-1,:) + out;
    
end

bin_dir_er = bin_dir_er(1:length(mon_ir),:);

% combine binRIR <- bin_ir_dif + bin_dir_er + mon_ir_low
bin_ir_synth=bin_ir_dif+bin_dir_er;

% bin_ir_synth = bin_ir_synth(1:length(mon_ir),:);

bin_ir_synth(:,1)=bin_ir_synth(:,1)+mon_ir_low;
bin_ir_synth(:,2)=bin_ir_synth(:,2)+mon_ir_low;

% bin_dir_er(:,2) = bin_dir_er(:,2)./2; % jugaad - fix it bro
% bin_ir_synth=bin_dir_er(1:length(bin_ir_diff),:)+bin_ir_diff;
% dir = [zeros(length(bin_ir_synth), 2)];
% dir(1,1) = 1;dir(1,2) = 1;
% m = zeros(numel(conv(dir(:,1),mon_ir(:,1))),2);
% m(:,1) = conv(dir(:,1), mon_ir(:,1));
% m(:,2) = conv(dir(:,2), mon_ir(:,1));


figure; plot(bin_ir_diff);
xlabel('Time samples'); ylabel('Amplitude');
title('Estimated diffuse part');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);

figure; plot(bin_dir_er);
xlabel('Time samples'); ylabel('Amplitude');
title('IR conv with HRIR for direct and reflections');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);

figure; plot(bin_ir_synth);
xlabel('Time samples'); ylabel('Amplitude');
title('Binaural RIR');
p = p+pos;
set(gcf,'position',[x0,p,width,height]);

% bin_ir_synth = bin_ir_dif; % uncomment to hear just bin_ir_diffuse
% [sig,sf] = audioread('DRUMSET3SHORT_48.wav');
% [sig,sf] = audioread('bday.wav');
% 
% HRIR = getHRIR(HRIR_L2702_SFD, 90 , 90 ,'DEG');bin_ir_synth = HRIR; % uncomment to test HRIR conv
% 

c = zeros(numel(conv(sig(:,1),bin_ir_synth(:,1))),2);
c(:,1) = conv(sig(:,1), bin_ir_synth(:,1));
c(:,2) = conv(sig(:,2), bin_ir_synth(:,2));

% normalize?
c(:,1) = c(:,1)./max(c(:,1));
c(:,2) = c(:,2)./max(c(:,2));
% 
% d = zeros(numel(conv(sig(:,1),dir(:,1))),2);
% d(:,1) = conv(sig(:,1), dir(:,1));
% d(:,2) = conv(sig(:,2), dir(:,2));
% 
% 

% Run following commands one by one for sound output

% sound(mon_ir,fs)
% sound(bin_ir_diff,fs)
% sound(bin_dir_er,fs)
% sound(bin_ir_synth,fs)
% sound(0.1*binauralNoise, noise_FS)
% sound(sig,sf);
% sound(c,sf);
% clear sound

audiowrite('demo_out_mon_ir.wav',mon_ir,fs);
audiowrite('demo_out_bin_ir_diff.wav',bin_ir_diff,fs);
audiowrite('demo_out_bin_dir_er.wav',bin_dir_er,fs);
audiowrite('demo_out_final_bin_ir_synth.wav',bin_ir_synth,fs);
audiowrite('demo_out_original_audio.wav',sig,fs);
audiowrite('demo_out_final_audio_conv_binRIR.wav',c,fs);

