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
