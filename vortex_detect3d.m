function vorticity = vortex_detect3d(psi,periodicBoundaries)
% vorticity = vortex_detect3d(psi)
%
% Detect superfluid vortices in a 3D complex field.  The natural discrete
% geometric elements for storing vorticity are the polygonal *faces* of the
% volume mesh.  Our mesh is a regular rectangular grid, so in this case the
% vorticity is detected on the rectangular 2D grid 
%
% psi                 -  3D wavefunction
% periodicBoundaries  -  switch to mark if we need to compute vorticity
%                        taking into account periodic boundary conditions
%                        or not
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
%   % flag for periodic boundaries
%   int periodicBoundaries
% }
%
% "vorticity" is a structure of type FaceField

if periodicBoundaries
    % first check if the field is already periodic
    % if not, add the periodic boundary manually
    if (psi(1,1,1) ~= psi(end,1,1)) || (psi(1,1,1) ~= psi(1,end,1)) || (psi(1,1,1) ~= psi(1,1,end))
        psi(end+1,:,:) = psi(1,:,:);
        psi(:,end+1,:) = psi(:,1,:);
        psi(:,:,end+1) = psi(:,:,1);
    end
end

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

vorticity = struct('siz', [Nx, Ny, Nz],...
                   'xfVal', xfVal, 'yfVal', yfVal, 'zfVal', zfVal,...
                   'periodicBoundaries',periodicBoundaries);

end
