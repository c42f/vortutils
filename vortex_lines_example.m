
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

% Detect the resutling vortices, and trace vortex lines.
disp('detecting vortices...');
vorticity = vortex_detect3d(psi);
disp('tracing vortex lines...');
vortLines = vortex_trace_all(vorticity);


% Plot all vortex lines
clf;
hold on;

for ii = 1:length(vortLines)
    vline = vortLines{ii};
    % Plot the vortex line.  facePos is the actual positions of the vortices
    % on the faces of the 3D mesh; half way between the cell centres.
    facePos = 0.5*(vline(1:end-1,:) + vline(2:end,:));
    if(all(vline(1,:) == vline(end,:)))
        % Visualize vortex loops in blue.
        plot3(facePos(:,1), facePos(:,2), facePos(:,3), '-');
    else
        % Visualize vortex lines in red
        plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'r-');
    end
    % Construct a smooth spline representation of the vortex line and plot
%    smoothed = smooth_vort_line(facePos);
%    plot3(smoothed(:,1), smoothed(:,2), smoothed(:,3), 'k-', 'linewidth', 1);
end

set(gca(), 'projection','perspective');
set(gca(), 'box', 'on');
%axis('equal');

