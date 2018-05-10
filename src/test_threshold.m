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
b = zeros(1,33);
b(1,1) = -1;
b(1,17) = 32;
b(1,18) = -32;
b(1,32) = 1;

ecg_2 = filter(b, [1 1], ecg_1); %high-pass filter

%%% Derivative
 b = [1 2 0 -2 -1].*(1/8)*Fs;   
ecg_3 = filter(b, 1, ecg_2); %derivative filter shifted

%%% Squared
ecg_4 = ecg_3.^2;

%%% Moving Window Integration
N = 0.15 * Fs; % double of the width of an average QRS complex = 0.15s = 0.15 * Fs points
Smwi = (1/N)*conv(ones(1,N),ecg_4);
figure;
plot(Smwi);

%%% Thresholding
% Print BPM
[bpm, R_ecg_locs] = bpm_threshold(Smwi, th, Fs);

% Figures PQRST
[segment_ecg, P_ecg_loc, Q_ecg_loc, R_ecg_loc, S_ecg_loc, T_ecg_loc] = ecg_threshold(Smwi, R_ecg_locs, i_seg);

%%% Locations of

time_segment_ecg = (1:length(segment_ecg))/Fs;

figure;
h = plot(time_segment_ecg, segment_ecg); grid on;
hold on;
plot(time_segment_ecg(P_ecg_loc),segment_ecg(P_ecg_loc), '*','Color','red'); text(time_segment_ecg(P_ecg_loc),segment(P_ecg_loc),' P ','Color','red','FontSize',14);
plot(time_segment_ecg(Q_ecg_loc),segment_ecg(Q_ecg_loc), '*','Color','red'); text(time_segment_ecg(Q_ecg_loc),segment_ecg(Q_ecg_loc),' Q ','Color','red','FontSize',14);
plot(time_segment_ecg(R_ecg_loc),segment_ecg(R_ecg_loc), '*','Color','red'); text(time_segment_ecg(R_ecg_loc),segment_ecg(R_ecg_loc),' R ','Color','red','FontSize',14);
plot(time_segment_ecg(S_ecg_loc),segment_ecg(S_ecg_loc), '*','Color','red'); text(time_segment_ecg(S_ecg_loc),segment_ecg(S_ecg_loc),' S ','Color','red','FontSize',14);
plot(time_segment_ecg(T_ecg_loc),segment_ecg(T_ecg_loc), '*','Color','red'); text(time_segment_ecg(T_ecg_loc),segment_ecg(T_ecg_loc),' T ','Color','red','FontSize',14);
hold off;
xlabel('Time (s)');
ylabel('Magnitude');
title('ECG segment_ecg characteristic')






