% function hrir = jma_getArbHRIR(HRIRs_sfd,az,el,mode)
%
% This function gives out a HRIR for an arbitrary direction, based on
% HRTF-Interpolation in the spherical Fourier domain. The function is based
% on the SOFiA toolbox from Benny Bernschütz.
%
% Reference: 
% Bernschütz, B. (2016). Microphone Arrays and Sound Field Decomposition 
%                        for Dynamic Binaural Recording. TU Berlin.
% 
% Dependencies: SOFiA toolbox, HRIRs_sfd
%
% Input:
% HRIRs_sfd - struct with HRIRs in spatial Fourier domain
% az        - azimuth of HRIR (az = 0 - 2*pi / 0° - 360°)
% el        - elevation of HRIR (el = 0 - pi / 0° - 180° (0 = above the head, 
%             pi = below the head))
% mode      - 'RAD' or 'DEG' (radiant or degree). RAD is default
%
% Output:
% hrir      - Result of HRTF interpolation in the spherical Fourier domain for
%             chosen direction
%
% (C) 2016 by JMA, Johannes M. Arend
%             Technische Hochschule Köln
%             University of Applied Sciences
%             Institute of Communication Systems
%             Department of Acoustics and Audio Signal Processing 

function hrir = jma_getArbHRIR(HRIRs_sfd,az,el,mode)

if nargin < 4
    mode = 'RAD';
end

if mode == 'DEG';
    az = az*pi/180;
    el = el*pi/180;
end

if az < 0 || el < 0
    error('Only positive azimuth/elevation values allowed!');
end

Hl_nm = HRIRs_sfd.Hl_nm;
Hr_nm = HRIRs_sfd.Hr_nm;

Hl = sofia_itc(Hl_nm, [az el]);
Hr = sofia_itc(Hr_nm, [az el]);
Hl = conj([Hl(:,:), conj(fliplr(Hl(:,2:end-1)))])';
Hr = conj([Hr(:,:), conj(fliplr(Hr(:,2:end-1)))])';
hl = real(ifft(Hl));
hr = real(ifft(Hr));
hl = hl(1:end/2,:);
hr = hr(1:end/2,:);

hrir = [hl,hr];

end

