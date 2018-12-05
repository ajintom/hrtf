function [weighting_function] = w_func(fs,mon_ir,direct_sound_time_frame, thresh0, thresh1)
    
averaging_length=2^floor(log2(fs/128));
mw = conv_fft(hanning(averaging_length),abs(mon_ir));
mw=mw(averaging_length/2:length(mon_ir)+averaging_length/2-1);

weighting_function=(mw/median(mw)-1);

weighting_function(1:floor(direct_sound_time_frame*fs))=1;
for xx=1:length(weighting_function)
    if weighting_function(xx)<thresh0
        weighting_function(xx)=0;
    end
    if weighting_function(xx)>thresh1 % need to adapt based on mon_ir_er
            weighting_function(xx)=1;
    end
end
weighting_function=conv(weighting_function,hanning(averaging_length));
weighting_function=weighting_function(averaging_length/2:length(mon_ir)+averaging_length/2-1);
[xx position]=max(mon_ir);
weighting_function=weighting_function./max(abs(weighting_function));
weighting_function(1:position+floor(averaging_length/4))=1; 

end
