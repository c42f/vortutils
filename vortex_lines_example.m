% Create some sample fields to bench the vortex detection algorithm

% disp('generating input field with simple vortex line...');
% L = 20.0;
% N = 20;
% dx = L/N;
% x = -L/2:dx:L/2-dx;
% [X,Y,Z] = meshgrid(x,x,x);
% a = 4;
% psi = (X+1i*Y).*exp(-(X.^2 + Y.^2)/a^2) - (X-1i*Z).*exp(-((X-3).^2 + (Z+7).^2)/a^2);
% psi = (X+1i*Y).*exp(-(X.^2 + Y.^2)/a^2);
% psi(:,:,10:end) = exp(-(X(:,:,10:end).^2 + Y(:,:,10:end).^2)/a^2);

% Generate a random complex field using cubic interpolation of random values.
% This is very likely to have some vortices threading through it.
disp('generating random input field...');
N = 5;
psiIn = zeros(N+1,N+1,N+1);
psiIn(1:N,1:N,1:N) = complex(randn(N,N,N), randn(N,N,N));
psiIn(end,:,:) = psiIn(1,:,:);
psiIn(:,end,:) = psiIn(:,1,:);
psiIn(:,:,end) = psiIn(:,:,1);
x1 = linspace(0,1, N+1);
N2 = 100;
x2 = (0:N2-1)/N2;
[x,y,z] = meshgrid(x2,x2,x2);
psi = interp3(x1,x1,x1, psiIn, x,y,z, 'cubic');

% we assume periodic boundary conditions for this examples
periodicBoundary = 1;

% Detect the resutling vortices, and trace vortex lines.
disp('detecting vortices...');
vorticity = vortex_detect3d(psi,periodicBoundary);
disp('tracing vortex lines...');
vortLines = vortex_trace_all(vorticity,0);

% Plot all vortex lines
plotVortexLines(vortLines);