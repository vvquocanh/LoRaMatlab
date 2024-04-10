function new_amplitude_modulated_signal = LoRa(pxx, amplitude_modulated_signal, primary_user_sampling_frequency)
    lora_signal_configuration = initialize_lora_signal_configuration("Hello World!", 100e3, 10, 14, 250e3);
    lora_signal_configurations = [lora_signal_configuration];
    threshold = 0.1;
    for configuration_index = 1:length(lora_signal_configurations)
        spectrum_hole = sense_spectrum_hole(pxx, threshold);
        center_frequency = find_center_frequency(pxx, spectrum_hole, lora_signal_configurations(configuration_index).bandwidth, primary_user_sampling_frequency);
        signal = LoRa_Tx(lora_signal_configurations(configuration_index).message, lora_signal_configurations(configuration_index).bandwidth, lora_signal_configurations(configuration_index).spreading_factor, lora_signal_configurations(configuration_index).power, lora_signal_configurations(configuration_index).sampling_frequency, 0);
        amplitude_modulated_signal = ammod(real(signal), center_frequency, primary_user_sampling_frequency);
        %disp(real(signal));
    end

    new_amplitude_modulated_signal = amplitude_modulated_signal;
end
    
function lora_signal_configuration = initialize_lora_signal_configuration(message, bandwidth, spreading_factor, power, sampling_frequency)
    lora_signal_configuration.message = message;
    lora_signal_configuration.bandwidth = bandwidth;
    lora_signal_configuration.spreading_factor = spreading_factor;
    lora_signal_configuration.power = power;
    lora_signal_configuration.sampling_frequency = sampling_frequency;
end

function spectrum_hole = sense_spectrum_hole(pxx, threshold)
    spectrum_hole(length(pxx)) = 0;
    for bin_index = 1:length(pxx)
        if (pxx(bin_index) > threshold)
            spectrum_hole(bin_index) = 1;
        end
    end
end

function center_frequency = find_center_frequency(pxx, spectrum_hole, desire_bandwidth, primary_user_sampling_frequency)
    HPSD = dspdata.psd(pxx, 'Fs', primary_user_sampling_frequency);
    beginning_index = 0;
    last_index = 0;
    current_bandwith = 0;

    for index = 1:length(spectrum_hole)
        if spectrum_hole(index) == 0
            if beginning_index == 0
                beginning_index = index;
            end
            if last_index == 0
                last_index = index;
            else
                last_index = last_index + 1;
            end
            current_bandwitdh = current_bandwith + (HPSD.Frequencies(last_index) - HPSD.Frequencies(beginning_index));
            if current_bandwitdh > desire_bandwidth
                center_frequency = (HPSD.Frequencies(beginning_index) + HPSD.Frequencies(last_index)) / 2;
                return;
            end
        else
            beginning_index = 0;
            last_index = 0;
            current_bandwith = 0;
        end
    end

    center_frequency = 0;
end