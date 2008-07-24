function vortices = phase_winding2d(phase)
% Detect phase winding about the grid plaquettes of a 2D phase profile.
%
% The resulting grid of detected vortices is of size  size(phase)-1.

	filter1 = [-1  1; 1 -1];
	filter2 = [ 1 -1;-1  1];

	phase = squeeze(phase);

	vortices = round( (conv2(unwrap(phase,[],1),filter1,'valid') + ...
					   conv2(unwrap(phase,[],2),filter2,'valid'))/(2*pi) );
end
