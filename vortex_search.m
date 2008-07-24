function vortInd = vortex_search(vorticity, depth, planeNormalName)

if planeNormalName == 'x'

elseif(planeNormalName == 'y')

elseif(planeNormalName == 'z')
	depthIdx = min(max(1, floor(vorticity.siz(3)*depth+1) ), vorticity.siz(3));
	vIdx = find(vorticity.zfVal(:,:,depthIdx) ~= 0);
	[x,y] = ind2sub(vorticity.siz(1:2)-1, vIdx);
	vortInd = [x,y,depthIdx*ones(size(x))];
end

end
