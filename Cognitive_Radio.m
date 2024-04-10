close all;
clc;
clear;

%------------------------------ Set up primary users -------------------------%
start_frequency = 54e3;
end_frequency = 798e3;
number_of_primary_users = 3;
time = 0:0.00001:0.001;
primary_user_signal = cos(2*pi*1000*time);
primary_user_sampling_frequency = 1600e3;
disp(primary_user_signal);
[amplitude_modulated_signal, pxx] = set_up_primary_users(primary_user_signal, start_frequency, end_frequency, primary_user_sampling_frequency, number_of_primary_users);
HPSD = plot_psd(pxx, primary_user_sampling_frequency, "PSD from primary users");
%----------------------------- Add noise -------------------------------------%
%noise = 5;
%[amplitude_modulated_signal, pxx] = add_noise(amplitude_modulated_signal, noise);
%plot_psd(pxx, primary_user_sampling_frequency, "PSD with noise");

%---------------------------- Secondary user sensing -------------------------%

new_amplitude_modulated_signal = LoRa(pxx, amplitude_modulated_signal, primary_user_sampling_frequency);
new_pxx = periodogram(new_amplitude_modulated_signal);
new_HPSD = plot_psd(new_pxx, primary_user_sampling_frequency, "PSD after secondary users sensing");

%----------------------------------- Function --------------------------------%
function [amplitude_modulated_signal, pxx] = set_up_primary_users(primary_user_signal, start_frequency, end_frequency, primary_user_sampling_frequency, number_of_primary_users)
    amplitude_modulated_signal = 0;
    for primary_user_index = 1:number_of_primary_users
        primary_user_carrier_frequency = (start_frequency + (end_frequency-start_frequency)*rand(1));
        disp(primary_user_carrier_frequency);
        pxx_individualy = periodogram(ammod(primary_user_signal, primary_user_carrier_frequency, primary_user_sampling_frequency));
        HPSD = dspdata.psd(pxx_individualy,'Fs',primary_user_sampling_frequency);
        figure;
        plot(HPSD);
        amplitude_modulated_signal = amplitude_modulated_signal + ammod(primary_user_signal, primary_user_carrier_frequency, primary_user_sampling_frequency);
    end
    pxx = periodogram(amplitude_modulated_signal);
end

function HPSD = plot_psd(pxx, sampling_frequency, figure_title)
    HPSD = dspdata.psd(pxx,'Fs',sampling_frequency);
    figure;
    plot(HPSD);
    title(figure_title);
end

function [amplitude_modulated_signal, pxx] = add_noise(amplitude_modulated_signal_without_noise, noise)
    amplitude_modulated_signal = awgn(amplitude_modulated_signal_without_noise, noise);
    pxx = periodogram(amplitude_modulated_signal);
end
