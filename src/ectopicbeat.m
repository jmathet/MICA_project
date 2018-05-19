function [ mean_RR, PVC_count ] = ectopicbeat( R_locs )
%ECTOPIC BEAT = Premature Ventricular Contraction
th_PVC = 7; % seuil arbitraire pour la détection des PVC
PVC_count = 0; %compteur du nombre de PVC detecte
RR = []; %vecteurs des intervalles R-R
for k=2:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-2*R_locs(k)+R_locs(k-1)); 
    RR = [RR RR_temp];
    if(RR_temp>th_PVC)
        PVC_count = PVC_count + 1;
    end
end
 mean_RR = mean(RR);
end

