function [density_dimples, density_cut] = density_trace3d(psi,threshold)
% Find the points in a 3D grid where the density falls below threshold
% times the mean density
%
% Params:
%   psi - the 3d wavefunction
%   threshold - the percent of the mean density that flags a dimple
%               (espressed by a real number between 0 and 1)
%
% Output:
%   density_dimple - a binary 3d array where 1s marks density dimples

if ( (threshold < 0) || (threshold > 1) )
    error('The value for the threshold must be between 0 and 1');
end

rho = abs(psi).^2;
meanDensity = mean(rho(:));
density_cut = meanDensity * threshold;
density_dimples = round(heaviside(rho - density_cut));