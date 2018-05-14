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
th = 200; % threshold
i_seg = 10; % Segment number to plot

% Time plot
figure;
plot(time_axis, data); grid on;
hold on; plot(time_axis, th*ones(1,N), 'red');
xlabel('Time (s)');
ylabel('Magnitude');
title('Time evolution of the loaded signal')

% Print BPM
[bpm, R_locs] = bpm_threshold(data, th, Fs);
% Figures PQRST
[segment, P_loc, Q_loc, R_loc, S_loc, T_loc] = ecg_threshold(data, R_locs, i_seg);
time_segment = (1:length(segment))/Fs;

figure;
h = plot(time_segment, segment); grid on;
hold on;
plot(time_segment(P_loc),segment(P_loc), '*','Color','red'); text(time_segment(P_loc),segment(P_loc),' P ','Color','red','FontSize',14);
plot(time_segment(Q_loc),segment(Q_loc), '*','Color','red'); text(time_segment(Q_loc),segment(Q_loc),' Q ','Color','red','FontSize',14);
plot(time_segment(R_loc),segment(R_loc), '*','Color','red'); text(time_segment(R_loc),segment(R_loc),' R ','Color','red','FontSize',14);
plot(time_segment(S_loc),segment(S_loc), '*','Color','red'); text(time_segment(S_loc),segment(S_loc),' S ','Color','red','FontSize',14);
plot(time_segment(T_loc),segment(T_loc), '*','Color','red'); text(time_segment(T_loc),segment(T_loc),' T ','Color','red','FontSize',14);
hold off;
xlabel('Time (s)');
ylabel('Magnitude');
title('ECG segment characteristic')

%% Your turn : My new method ! 
%%% Band-pass filter
ecg_1 = filter([1 0 0 0 0 0 -1], [1 -1], data); %low_pass filter
ecg_1 = filter([1 0 0 0 0 0 -1], [1 -1], ecg_1); %square
b1 = zeros(1,33);
b1(1,1) = -1;
b1(1,17) = 32;
b1(1,18) = -32;
b1(1,32) = 1;

ecg_2 = filter(b1, [1 -1], ecg_1); %high-pass filter


%%% Derivative
 b2 = [1 2 0 -2 -1]*(1/8)*Fs;   
delay = 2; % delai introduit par la causalite forcee du filtre
ecg_3 = filter(b2, 1, ecg_2); %derivative filter shifted
delay = delay + 2;

%%% Squared
ecg_4 = ecg_3.^2;

%%% Moving Window Integration
N = 0.15 * Fs -1; % double of the width of an average QRS complex = 0.15s = 0.15 * Fs points
% -1 pour avoir un delay entier lorsqu'on calcule le delai
Smwi = (1/N)*conv(ones(1,N),ecg_4);
figure;
plot(Smwi);
title('Smwi');
delay = delay + (N-1)/2; % la fenetre introduit un delai de (N-1)/2

delay_vector = zeros(1,delay); %creation du vecteur delai
delay_vector(1,delay)=1; % mise en place d'un dirac a la position delay
ecg_2_delay = conv(ecg_2,delay_vector);% ajout du delai a la sortie du filtre passe_bande


%%% Thresholding
th = mean(Smwi)+0.25*mean(Smwi); % seuil arbitraire

%[pks, loc] = findpeaks(Smwi);

 for i=1:length(Smwi)
     if (Smwi(1,i) < th)  % on accepte jusqu'a -30% en dessous de la moyenne des 5 derniers
         Smwi(1,i)=0;
     end
 end
 R_loc=[1];
 pks_start=1;
 pks_end=1;
 while j~=length(ecg_2_delay)
        while ecg_2_delay(1,j)~=0
            if pks_start < j
                pks_start=j;
            end
            pks_end=j;
            j=j+1;
        end
        if j~=0
            segment = ecg_2_delay(pks_start:pks_end);
            [M]
            R_loc=[R_loc j];
        end
        j=j+1;
 end

 figure;
hold on; plot(ecg_2_delay/max(ecg_2)); plot(Smwi/max(Smwi)); hold off
 
%%% Locations of

 %loc_ecg_th = find(pks);
 %R_ecg_loc = loc(loc_ecg_th);
 
time_segment_ecg = (1:length(ecg_2_delay))/Fs;
 
 %figure;
 %h = plot(time_segment_ecg, ecg_2_delay); grid on;
 hold on;
% plot(time_segment_ecg(P_ecg_loc),segment_ecg(P_ecg_loc), '*','Color','red'); text(time_segment_ecg(P_ecg_loc),segment(P_ecg_loc),' P ','Color','red','FontSize',14);
% plot(time_segment_ecg(Q_ecg_loc),segment_ecg(Q_ecg_loc), '*','Color','red'); text(time_segment_ecg(Q_ecg_loc),segment_ecg(Q_ecg_loc),' Q ','Color','red','FontSize',14);
 %plot(time_segment_ecg(R_ecg_loc),ecg_2_delay(R_ecg_loc), '*','Color','red'); text(ecg_2_delay(R_ecg_loc),ecg_2_delay(R_ecg_loc),' R ','Color','red','FontSize',14);
% plot(time_segment_ecg(S_ecg_loc),segment_ecg(S_ecg_loc), '*','Color','red'); text(time_segment_ecg(S_ecg_loc),segment_ecg(S_ecg_loc),' S ','Color','red','FontSize',14);
% plot(time_segment_ecg(T_ecg_loc),segment_ecg(T_ecg_loc), '*','Color','red'); text(time_segment_ecg(T_ecg_loc),segment_ecg(T_ecg_loc),' T ','Color','red','FontSize',14);
% hold off;
 xlabel('Time (s)');
 ylabel('Magnitude');
 title('ECG segment_ecg characteristic')






