function chunks = breakVortex(vortLine)
% Breaks a vortex line into pieces that don't cross the boundaries with
% periodic condition
%
% vortLine - the array with the (x,y,z) coordinates of the vortex path

steps = find(sum(diff(vortLine).^2,2) > 1);

chunks = cell(length(steps)+1,1);

chunkIndex = 1;
startIndex = 1;
for kk=1:length(steps)
    chunks{chunkIndex} = vortLine(startIndex:steps(kk),:);
    startIndex = steps(kk) + 1;
    chunkIndex = chunkIndex + 1;
end
chunks{chunkIndex} = vortLine(startIndex:end,:);

return