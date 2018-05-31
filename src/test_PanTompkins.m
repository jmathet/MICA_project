%% Main script to test ecg function without gui
% This file computes a simple analysis of an ecg signal. You can use it to test the different processing methods. 
% This first version will plot the temporal signal, compute its cardiac rythma and display the different P, Q, R, S, T points for a specific segment.  

clear; close all; clc;
addpath(genpath('.'));

%% Load a signal
[file,path] = uigetfile('../data/ecg_normal_1.mat', 'rt');
signal = load(fullfile(path, file));
data = signal.ecg; % Your ecg data
Fs = signal.Fs; % Sampling frequency
N = size(data,2); % Data length
time_axis = (1:N)/Fs;
%% Threshold method
% th = 200; % threshold
% i_seg = 10; % Segment number to plot
% 
% % Time plot
% figure;
% plot(time_axis, data); grid on;
% hold on; plot(time_axis, th*ones(1,N), 'red');
% xlabel('Time (s)');
% ylabel('Magnitude');
% title('Time evolution of the loaded signal')
% 
% % Print BPM
% [bpm, R_locs] = bpm_threshold(data, th, Fs);
% % Figures PQRST
% [segment, P_loc, Q_loc, R_loc, S_loc, T_loc] = ecg_threshold(data, R_locs, i_seg);
% time_segment = (1:length(segment))/Fs;
% 
% figure;
% h = plot(time_segment, segment); grid on;
% hold on;
% %plot(time_segment(P_loc),segment(P_loc), '*','Color','red'); text(time_segment(P_loc),segment(P_loc),' P ','Color','red','FontSize',14);
% %plot(time_segment(Q_loc),segment(Q_loc), '*','Color','red'); text(time_segment(Q_loc),segment(Q_loc),' Q ','Color','red','FontSize',14);
% %plot(time_segment(R_loc),segment(R_loc), '*','Color','red'); text(time_segment(R_loc),segment(R_loc),' R ','Color','red','FontSize',14);
% %plot(time_segment(S_loc),segment(S_loc), '*','Color','red'); text(time_segment(S_loc),segment(S_loc),' S ','Color','red','FontSize',14);
% plot(time_segment(T_loc),segment(T_loc), '*','Color','red'); text(time_segment(T_loc),segment(T_loc),' T ','Color','red','FontSize',14);
% hold off;
% xlabel('Time (s)');
% ylabel('Magnitude');
% title('ECG segment characteristic')

%% Your turn : My new method ! 
figure;
plot(time_axis, data); 
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
figure;
plot(Smwi);
title('Smwi');
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
 
 % comparaison  du signal ecg brut(data) et apres traitement
figure;
hold on; plot(time_axis, data_delay_PT()/max(data_delay_PT)); 
plot(time_axis, Smwi/max(Smwi)); 
hold off;
title('Comparaison between ECG inital normalized (data normalized) and signal after thresholding normalized (ecg th normalized)');
legend('data normalized','ecg th normalized');

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
         [min_value min_pos]=min(data_delay_PT(complex_start:complex_start+max_pos));
         Q_locs_PT = [Q_locs_PT min_pos+complex_start-1];
         
         
         % Locations of S inside complex i:j (next min search)
         [min_value min_pos]=min(data_delay_PT(complex_start+max_pos:complex_end));
         S_locs_PT = [S_locs_PT min_pos+complex_start+max_pos-1];
         
         i=j; % on reprend la recherche apres le complexe
     else
        i=i+1;
     end
end

R_locs_PT = R_locs_PT(1:(end-delay_PT)); % on tronque le dernier car le signal ne se termine pas sur un pic R (faux positif)
 
 %compensation du retard : positions correspondantes sur data
R_locs = R_locs_PT - delay_PT + 1;
Q_locs = Q_locs_PT - delay_PT + 1;
S_locs = S_locs_PT - delay_PT + 1;




 %%% Locations of T and P
delay_T_P = 0; % reference data
ecg_5 = filter([1 0 0 0 0 0 -1], [1], data);
delay_T_P = delay_T_P + 3;
ecg_6 = filter([1 0 0 0 0 0 0 0 -1], [1 -1], ecg_5);
delay_T_P = delay_T_P + 4;

delay_vector_T_P = zeros(1,delay_T_P); % creation du vecteur delai
delay_vector_T_P(1,delay_T_P)=1; % mise en place d'un dirac a la position delay_T_P
data_delay_T_P = conv(data,delay_vector_T_P);% ajout du delai aux donnees brut (data)
data_delay_T_P = data_delay_T_P(1:length(data)); % troncature pour retirer les derniers points ajoutes 

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

% % plot final de l'ecg avec les points trouves
 figure;
 time_segment = (1:length(data))/Fs;
  h = plot(time_segment, data); grid on;
  hold on;
  plot(time_segment(P_locs),data(P_locs), '*','Color','red');
    text(time_segment(P_locs),data(P_locs),' P ','Color','red','FontSize',14);
  plot(time_segment(R_locs),data(R_locs), '*','Color','magenta'); 
    text(time_segment(R_locs),data(R_locs),' R ','Color','magenta','FontSize',14);
  plot(time_segment(Q_locs),data(Q_locs), '*','Color','blue');
    text(time_segment(Q_locs),data(Q_locs),' Q ','Color','blue','FontSize',14);  
  plot(time_segment(S_locs),data(S_locs), '*','Color','green');
    text(time_segment(S_locs),data(S_locs),' S ','Color','green','FontSize',14);  
  plot(time_segment(T_locs),data(T_locs), '*','Color','black');
    text(time_segment(T_locs),data(T_locs),' T ','Color','black','FontSize',14);  
  hold off;
  xlabel('Time (s)');
  ylabel('Magnitude');
  title('ECG segment with PQRST waves (source : ecg normal 1.m)');
  xlim([560 563]);
  
%tachycardia(R_locs, 20)
  
%ectopicbeat(R_locs)

%AtrialFibrillation(R_locs);
%% bpm estimate
RR = [];
for k=1:(length(R_locs)-1)
    RR_temp = abs(R_locs(k+1)-R_locs(k)); 
    RR = [RR RR_temp];
end
bpm_estimate = (1/length(R_locs))*sum(RR);
%% statictical
N=length(R_locs);
stat_theo = [];
for k =1:(N-1)
    temp = 0;
    for n = 1:N-k-1
        temp = temp+(RR(n+k)-bpm_estimate)*(RR(n)-bpm_estimate);
    end
    stat_theo = [stat_theo (1/N-k-1)*temp];
end
%% auto-covariance function of the process RR
autocor = xcorr(RR);
autocor = autocor(length(stat_theo):length(autocor));
%% comparison
if (autocor<stat_theo)
    res = 1;
end
%close all; hold on; plot(autocor); plot(stat_theo); hold off;

