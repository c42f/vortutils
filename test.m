%load matt_vortex_data.mat

%disp('detecting vortices...');
%vorticity = vortex_detect3d(psiq);

disp('searching for vertices through central plane...');
startPos = vortex_search(vorticity, 0.2, 'z');

disp('plotting...');
volVorticity = face_field_to_vol_field(vorticity);
clf;
hold on;
for ii = 1:size(startPos, 1)
	% Trace the vortex line.
	vortTrace = vortex_trace(volVorticity, startPos(ii,:));

	% Plot the vortex line.
	%plot3(vortTrace(:,1), vortTrace(:,2), vortTrace(:,3), '.-');

	traceLen = size(vortTrace,1);
	if(traceLen > 1)
		% Construct a smooth spline representation of the vortex line, and plot
		% that.
		smoothTrace = csaps(1:traceLen, vortTrace.', 0.2, 1:traceLen).';
		plot3(smoothTrace(:,1), smoothTrace(:,2), smoothTrace(:,3), '-', 'linewidth', 1);
	end
end

axis([1,vorticity.siz(1), 1,vorticity.siz(2), 1,vorticity.siz(3)]);
set(gca(), 'projection','perspective');
set(gca(), 'box', 'on');
axis('equal');
