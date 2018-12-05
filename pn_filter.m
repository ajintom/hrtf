function pn_out = pn_filter(x, fs, az, el, fig)

% applies delays based on pinna reflections

% compute angles in radians
az = az * pi/180; 
el = el * pi/180;

% define constants
ref = [ 1 0.5 -1 0.5 -0.25 0.25]; % reflection coefficients
A = [1 5 5 5 5];                  % amplitude
B = [2 4 7 11 13];                % offset
D = [1 0.5 0.5 0.5 0.5];          % scaling factor - for individualization

% memory allocation
T_pn = [0 0 0 0 0 0]; 
del_pn = [0 0 0 0 0 0];

% TO DO: implement fractional delaylines!!

% calculate 5 disting delays
for i = 2:6
T_pn(i) = A(i-1)*cos(az/2)*sin(D(i-1)*(pi/2-el)) + B(i-1); 
del_pn(i) = round(T_pn(i)/1000 * fs);
end

% sum and return input plus 5 delayed copies
pn_out = zeros(1,length(x)+max(del_pn)); 
pn = zeros(6, length(x)+max(del_pn)); 

for i = 1:6
pn(i, (del_pn(i)+1):(del_pn(i)+length(x)) ) = x*ref(i);
pn_out = pn_out + pn(i,:);
end


if fig == 1
    phi = linspace(0,60,1000)* pi/180;
    i=2;
    T_pn = A(i-1)*cos(az/2)*sin(D(i-1)*(pi/2-phi)) + B(i-1); 
    plot(phi,T_pn);
    xlabel('Elevation (degrees)')
    ylabel('Delay in samples')
    title('Delay time of 1st echo in pinna')
%     ylim([2 5])
    hold on
end



end