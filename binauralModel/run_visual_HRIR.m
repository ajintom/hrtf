clear all
close all

az = 0;
el = 0;
n = 1000;
imp = [zeros(1,n/8) 1 zeros(1,n/2)];
si = imp';

Ntheta = 10;
theta = linspace(1,150,Ntheta);
lol = model(si,0,0);
N = length(lol(1:n,1));
bi = zeros(Ntheta,N);
phi = linspace(1,150,15);
for i=1:length(theta)
    lol = model(si,theta(i),el);
    bi(i,:) = lol(1:n,1)';
end



[xtheta,xN] = meshgrid(1:Ntheta,1:N);

surf(xtheta, xN,bi');


