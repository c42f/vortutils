function vorticity = vortex_detect2d(psi)
% Detect vortices in a field psi, on plaquettes of a 2D grid.
%
% Inputs:
%   psi - complex wavefunction in which to detect vortices.
%
% Outputs:
%   vorticity - an array containing 0, +1 or -1 to indicate the presence of
%               vortices.  size(vorticity) == size(psi)-1.

	vorticity = phase_winding2d(angle(psi));

end
