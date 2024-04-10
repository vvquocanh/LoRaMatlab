
clear
clc
close all;

SF = 10 ;
BW = 125e3 ;
fc = 915e6 ;
Power = 14 ;

message = "Hello World!" ;
    
%% Sampling
Fs = 10e6 ;
Fc = 921.5e6 ;
%% Transmit Signal

%sense_spectrum = Cognitive_Radio();
%if sense_spectrum ~= -1
%    Fc = sense_spectrum;
%end

%disp(['Used spectrum = ' num2str(Fc) ' Hz']);

signalIQ = LoRa_Tx(message,BW,SF,Power,Fs, Fc-fc) ;

Sxx = 10*log10(rms(signalIQ).^2) ;
disp(['Transmit Power   = ' num2str(Sxx) ' dBm'])

%% Plots
figure;
spectrogram(signalIQ,500,0,500,Fs,'yaxis','centered')
%spectrogram(signalIQ)
figure;
obw(signalIQ,Fs) ;
%% Received Signal
message_out = LoRa_Rx(signalIQ,BW,SF,2,Fs,Fc-fc) ;
%% Message Out
disp(['Message Received = ' char(message_out)])

