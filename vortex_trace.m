function [lineIndices] = vortex_trace(vorticity, startPos);
% lineIndices = vortex_trace(vorticity, startPos);
%
% Trace a vortex line in the given vorticity field.  Each cubic cell in the
% vorticity field is represented by a six-element array, containing the
% vorticity on the faces of the cell.
%
% TODO: This function doesn't deal with periodic boundaries yet.
%
% Input:
%   vorticity - An array containing the vorticity stored in cell volumes
%   startPos - Starting index into the vorticity array.
%
% Output:
%   lineIndices - Indices of cells through which the line passes.

% Find direction to move in.
startCellVorticity = vorticity(startPos(1),startPos(2),startPos(3),:);
faceIdxIdx = find(startCellVorticity ~= 0);

if(numel(faceIdxIdx) == 0)
	lineIndices = [];
	return;
end

handedness = startCellVorticity(faceIdxIdx(1));
forwardTrace = trace_direction(vorticity, startPos, faceIdxIdx(1));
if(all(forwardTrace(1,:) == forwardTrace(end,:)) && size(forwardTrace,1) ~= 1)
	% loop found - don't need to trace backward along the vortex line...
	backwardTrace = [];
	% debug - Highlight the loop.
	% plot3(forwardTrace(:,1), forwardTrace(:,2), forwardTrace(:,3), 'r.', 'linewidth', 1);
else
	backwardTrace = trace_direction(vorticity, startPos, faceIdxIdx(2));
end
lineIndices = [flipud(backwardTrace(2:end,:)); forwardTrace];

% Ensure that the handedness of the rotation as we traverse the vortex line is
% always the same by flipping any lines traced with negative handednesses.
if handedness < 0
    lineIndices = flipud(lineIndices);
end

end




function lineIndices = trace_direction(vorticity, startPos, faceIdx)
	% An array which maps outgoing face indices in one cell to the incoming face
	% index in the next cell.
	incomingFromOutgoing = [4,5,6, 1,2,3];

	% Increment which changes the cell coordinates.  If we know the index of the
	% outgoing face faceIdx, then inc(faceIdx, :) is the increment to add to the
	% current coordinate position to get the next one.
	inc = [-1, 0, 0; ...
			0,-1, 0; ...
			0, 0,-1; ...
			1, 0, 0; ...
			0, 1, 0; ...
			0, 0, 1];

	lineIndices = {};

	% Size of the vorticity field.
	fieldSize = size(vorticity);
	fieldSize = fieldSize(1:3);

	currPos = startPos;
	ii = 1;
	while true
		% store index for vortex.
		%lineIndices{ii} = currPos + 0.5*inc(faceIdx, :);
		lineIndices{ii} = currPos;
		if( all(currPos == startPos) && ii > 1 )
			break;
		end
		% Go to the next cell - we need to update...

		% (1) The position to the position of the next cell.
		currPos = currPos + inc(faceIdx, :);
		if(any(currPos < 1) || any(currPos > fieldSize))
			% stop if we end up outside the volume of interest
			break;
		end
		% (2) The face index to the position of the outgoing face for this cell
		currIncomingIdx = incomingFromOutgoing(faceIdx);
		% Get indices to all faces of the current cell holding nonzero values.
		faceVortIdx = find(vorticity(currPos(1),currPos(2),currPos(3),:) ~= 0);
		if(numel(faceVortIdx) ~= 2)
			warning('Vortex line ended unexpectedly!');
			break;
		end
		% Get the index of the outgoing face.
		faceIdx = faceVortIdx(faceVortIdx ~= currIncomingIdx);

		ii = ii + 1;
	end

	lineIndices = reshape(cell2mat(lineIndices), 3, length(lineIndices)).';
end
