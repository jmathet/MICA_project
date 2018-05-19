function [ res ] = tachycardia( R_locs, age )
%TACHYCARDIA ventricular 
RR = []; %vecteurs des intervalles R-R
%% estimation du bpm
for k=1:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-R_locs(k)); 
    RR = [RR RR_temp];
end
bpm_estimate = (1/length(R_locs))*sum(RR);

%% diagnostic
res = 0; %resultat negatif
if(age == 1 && bpm_estimate>160)
    res = 1; %resultat positif
elseif(age == 2 && bpm_estimate>130)
    res = 1;
elseif(age>2 && age<7 && bpm_estimate>120)
    res = 1;
elseif(age>=7 && age<=12 && bpm_estimate>110)
    res = 1;
elseif(age>12 && age<65 && bpm_estimate>100)
    res = 1;
elseif(age>=65 && bpm_estimate>95)
    res = 1;
end

end

