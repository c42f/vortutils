load matt_vortex_data.mat

disp('detecting vortices...');
vorticity = vortex_detect3d(psiq);

volVorticity = face_field_to_vol_field(vorticity);

clf;
hold on;

% Ratio of the z-height of the simulation box to the other two directions.
aspectRatio = 0.57;

disp('tracing vortices...');
for kk = 1:(vorticity.siz(3)-1)

	%disp(sprintf('searching for vertices through z-plane number %d', kk));
	startPos = vortex_search(vorticity, kk);

	for ii = 1:size(startPos, 1)
		% Since we delete the lines as we go to avoid detecting them twice, we need
		% to test that the ii'th start position is still valid.
		if(any(volVorticity(startPos(ii,1), startPos(ii,2), startPos(ii,3), :) ~= 0))
			% Trace the vortex line.
			vortTrace = vortex_trace(volVorticity, startPos(ii,:));

			% Delete the vortex line from the field so that we don't find it twice.
			for jj=1:6
				volVorticity(sub2ind(size(volVorticity), vortTrace(:,1), ...
					vortTrace(:,2), vortTrace(:,3), ones(size(vortTrace(:,1)))*jj)) = 0;
			end

			% Plot the vortex line.  facePos is the actual positions of the vortices
			% on the faces of the 3D mesh; half way between the cell centres.
			facePos = 0.5*(vortTrace(1:end-1,:) + vortTrace(2:end,:));
			facePos(:,3) = facePos(:,3)*aspectRatio;
			if(abs(diff(vortTrace([1,end],3))) == vorticity.siz(3)-2)
				% emphasize any which go all the way through the middle of the cloud.
				plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'k.-');
			elseif(all(vortTrace(1,:) == vortTrace(end,:)))
				plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'r-');
			else
				plot3(facePos(:,1), facePos(:,2), facePos(:,3), '-');
			end

			% Construct a smooth spline representation of the vortex line, and plot
			% that.
			% smoothed = smooth_vort_line(vortTrace);
			% plot3(smoothed(:,1), smoothed(:,2), smoothed(:,3), '-', 'linewidth', 1);
		end
	end

end

axis([1,vorticity.siz(1), 1,vorticity.siz(2), 1,vorticity.siz(3)*aspectRatio]);
set(gca(), 'projection','perspective');
set(gca(), 'box', 'on');
axis('equal');
