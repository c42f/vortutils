function vorticity = vortex_detect3d(psi)
% Detect superfluid vortices in a 3D complex field.  The natural discrete
% geometric elements for storing vorticity are the polygonal *faces* of the
% volume mesh.  Our mesh is a regular rectangular grid, so in this case the
% vorticity is detected on the rectangular 2D grid 
%
% Structure for regular meshes:
%
% struct FaceField
% {
%   % grid size.
%   int[3] siz
%   % field values for the x,y,z faces
%   double[Nx][Ny-1][Nz-1] xfVal
%   double[Nx-1][Ny][Nz-1] yfVal
%   double[Nx-1][Ny-1][Nz] zfVal
% }
%
% "vorticity" is a structure of type FaceField

[Nx, Ny, Nz] = size(psi);

xfVal = zeros(Nx,Ny-1,Nz-1);
yfVal = zeros(Nx-1,Ny,Nz-1);
zfVal = zeros(Nx-1,Ny-1,Nz);

phase = angle(psi);

for ii = 1:Nx
	xfVal(ii,:,:) = phase_winding2d(phase(ii,:,:));
end
for ii = 1:Ny
	yfVal(:,ii,:) = phase_winding2d(phase(:,ii,:));
end
for ii = 1:Nz
	zfVal(:,:,ii) = phase_winding2d(phase(:,:,ii));
end

vorticity = struct('siz', [Nx, Ny, Nz], 'xfVal', xfVal, 'yfVal', yfVal, 'zfVal', zfVal);

end


%-------------------------------------------------------------------------------
function vortices = phase_winding2d(phase)
% Detect phase winding about the grid plaquettes of a 2D phase profile.
%
% The resulting grid of detected vortices is of size  size(phase)-1.
%
	filter1 = [-1  1; 1 -1];
	filter2 = [ 1 -1;-1  1];

	phase = squeeze(phase);

	vortices = round( (conv2(unwrap(phase,[],1),filter1,'valid') + ...
					   conv2(unwrap(phase,[],2),filter2,'valid'))/(2*pi) );
end
