function binaural_out = model(sig, az, el)

% instruction to run: 

% az = -90;el = 80; 
% [sig,fs] = audioread('phrase-sax.wav');
% sound(model(sig, az, el),fs);
%---------------------------------------------

fs = 44100; % sample rate

if sig == 1
    
    % plotting frequency response of head shadow filter for various azimuths
    figure;
    theta = [0,60,75,90,105,120,135,150,160,180];
    for i=1:length(theta)
        hs_filter(1,fs,theta(i),1);
    end

    % plotting torso time delays for various angles
    figure;
    theta = linspace( 0,  pi/3, ((pi/3)/(pi/12)) );
    theta = linspace( 0, 90 , 5 );
    for i=1:length(theta)
        ts_filter(1, fs, theta(i), 1,1);
    end

    % plotting 1st pinna reflection time delays for various angles
    figure;
    theta = linspace( 0,  pi/3, ((pi/3)/(pi/12)) );
    theta = linspace( -179, 179 , 10 );
    for i=1:length(theta)
        pn_filter(1, fs, theta(i), 1,1);
    end



end


%------------------------------


% to avoid division by 0
if (abs(az) == 180)
az = 179 * sign(az);
end

sig = sig';

% Apply Head Shadowing to input (-az for left ear)
r_hs = hs_filter(sig, fs, az, 0); 
l_hs = hs_filter(sig, fs, -az, 0);

% Apply a torso delay to input (-az for left ear)
r_ts = ts_filter(sig, fs, az, el, 0);
l_ts = ts_filter(sig, fs, -az, el, 0);

% Sum the head shadowed/torso delayed signals: This is the
% signal that makes it to the outer ear (pre pinna)

r_pn = zeros(1,max(length(r_hs),length(r_ts))); 
r_pn = r_pn + r_hs; 
r_pn = r_pn + r_ts;

l_pn = zeros(1,max(length(l_hs),length(l_ts))); 
l_pn = l_pn + l_hs; 
l_pn = l_pn + l_ts;

% Pinna reflections to the prepinna signals (-az for left ear)
r = pn_filter(r_pn, fs, az, el, 0); 
l = pn_filter(l_pn, fs, -az, el, 0);

% Pad zeros 
if ( length(r) < length(l) )
r = [r zeros(1,length(l)-length(r))];
else
l = [l zeros(1,length(r)-length(l))]; 
end

% return final headphone stereo track
binaural_out = [r' l'];
binaural_out = binaural_out./max(binaural_out);
% sound(binaural_out,fs);

end



