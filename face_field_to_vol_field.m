function volField = face_field_to_vol_field(faceField)
% This function takes a field which is defined on the square faces of a regular
% grid in "FaceField" structure format, and turns it into a single matlab
% array, defined on the cubic volume elements of the grid.
%
% The resulting representation is redundent, since every cubic volume element
% stores the values at all six faces which adjoin it along the last
% dimension.  However, it is much easier and probably more efficient to
% index in this format.
%
% In particular, indexing with (i,j,k) into volField pulls out a 6-vector
% with each element of the vector corresponding to one of the adjoining faces
% of the (i,j,k)'th cubic cell.  The order of the faces is:
%
% [-x,-y,-z,+x,+y,+z]

volField = zeros([faceField.siz-1, 6]);

% -x,-y,-z
volField(:,:,:,1) = faceField.xfVal(1:end-1,:,:);
volField(:,:,:,2) = faceField.yfVal(:,1:end-1,:);
volField(:,:,:,3) = faceField.zfVal(:,:,1:end-1);

% +x,+y,+z
volField(:,:,:,4) = faceField.xfVal(2:end,:,:);
volField(:,:,:,5) = faceField.yfVal(:,2:end,:);
volField(:,:,:,6) = faceField.zfVal(:,:,2:end);

end
