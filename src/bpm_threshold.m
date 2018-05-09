function [bpm, R_locs] = bpm_threshold(data, th, Fs)
% This function computes the cardiac activity in BPM by using the 
% mean R-R distance obtained by the treshold method. It also returns the
% location of all the R points of the entire signal.
% SEE ALSO : ecg_threshold

[pks, loc] = findpeaks(data);
pks(pks < th) = 0;
loc_th = find(pks);
R_locs = loc(loc_th);

mean_rr = (R_locs(end)-R_locs(1))/(length(loc_th)-1);
bps = mean_rr/Fs; % interval in seconds
bpm = round(60/bps); % in minutes
end

