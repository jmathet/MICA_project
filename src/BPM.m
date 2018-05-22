function [ bpm_estimate ] = BPM( R_locs )
% BPM estimation based on avg R-R locs
% Warning displayed in the interface depending on the window for coherence

RR = []; %vecteurs des intervalles R-R
%% estimation du bpm
for k=1:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-R_locs(k)); 
    RR = [RR RR_temp];
end
bpm_estimate = (1/length(R_locs))*sum(RR); %moyenne empirique sur les R-R

end

