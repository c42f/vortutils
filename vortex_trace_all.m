function [vortLines] = vortex_trace_all(vorticity)
% Trace all vortices in a vorticity field
%
% TODO: We need a more intelligent way to avoid detecting the same vortex
% twice.  Currently it results in vortex lines which unexpectedly cut off in
% the middle of the field.
%
% Params:
%   vorticity - vorticity "face field" as returned from vortex_detect3d
%
% Output:
%   vortLines - a cell array containing all vortex lines found in the field.

volVorticity = face_field_to_vol_field(vorticity);

vortLines = {};
nLines = 1;

for kk = 1:(vorticity.siz(3)-1)
    startPos = vortex_search(vorticity, kk);

    for ii = 1:size(startPos, 1)
        % Since we delete the lines as we go to avoid detecting them twice, we need
        % to test that the ii'th start position is still valid.
        if any(volVorticity(startPos(ii,1), startPos(ii,2), startPos(ii,3), :) ~= 0)
            % Trace the vortex line.
            vortTrace = vortex_trace(volVorticity, startPos(ii,:));

            % Delete the vortex line from the field so that we don't find it twice.
            %
            % FIXME: If more than one vortex line passes through a given cell,
            %        this messes things up!
            for jj=1:6
                volVorticity(sub2ind(size(volVorticity), vortTrace(:,1), ...
                    vortTrace(:,2), vortTrace(:,3), ones(size(vortTrace(:,1)))*jj)) = 0;
            end

            vortLines{nLines} = vortTrace;
            nLines = nLines + 1;
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
