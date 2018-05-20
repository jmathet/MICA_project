function [ res ] = AtrialFibrillation( R_locs )
%ATRIAL FIBRILLATION
res = 0;
%% bpm estimate
RR = []; %vecteur des intervalles R-R
for k=1:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-R_locs(k)); 
    RR = [RR RR_temp];
end
bpm_estimate = (1/length(R_locs))*sum(RR); 
%% statictical
N=length(RR);
stat_theo = [];
for k =1:(N-2)
    temp = 0;
    for n = 1:N-k
        temp = temp+(RR(n+k+1)-bpm_estimate)*(RR(n+1)-bpm_estimate);
    end
    stat_theo = (1/N-k-1)*temp;
end
%% auto-covariance function of the process RR
autocor = xcorr(RR);
%% comparison
if (autocor<stat_theo)
    res = 1;
end
end

