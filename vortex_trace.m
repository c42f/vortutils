function vortexLines = vortex_trace(vorticity, coords)
% trace vortex lines in the given vorticity field.

% search for a vortex line.
searchZ = 1;
vIdx = find(vorticity.zfVal(:,:,searchZ) ~= 0);

if(numel(vIdx) == 0)
	vortexLines = {};
	return;
end

% re-store vorticity in volume elements for ease of access.
vVol = face_field_to_vol_field(vorticity);

% Sizes of the volume element grid.
Nx = size(vVol,1);
Ny = size(vVol,2);
Nz = size(vVol,3);

% An array which maps outgoing face indices in one cell to the incoming face
% index in the next cell.
incomingFromOutgoing = [4,5,6, 1,2,3];
% Increments which change the cell coordinates
incX = [-1,0,0, 1,0,0];
incY = [0,-1,0, 0,1,0];
incZ = [0,0,-1, 0,0,1];

hold on;
for lineNum=1:length(vIdx)
	[x,y] = ind2sub(vorticity.siz(1:2)-1, vIdx(lineNum));
	z = searchZ;
	faceIdx = 6;

	vLineIndices = {};
	ii = 1;
	while true
		% Get incoming face index from outgoing index of previous iteration.
		faceIdx = incomingFromOutgoing(faceIdx);
		% store index for vortex.
		%vLineIndices{ii} = [x + 0.5*incX(faceIdx), y + 0.5*incY(faceIdx), z + 0.5*incZ(faceIdx)];
		vLineIndices{ii} = [x,y,z];
		% Get indices to all faces of the current cell holding nonzero values.
		faceVortIdx = find(vVol(x,y,z,:) ~= 0);
		if(numel(faceVortIdx) < 2)
			break;
		end
		% Get the index of the outgoing face.
		faceIdx = faceVortIdx(faceVortIdx ~= faceIdx);
		
		% Set the outgoing face value to zero, in order to terminate vortex
		% loop detection.
		vVol(x,y,z,faceIdx) = 0;

		% Get the next cell index
		x = x + incX(faceIdx);
		y = y + incY(faceIdx);
		z = z + incZ(faceIdx);
		if(x < 1 || y < 1 || z < 1  ||  x > Nx || y > Ny || z > Nz)
			break;
		end
		ii = ii + 1;
	end

	vortexLines{lineNum} = reshape(cell2mat(vLineIndices), 3, length(vLineIndices));
end


