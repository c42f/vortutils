function smoothedLine = smooth_vort_line(line)
% smoothTrace = smooth_trace(line)
%
% Smooth out the trace of a vortex line using a spline.  Requires the splines
% toolbox.
% 
% Input:
%   line - Vortex line to smooth out.  should be dimensions Nx3 where N is the
%          number of points.
%
% Output:
%   smoothedLine - smoothed version of the vortex line.

lineLen = size(line,1);
if(lineLen > 1)
	% Construct a smooth spline representation of the vortex line
	% that.
	smoothTrace = csaps(1:lineLen, vortTrace.', 0.2, 1:lineLen).';
else
	smoothedLine = line;
end
