function [psi, coords] = gen_vortex_line(vortBasePt, vortDirec, fieldDims)
% Generate a vortex line in a complex 3D field for testing purposes.
%
% [psi, coords] = gen_vortex_line(vortBasePt, vortDirec, fieldDims)
%
% params:
%   vortDirec - vortex line direction vector.
%   vortBasePt - a point on the vortex line.
%   fieldDims - 3D dimensions of the resulting grid representing the field.
%
% returns:
%   psi - a complex field containing a vortex line.
%   coords - struct containing coordinate vectors; coords.x, coords.y and coords.z.
%
% example
%   [psi, coords] = gen_vortex_line([0.4012, 0.5112, 0], [0.3, 0, 1], [10,10,10])

% normalize vortex direction.
vortDirec = vortDirec./norm(vortDirec);

coords = struct( 'x', linspace(0,1,fieldDims(1)), ...
                 'y', linspace(0,1,fieldDims(2)), ...
                 'z', linspace(0,1,fieldDims(3)) );

[xx,yy,zz] = ndgrid(coords.x, coords.y, coords.z);

% Generate a coordinate system perp. to vortex line: {e1, e2}.

e1 = cross(vortDirec, [0.569878121982, 0.341982398923, 0.9234098234]);
e1 = e1./norm(e1);
e2 = cross(vortDirec, e1);

% get 2D coordinates of the grid in this coordinate system...
v1 = (xx-vortBasePt(1))*e1(1) + (yy-vortBasePt(2))*e1(2) + (zz-vortBasePt(3))*e1(3);
v2 = (xx-vortBasePt(1))*e2(1) + (yy-vortBasePt(2))*e2(2) + (zz-vortBasePt(3))*e2(3);

r = sqrt(v1.*v1 + v2.*v2);
r(r == 0) = 1;

psi = complex(v1./r, v2./r);

end
