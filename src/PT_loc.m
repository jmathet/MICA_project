function [ P_locs, T_locs ] = PT_looc( data, R_locs )
%PT_LOOC find the locattions of the P and T waves

delay_T_P = 0; % reference data
ecg_5 = filter([1 0 0 0 0 0 -1], [1], data);
delay_T_P = delay_T_P + 3;
ecg_6 = filter([1 0 0 0 0 0 0 0 -1], [1 -1], ecg_5);
delay_T_P = delay_T_P + 4;

delay_vector_T_P = zeros(1,delay_T_P); % creation du vecteur delai
delay_vector_T_P(1,delay_T_P)=1; % mise en place d'un dirac a la position delay_T_P
data_delay_T_P = conv(data,delay_vector_T_P);% ajout du delai aux donnees brut (data)
data_delay_T_P = data_delay_T_P(1:length(data)); % troncature pour retirer les derniers points ajoutes 

%% T waves location
T_locs_new = [];
for i=1:length(R_locs)-1
   temp_loc = [];
   % Etude de l'intervalle R(i)->R(i+1) 
   RR_start = R_locs(i) + round((R_locs(i+1)-R_locs(i))*0.2)+ delay_T_P; 
   RR_end = R_locs(i) + round((R_locs(i+1)-R_locs(i))*0.7) + delay_T_P;
   for j=RR_start:RR_end
       if (ecg_6(j)*ecg_6(j+1)<0)
            temp_loc = [temp_loc j];
       end
   end
   [max_value, max_pos] = max(data_delay_T_P(temp_loc));
   T_locs_new = [T_locs_new temp_loc(max_pos)];
end

T_locs  = T_locs_new - delay_T_P +1;

%% P waves location
P_locs_new = [];
for i=1:length(R_locs)-1
   temp_loc = [];
   % Etude de l'intervalle R(i)->R(i+1) 
   RR_start = R_locs(i) - round((R_locs(i+1)-R_locs(i))*0.25) + delay_T_P; %reduction de l'interval
   % de recherche de 30% a 25% car peu de change de trouver P dans les 5%
   % (reduit les erreurs
   RR_end = R_locs(i) - round((R_locs(i+1)-R_locs(i))*0.1) + delay_T_P;
   for j=RR_start:RR_end
       if (ecg_6(j)*ecg_6(j+1)<0)
            temp_loc = [temp_loc j];
       end
   end
   [max_value, max_pos] = max(data_delay_T_P(temp_loc));
   P_locs_new = [P_locs_new temp_loc(max_pos)];
end

P_locs  = P_locs_new - delay_T_P +1;
end

