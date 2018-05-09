function [segment, P_loc, Q_loc, R_loc, S_loc, T_loc ] = ecg_threshold( data, R_locs, i_seg)
% This function cumputes and returns the location of the P, Q, R, S and 
% T point for the specified segment number and R values of the entire signal.

inter_pks = round((R_locs(2) - R_locs(1))/2);
if i_seg > 1
    start_pks = R_locs(i_seg-1) + inter_pks;
else
    start_pks = 1 + inter_pks;
end
end_pks = R_locs(i_seg+1) - inter_pks;

segment = data(start_pks:end_pks);
R_loc = R_locs(i_seg)-start_pks+1;
[~, Q_loc] = min(segment(1:R_loc));
[~, P_loc] = max(segment(1:Q_loc));
[~, S_loc] = min(segment(R_loc+1:end));
S_loc = S_loc + R_loc;
[~, T_loc] = max(segment(S_loc+1:end));
T_loc = T_loc + S_loc;
end

