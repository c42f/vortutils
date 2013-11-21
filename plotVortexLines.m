function plotVortexLines(vortLines)
% Plot the vortex lines
%
% vortLines - a matlab cell vector contaning the path of a series of
%             vortices
% vorticity - the vorticity field containing the vorticity field, the
%             periodic boundary flag and the field size

clf; % Clear current figure window
hold on;

view(54,26);
daspect([1,1,1]);

for ii = 1:length(vortLines) % for each detected vortex - ii is the vortex number
    vline = vortLines{ii}; % this carries the indeces of the vortex trajectory
    
    % facePos is the actual positions of the vortices
    % on the faces of the 3D mesh; half way between the cell centres.
    
    if(all(vline(1,:) == vline(end,:)))
        % Visualize vortex LOOPS.
        
        % If the pos of vortex skip of more than one it means the vortex
        % has crossed the boundaries.
        steps = find(sum(diff(vline).^2,2) > 1);
        
        if isempty(steps)
            % visualise vortex loops in blue
            facePos = 0.5*(vline(1:end-1,:) + vline(2:end,:));
            
            % Make sure to append a copy of the first facePos to the end
            % so that the loop is drawn as a loop
            facePos(end+1,:) = facePos(1,:);
            
            plot3(facePos(:,1), facePos(:,2), facePos(:,3), '-');
        else
            % visualise vortex loops crossing boundaries in green
            
            startIndex = 1;
            for kk=1:length(steps)
                 facePos = 0.5*(vline(startIndex:steps(kk)-1,:) + vline(startIndex+1:steps(kk),:));
                 plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'g-');
                 startIndex = steps(kk) + 1;
            end
            facePos = 0.5*(vline(startIndex:end-1,:) + vline(startIndex+1:end,:));
            plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'g-');
        end
    else
        % Visualise vortex LINES in red
        facePos = 0.5*(vline(1:end-1,:) + vline(2:end,:));
        plot3(facePos(:,1), facePos(:,2), facePos(:,3), 'r-');
    end
end