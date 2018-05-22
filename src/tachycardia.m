function [ res ] = tachycardia( R_locs, patient_category, bpm_estimate )
%TACHYCARDIA ventricular en fonction de l'age du patient
% patient_category = {1 (adulte), 2 (enfant), 3 (bébé)}
% result +-1(warning), +-2(danger) -> positif = tachy, negatif =
% brady

%% diagnostic
res = 0; % RAS
% Normal hearth rates are given in parenthesis, "ok" interval is centered
% in the interval with a width of 20

if (patient_category == 1) % ADULT (60-120)
    if(bpm_estimate < 60) 
        res=-2; % dangerous brady
    elseif(bpm_estimate >= 60 && bpm_estimate < 80)
        res=-1; % warning brady
    elseif(bpm_estimate >= 100 && bpm_estimate < 120)
        res=1; % warning tachy
    elseif(bpm_estimate >= 120)
        res=2; % dangerous tachy
    end
elseif(patient_category == 2) % CHILD (62-151)
    if(bpm_estimate < 62) 
        res=-2; % dangerous brady
    elseif(bpm_estimate >= 62 && bpm_estimate < 96)
        res=-1; % warning brady
    elseif(bpm_estimate >= 116 && bpm_estimate < 151)
        res=1; % warning tachy
    elseif(bpm_estimate >= 151)
        res=2; % dangerous tachy
    end
else % BABY (106-186)
    if(bpm_estimate < 106) 
        res=-2; % dangerous brady
    elseif(bpm_estimate >= 106 && bpm_estimate < 136)
        res=-1; % warning brady
    elseif(bpm_estimate >= 156 && bpm_estimate < 186)
        res=1; % warning tachy
    elseif(bpm_estimate >= 186)
        res=2; % dangerous tachy
    end
end

