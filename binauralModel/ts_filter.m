function ts_out = ts_filter(x, fs, az, el, fig)

% applies shoulder reflection delay in ms
T_sr = 1.2*(180 - az)/180 * (1 - 0.00004*((el - 80)*180/(180 + az)).^2);


% fractional delay (input signal, delay amount, 0:'linear'/ 1:'all-pass')
del_sh = T_sr/1000*fs;
ts_out = frac_del(x,abs(del_sh),1);

if fig == 1
    phi = linspace(-100,100,1000);
    T_sr = 1.2*(180 - az)/180 * (1 - 0.00004*((phi - 80)*180/(180 + az)).^2);
    plot(phi,T_sr)
    xlabel('Elevation (degrees)')
    ylabel('Time delay (ms)')
    title('Delay time of echo')
    ylim([-0.5 1.5])
    hold on
end

end

