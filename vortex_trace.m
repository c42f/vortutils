function [lineIndices, unexpectedEnd, volVorticity] = vortex_trace(startPos, volVorticity, periodicBoundaries)
% lineIndices = vortex_trace(vorticity, startPos);
%
% Trace a vortex line in the given vorticity field.  Each cubic cell in the
% vorticity field is represented by a six-element array, containing the
% vorticity on the faces of the cell.
%
% Input:
%   vorticity - An array containing the vorticity stored in cell volumes
%   startPos - Starting index into the vorticity array.
%
% Output:
%   lineIndices - Indices of cells through which the line passes.
%   unexpectedEnd - flag indictaoing wheter the vortex ended unexpectedly
%                   or not

% Find direction to move in.
startCellVorticity = volVorticity(startPos(1),startPos(2),startPos(3),:);
faceIdxIdx = find(startCellVorticity ~= 0);

if(numel(faceIdxIdx) == 0)
    lineIndices = [];
    return;
end

handedness = startCellVorticity(faceIdxIdx(1));

backwardUnexpectedEnd = 0;

% forwardTrace(:,1:3) and backwardTrace(:,1:3) are 3D lists of coordinates
% of the cells traversed by the vortex.
% forwardTrace(:,4) and backwardTrace(:,4) are the indices of the faces of
% the cells where the vortex enter.
% forwardTrace(:,5) and backwardTrace(:,5) are the indices of the faces of
% the cells where the vortex exit.

[forwardTrace, forwardUnexpectedEnd, volVorticity] = trace_direction(startPos, faceIdxIdx(1), volVorticity, periodicBoundaries);

if(all(forwardTrace(1,1:3) == forwardTrace(end,1:3)) && size(forwardTrace,1) ~= 1 && forwardTrace(end,end) == forwardTrace(1,end))
    % loop found - don't need to trace backward along the vortex line...
    backwardTrace = [];
    forwardTrace(1,:) = forwardTrace(end,:);
else
    [backwardTrace, backwardUnexpectedEnd,volVorticity] = trace_direction(startPos, faceIdxIdx(2), volVorticity, periodicBoundaries);
    % here we patch the entry and exit indices of the faces for the head of the
    % forward traced and backward traced vortices
    forwardTrace(1,4) = forwardTrace(1,5);
    forwardTrace(1,5) = backwardTrace(1,5);
end

% create a unique vortex line by attaching the forward traced part of the
% vortex to the backward traced one
lineIndices = [flipud(backwardTrace(2:end,:)); forwardTrace];

unexpectedEnd = forwardUnexpectedEnd | backwardUnexpectedEnd;

% Ensure that the handedness of the rotation as we traverse the vortex line is
% always the same by flipping any lines traced with negative handednesses.
if handedness < 0
    lineIndices = flipud(lineIndices);
end

end


function [lineIndices, unexpectedEnd, volVorticity] = trace_direction(startPos, faceIdx, volVorticity, periodicBoundaries)
% Flag to mark all the vortices that don't end on the edges of the grid
unexpectedEnd = 0;

% An array which maps outgoing face indices in one cell to the incoming face
% index in the next cell.
incomingFromOutgoing = [4,5,6, 1,2,3];

% Handedness array. This array is used to ensure that handness of the
% incoming vortex and outgoing vortex are matched.
% This is computed by assuming to have an incoming vortex on the face with
% index 1 with positive handedness. The index then represent the expected
% handedness for a matching vortex in any of the other faces.
expectedHandedness = [ 1 , 1 , -1 , 1 , -1 , 1 ];

% Increment which changes the cell coordinates.  If we know the index of the
% outgoing face faceIdx, then inc(faceIdx, :) is the increment to add to the
% current coordinate position to get the next one.
inc = [-1, 0, 0; ...
    0,-1, 0; ...
    0, 0,-1; ...
    1, 0, 0; ...
    0, 1, 0; ...
    0, 0, 1];

% Size of the vorticity field.
fieldSize = size(volVorticity);
fieldSize = fieldSize(1:3);

% initialize the lineIndices array with an array of zeros twice as
% long the grid (safe assumption)
lineIndicesInitialSize = max(fieldSize);
lineIndices = zeros(lineIndicesInitialSize,5);

% We start tracing the vortex line from the faceIdx passed in which is the
% index of the face with the outgoing vortex from this cell
currIncomingIdx = 0;

currPos = startPos;
ll = 1;
while true
    
    % we have preallocated the empty array with the size of the
    % system for speed. If we found a vortex that is longer than
    % the size of the system we need to extend the array. In
    % practice this will rarely happen so we still get a
    % performance boost
    if ll > lineIndicesInitialSize
        lineIndices = [lineIndices; zeros(lineIndicesInitialSize,5)];
    end
    
    % store index for vortex together with the index of the face where the
    % vortex entered the current cell (currIncomingIdx) and the index of
    % the face where the vortex exits the cell (faceIdx)
    lineIndices(ll,:) = [currPos currIncomingIdx faceIdx];
    
    % if the currPos is equal to the startPos we encountered a loop and we
    % can exit
    if ( all(currPos == startPos) && ll > 1 )
        break;
    end
    
    % Go to the next cell - we need to update...
    
    % (1) The position to the position of the next cell.
    currPos = currPos + inc(faceIdx, :);
    
    if any(currPos < 1)
        if periodicBoundaries
            currPos(currPos == 0) = fieldSize(currPos == 0);
        else
            % stop if we end up outside the volume of interest
            break;
        end
    end
    if any(currPos > fieldSize)
        if periodicBoundaries
            currPos((currPos > fieldSize) ~= 0) = 1;
        else
            % stop if we end up outside the volume of interest
            break;
        end
    end
    
    % (2) The face index to the position of the outgoing face for this cell
    currIncomingIdx = incomingFromOutgoing(faceIdx);
    
    % compute the handedness matching array for the current incoming
    % face index and handedness
    matchingHandedness = volVorticity(currPos(1),currPos(2),currPos(3),currIncomingIdx)*circshift(expectedHandedness,[0 currIncomingIdx-1]);
    % find the faces that have the right handedness by multiplying the
    % expected handedness with the handedness of the cell. Any face with
    % the right handedness will have a value of one after this
    matchingHandedness = squeeze(volVorticity(currPos(1),currPos(2),currPos(3),:))' .* matchingHandedness;
    
    % Get indices to all faces of the current cell holding nonzero values.
    faceVortIdx = find(matchingHandedness == 1);
    % old style
    %faceVortIdx = find(vorticity(currPos(1),currPos(2),currPos(3),:) ~= 0);
    
    % every cell should have at least a vortex line getting in and one
    % going out
    if (numel(faceVortIdx) < 2)
        warning('Vortex line ended unexpectedly!');
        unexpectedEnd = 1;
        break;
    end
    
    % Get the index of the outgoing face.
    faceIdx = faceVortIdx(faceVortIdx ~= currIncomingIdx);
    faceIdx = faceIdx(1);
    
    % we erase the vortex line from the faces as we go through
    volVorticity(currPos(1),currPos(2),currPos(3),currIncomingIdx) = 0;
    volVorticity(currPos(1),currPos(2),currPos(3),faceIdx) = 0;
    
    ll = ll + 1;
end

% get rid of the empty entries we preallocated
lineIndices(ll+1:end,:) = [];

end