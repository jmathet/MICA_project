function [ Q_locs, R_locs, S_locs ] = QRS_loc( data, Fs )
%QRS_LOC return the locations of the QRS waves

%%% Band-pass filter
ecg_1 = filter([1 0 0 0 0 0 -1], [1 -1], data); %low_pass filter
ecg_1 = filter([1 0 0 0 0 0 -1], [1 -1], ecg_1); %square
delay_bandpass = 5; % delai cree par le filtre passe bas
b1 = zeros(1,33);
b1(1,1) = -1;
b1(1,17) = 32;
b1(1,18) = -32;
b1(1,32) = 1;

ecg_2 = filter(b1, [1 -1], ecg_1); %high-pass filter
delay_bandpass = delay_bandpass + 16; % ajout du delai du filtre passe haut

%%% Derivative
 b2 = [1 2 0 -2 -1]*(1/8)*Fs;   
delay_PT = delay_bandpass; % delai introduit par la causalite forcee du filtre %modifier le commentaire
ecg_3 = filter(b2, 1, ecg_2); %derivative filter shifted
delay_PT = delay_PT + 2; % delai introduit par le filtre derivant

%%% Squared
ecg_4 = ecg_3.^2;

%%% Moving Window Integration
N = 0.15 * Fs -1; % double of the width of an average QRS complex = 0.15s = 0.15 * Fs points
% -1 pour avoir un delay entier lorsqu'on calcule le delai
Smwi = (1/N)*conv(ones(1,N),ecg_4);
Smwi = Smwi(1:length(data)); % troncature
delay_PT = delay_PT + (N-1)/2; % la fenetre introduit un delai de (N-1)/2

delay_vector_PT = zeros(1,delay_PT); %creation du vecteur delai
delay_vector_PT(1,delay_PT)=1; % mise en place d'un dirac a la position delay
data_delay_PT = conv(data,delay_vector_PT);% ajout du delai aux donnees (data)
data_delay_PT = data_delay_PT(1:length(data)); % troncature


%%% Thresholding
th = mean(Smwi); % seuil arbitraire => la moyenne
 for i=1:length(Smwi)
     if (Smwi(1,i) < th)  
         Smwi(1,i)=0;
     end
 end
 
 %%% Locations of R, Q and S directement sur les data
i=1;
R_locs_PT = [];
Q_locs_PT = [];
S_locs_PT = [];

while i<length(Smwi)
     if Smwi(i)~=0 % si on trouve un complexe
         complex_start = i;
         j=i;
         while (Smwi(j)~=0 && j<length(Smwi))% on va chercher la fin du complexe et on verifie de ne pas sortir de l'interval des donnes
             j=j+1;
         end
         complex_end=j;
         
         % Locations of R inside complex i:j (max search in data_delay_PT)
         [max_value max_pos]=max(data_delay_PT(complex_start:complex_end));
         R_locs_PT = [R_locs_PT max_pos+complex_start-1];
         
         % Locations of Q inside complex i:j (previous min search)
         if(complex_start+max_pos <= length(data)) % check if they are data to analyse (avoid exceeding indices at the end)
             [min_value min_pos]=min(data_delay_PT(complex_start:complex_start+max_pos));
              Q_locs_PT = [Q_locs_PT min_pos+complex_start-1];
         end    
         
         % Locations of S inside complex i:j (next min search)
         [min_value min_pos]=min(data_delay_PT(complex_start+max_pos:complex_end));
         S_locs_PT = [S_locs_PT min_pos+complex_start+max_pos-1];
         
         i=j; % on reprend la recherche apres le complexe
     else
        i=i+1;
     end
end

% R_locs_PT = R_locs_PT(1:(end-delay_PT)); % on tronque le dernier car le signal ne se termine pas sur un pic R (faux positif)
 
 %compensation du retard : positions correspondantes sur data
R_locs = R_locs_PT - delay_PT + 1;
Q_locs = Q_locs_PT - delay_PT + 1;
S_locs = S_locs_PT - delay_PT + 1;



end

