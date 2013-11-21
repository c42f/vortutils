function l = vortLength(vortLine)
% Compute the length of a vortex and deals with vortices crossing the
% boundaries with periodic conditions
%
% vortLine - the trace of the vortex holding the x,y,z coordinates of its
%            path

stepsLength = sum(diff(vortLine).^2,2);
l = sum(stepsLength(stepsLength <= 1));

return
