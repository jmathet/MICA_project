function [ output_args ] = bradycardia( R_locs )
%BRADYCARDIA detecte une bradycardie a partir des positions des points R
%% estimation du bpm
RR = []; %vecteurs des intervalles R-R
for k=1:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-R_locs(k)); 
    RR = [RR RR_temp];
end
bpm_estimate = (1/length(R_locs))*sum(RR);
%% diagnostic
res = 0; %resultat negatif
if (bpm_estimate<60)
    res = 1; % resultat positif
end
end

