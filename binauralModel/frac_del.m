function f_del = frac_del(x, delayamount, interpolation)

% Define the desired delay (in samples)
M = delayamount;

delta = M - floor(M);
a = (1 - delta) / (1 + delta);
M = floor(M);
% samples shift forward by delta

% Define the number of time steps to compute.
N = length(x);

% Define our input signal.
% x = [1,1, zeros(1, N-2)];  % impulse
% x = 1:N;  % ramp

% Allocate the delay-line and output buffers.  The delayline buffer
% itself can be longer than our delay value.
dLength = M + 50;
delayline = zeros(1, dLength);
y = zeros(1, N);        % output buffer
ya = zeros(1, N);        % output buffer

% Set the read and write pointer locations.
wptr = 1;               % write pointer
rptr = wptr - M;        % read pointer chases write

if (rptr <= 0)
  rptr = rptr + dLength;
end
pptr = rptr - 1;        % previous pointer lags read pointer by 1 for interpolation calculation
if pptr <= 0
  pptr = pptr + dLength;
end
delta = 1 - delta;      % for ease of calculation and thought process
ynm1 = 0;    
for n = 1:N,
    
  % Write the delay line input.
  delayline(wptr) = x(n);
  
  % Read the delay line output.
  y(n) = delayline(pptr) + delta*((delayline(rptr))- delayline(pptr));
  ya(n) = a * (delayline(pptr) - ynm1) + delayline(wptr);
  ynm1 = ya(n);
  %   disp(pptr),disp(rptr),disp(wptr),disp("--")

  % Increment the pointer and check end conditions.
  rptr = rptr + 1;
  wptr = wptr + 1;
  pptr = pptr + 1;
  if wptr > dLength, wptr = 1; end
  if rptr > dLength, rptr = 1; end
  if pptr > dLength, pptr = 1; end
end

if interpolation == 0
    f_del = y;
end
if interpolation == 1
    f_del = ya;
end

end

