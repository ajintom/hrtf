function hs_out = hs_filter(x,fs, az, fig)

% hs_filter applies head shodowing effects to input signal x for given
% azimuthal angle, az

az = az + 90;    % for ease of implementation 
az0 = 150;       % theta0
al_min = 0.1;    % alpha_min
a = 0.08;        % effective head radius
c = 334;         % speed of sound
w0 = c/a;

% match position of zeros with respect to az
al = 1 + al_min/2 + (1 - al_min/2) * cos(az / az0 * pi);

%trasnfer function definition 
B = [(al + w0/fs) / (1 + w0/fs), ( -al + w0/fs ) / (1 + w0/fs)] ;
A = [1, -(1 - w0/fs) / (1 + w0/fs)] ;

% HS introduces group delay, at az = 90, HS_filter provides 50% more LF del
if (abs(az) < 90)
    gd = - fs/w0 * (cos(az * pi/180) - 1) ;
else
    gd = fs/w0 * ((abs(az) - 90) * pi/180 + 1); 
end;

a = (1 - gd)/(1 + gd);  % allpass filter 

mag = filter(B, A, x);
hs_out = filter([a, 1],[1, a], mag);

if fig == 1
    w = linspace(0.1,100,1000);
    h = freqz(B,A,1000,fs);
    dB = mag2db(abs(h));

    semilogx(w,dB)
    xlabel('Normalized frequency')
    ylabel('Magnitude (dB)')
    title('Frequency response of Head-shadow filter')
    ylim([-25 10])
    hold on
end

end
