function [vortLines, unexpectedEnds] = vortex_trace_all(vorticity, lengthFilter)
% Trace all vortices in a vorticity field
%
% Params:
%   vorticity - vorticity "face field" as returned from vortex_detect3d
%   lengthFilter - only save vortices that extends over a number of cells
%                  larger than lengthFilter (lengthFilter = 0 means no
%                  filter is applied)
%
% Output:
%   vortLines - a cell array containing all vortex lines found in the field.
%   unexpectedEnds - flags the vortex lines that unded unexpectedly so that
%                    they can be removed from the count later. A value of 1
%                    for unexpectedEnd marks a vortex that ended suddenly
%                    in the bulk of the field

volVorticity = face_field_to_vol_field(vorticity);
periodicBoundaries = vorticity.periodicBoundaries;

vortLines = {};
nLines = 1;

for kk = 1:(vorticity.siz(3)-1)
    startPos = vortex_search(vorticity, kk);
    
    for ii = 1:size(startPos, 1)
        % Since we delete the lines as we go to avoid detecting them twice, we need
        % to test that the ii'th start position is still valid.
        if any(volVorticity(startPos(ii,1), startPos(ii,2), startPos(ii,3), :) ~= 0)
            % Trace the vortex line.
            [vortTrace, unexpectedEnd, volVorticity] = vortex_trace(startPos(ii,:), volVorticity, periodicBoundaries);
            vortTrace = vortTrace(:,1:3);
            
            if ( ( lengthFilter == 0 ) || ( size(vortTrace,1) > lengthFilter ) )
                vortLines{nLines} = vortTrace;
                unexpectedEnds(nLines) = unexpectedEnd;
                nLines = nLines + 1;
            end
        end
    end
end

end

function vortInd = vortex_search(vorticity, planeIndex)
% vortInd = vortex_search(vorticity, planeIndex)
%
% Search for vortices in one xy plane of a vorticity field.
%
% Input:
%   vorticity - "face-field" describing vorticities of a 3D mesh
%   planeIndex - z-index of the plane on which to detect the vorticity.
%
% Output:
%   vortIdx - [x,y,z] indices for N found vortices, dimension Nx3

vIdx = find(vorticity.zfVal(:,:,planeIndex) ~= 0);
[x,y] = ind2sub(vorticity.siz(1:2)-1, vIdx);
vortInd = [x,y,planeIndex*ones(size(x))];

end