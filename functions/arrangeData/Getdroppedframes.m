function droppedframes = Getdroppedframes(varlist,thisses,thistime,ifi)
nframes = numel(thistime);
predTime = transpose(0:ifi:(nframes-1)*ifi);
clockDiff = thistime-predTime;
jumps = abs(diff(clockDiff));
peaks = find(jumps>=ifi);
% check if the clockDiff is going back to a stable value
droppedframes = [];
if ~isempty(peaks)
    for i = 1:numel(peaks)
        if peaks(i)+2>numel(clockDiff) || peaks(i)+10 > numel(clockDiff)
            base = clockDiff(peaks(i)) - clockDiff(peaks(i)+1);
        else
            base = clockDiff(peaks(i)) - mean(clockDiff(peaks(i)+2:peaks(i)+10)); % why not the diff between the frame and the following frame?
        end

        isover(i) = abs(base)>ifi;
    end
    droppedframes_ind = peaks(isover);

    if ~isempty(droppedframes_ind)
        figure
        plot(clockDiff)
        hold on
        plot(droppedframes_ind,clockDiff(droppedframes_ind),'or')
        hold on
        yline(0:ifi:clockDiff(end),'b')
        title([varlist.animalnames{thisses},' ', varlist.taskname{thisses}])
        hold off
        droppedframes.ind = droppedframes_ind;
        % add artificial timestamps
        droppedframes.timestamps = [];
        for i = 1:numel(droppedframes.ind)
            droppedframes.n(i) = round(jumps(droppedframes.ind(i))/ifi);
            t = thistime(droppedframes.ind(i)); % timestamp after frames dropped
            e = thistime(droppedframes.ind(i)+1); % timestamp before frames dropped
            addedtimestamps = transpose(t+ifi:ifi:t+droppedframes.n(i)*ifi);
            droppedframes.timestamps = [droppedframes.timestamps;addedtimestamps];
        end
    end
end
end