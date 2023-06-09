clear, clc, close all
% Signal Processing Toolbox Add-On for MATLAB is required.

% Lines 12 to 45: Background Noise Reduction of Audio File
% Lines 46 to 77: Demonstration of the Fourier Transform of a Whole Sound Wavefrom
% Lines 78 to 124: Demonstration of the Gabor Transform
% Lines 125 to 313: Determining the Optimum Spectrogram Creation Process
% Lines 314 to 526: Generating Relevant Spectrograms and Plots for All Fluids
% Lines 527 to 712: Generating Relevant Spectrograms and Plots for Only Water


% Background Noise Reduction of Audio Files:
temp_window_length = 256;
temp_window_overlap = 128;

figure("Name", "Spectrograms Before & After Background Noise Reduction")
        noise_reduction_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');
[sampled_data_before_noise_red, sample_rate_before_noise_red] = audioread("Recordings\before_noise_reduction.wav");
[sampled_data_after_noise_red, sample_rate_after_noise_red] = audioread("Recordings\after_noise_reduction.wav");

for x = 1:2
    nexttile
    if x == 1
        sampled_data_noise = sampled_data_before_noise_red;
        sample_rate_noise = sample_rate_before_noise_red;
        title_string = "Spectrogram Before Background Noise Reduction";
    elseif x == 2
        sampled_data_noise = sampled_data_after_noise_red;
        sample_rate_noise = sample_rate_after_noise_red;
        title_string = "Spectrogram After Background Noise Reduction";
    end
    [spec_magnitudes_noise, spec_freq_noise, spec_time_noise] = spectrogram(sampled_data_noise(:, 1), ...
            temp_window_length, temp_window_overlap, [], sample_rate_noise);
    spec_db_noise = mag2db(abs(spec_magnitudes_noise));
    spec_main_noise = pcolor(spec_time_noise, spec_freq_noise, spec_db_noise);
    spec_main_noise.ZData = spec_main_noise.CData;
    shading interp;
    db_colourbar = colorbar;
    db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
    title(title_string)
    xlabel("Time (Seconds)")
    ylabel("Frequency (Hz)")
end


% Demonstration of the Fourier Transform of a Whole Sound Wavefrom:
[sampled_data_fourier_demo, sample_rate_fourier_demo] = audioread("Recordings\demo.wav");
total_time_fourier_demo = (1:size(sampled_data_fourier_demo, 1))'/sample_rate_fourier_demo;
figure("Name", "Demonstration of the Fourier Transform of a Whole Sound Wavefrom")
fourier_demo_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');

% Plotting the waveform first.
nexttile
plot(total_time_fourier_demo, sampled_data_fourier_demo)
title("Sound Waveform of an Audio Recording")
xlabel("Time (Seconds)")
% The y-axis units are in terms of digital units and are normalised when loaded.
ylabel("Normalised Amplitude")
ylim([-0.65, 0.65])
xlim([0, total_time_fourier_demo(end)])
grid on

% The Fourier transform of the whole waveform is taken to demonstrate why
% it is not entirely useful.
fourier_demo_fft = fft(sampled_data_fourier_demo);
% Plotting the Fourier transform.
nexttile
frequency_ft = linspace(-sample_rate_fourier_demo/2, sample_rate_fourier_demo/2, length(fourier_demo_fft));
fftshifted_demo = real(fftshift(fourier_demo_fft));
plot(frequency_ft, fftshifted_demo/max(fftshifted_demo))
title("Fourier Transform of the Whole Sound Waveform")
xlabel("Frequency (Hz)")
ylabel("Normalised Amplitude")
ylim([-1.5, 1.5])
grid on


% Demonstration of the Gabor Transform:
[sampled_data_gabor_demo, sample_rate_gabor_demo] = audioread("Recordings\demo.wav");
total_time_gabor_demo = (1:size(sampled_data_gabor_demo, 1))'/sample_rate_gabor_demo;

times_gabor_demo_list = [0.8, 1.6];
for time_gabor_demo = 1:length(times_gabor_demo_list)
    figure("Name", "Demonstration of Gabor Transform at " + times_gabor_demo_list(time_gabor_demo) + " Seconds")
    gabor_filter = exp((-(total_time_gabor_demo-times_gabor_demo_list(time_gabor_demo)).^2)*100);

    % The section of the sound waveform within the Gabor filter is isolated.
    section_gabor_filter = double(gabor_filter).*double(sampled_data_gabor_demo);
    % The Fourier transform of section of the sound waveform within the Gabor filter is taken.
    section_fourier = fft(section_gabor_filter);

    % The Gabor filter is shown sliding across the sound waveform at each chosen time:
    subplot(3,1,1)
    plot(total_time_gabor_demo, sampled_data_gabor_demo * 2, 'k', total_time_gabor_demo, gabor_filter, 'b')
    title(["Gabor Filter Sliding Across the Sound Waveform", "(Currently at " + times_gabor_demo_list(time_gabor_demo) + " Seconds)"])
    xlabel("Time (Seconds)")
    ylabel(["Normalised" , "Amplitude"])
    ylim([-1.5, 1.5])
    xlim([0, total_time_gabor_demo(end)])
    grid on
    
    % Isolated section of the sound wave is shown at each chosen time:
    subplot(3,1,2)
    plot(total_time_gabor_demo, section_gabor_filter * 2, 'k')
    title("Isolated Section of the Sound Waveform at " + times_gabor_demo_list(time_gabor_demo) + " Seconds")
    xlabel("Time (Seconds)")
    ylabel(["Normalised" , "Amplitude"])
    ylim([-1, 1])
    xlim([0, total_time_gabor_demo(end)])
    grid on

    % The Fourier transform of the isolated section is shown:
    subplot(3,1,3)
    frequency_ft = linspace(-sample_rate_gabor_demo/2, sample_rate_gabor_demo/2, length(section_fourier));
    gabor_demo_fft = real(fftshift(section_fourier));
    plot(frequency_ft, (gabor_demo_fft/max(gabor_demo_fft)))
    xlabel("Frequency (Hz)")
    ylabel(["Normalised" , "Amplitude"])
    title("Fourier Transform of the Isolated Section at " + num2str(times_gabor_demo_list(time_gabor_demo)) + " Seconds")
    ylim([-1.5, 1.5])
    grid on
end


% Experimental Data and Audio File Name Specifications:
fluids = ["Water", "Milk", "Olive Oil", "Honey", "Oat Milk", "the Water Sample"];
file_prefix = ["water", "milk", "olive_oil", "honey", "oat_milk", "water_sample"];
temps_low = ["4.7 \circC", "11.6 \circC", "43.2 \circC", "95.3 \circC", "7.1 \circC", "A Low Temperature"];
temps_high = ["70.1 \circC", "82.5 \circC", "131.7 \circC", "127.4 \circC", "75.6 \circC", "A High Temperature"];

% Using the Demonstration Recording of Water to Determine Spectrogram Creation Properties:
[sampled_data_test, sample_rate_test] = audioread("Recordings\demo.wav");


% Comparing Linear Frequency and Logarithmic Frequency Spectrograms:

% Logarithmic frequency y-axis tick values to be used when plotting
% frequency on a logarithmic scale.
y_ticks_log = [0, 100, 300, 600, 1100, 2500, 5000, 10000, 20000];
y_ticks_log_3d = [0, 100, 700, 2500, 7000, 20000];

figure("Name", "Comparing Linear and Logarithmic Frequency Spectrograms")
specs_log_lin_tiles= tiledlayout(2, 1, 'TileSpacing','Compact');

nexttile
[spec_magnitudes_lin, spec_freq_lin, spec_time_lin] = spectrogram(sampled_data_test(:, 1), ...
        temp_window_length, temp_window_overlap, [], sample_rate_test);
spec_db_lin = mag2db(abs(spec_magnitudes_lin));
spec_main_lin = pcolor(spec_time_lin, spec_freq_lin, spec_db_lin);
spec_main_lin.ZData = spec_main_lin.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title("Linear Frequency Spectrogram")
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")

nexttile
[spec_magnitudes_log, spec_freq_log, spec_time_log] = spectrogram(sampled_data_test(:, 1), ...
        temp_window_length, temp_window_overlap, [], sample_rate_test);
spec_db_log = mag2db(abs(spec_magnitudes_log));
spec_main_log = pcolor(spec_time_log, spec_freq_log, spec_db_log);
spec_main_log.ZData = spec_main_log.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title("Logarithmic Frequency Spectrogram")
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
set(gca, 'YScale', 'log')
yticks(y_ticks_log)


% Finding the Optimum Window Length and Window Overlap of the Gabor Filter (Hanning Window):

% 8 pairs of window lengths and window overlaps which will be checked to
% determine the final gabor filter (hanning window) properties.
window_lengths = [256, 512, 1024, 1024, 2048, 2048, 2048, 4096, 4096];
window_overlaps = [128, 256, 512, 920, 1024, 1640, 1850, 2048, 3280];

figure('Name', "Spectrogram Created Using Different Window Properties (1/3)")
signal_points_z_1_all = [];
signal_points_z_2_all = [];
noise_points_z_1_all = [];
noise_points_z_2_all = [];
spectrograms_window_tests_tiles1 = tiledlayout(3, 1, 'TileSpacing','Compact');

for window_setting = 1:length(window_lengths)
    if window_setting == 4
        figure('Name', "Spectrogram Created Using Different Window Properties (2/3)")
        spectrograms_window_tests_tiles2 = tiledlayout(3, 1, 'TileSpacing','Compact');
    elseif window_setting == 7
        figure('Name', "Spectrogram Created Using Different Window Properties (3/3)")
        spectrograms_window_tests_tiles3 = tiledlayout(3, 1, 'TileSpacing','Compact');
    end
    nexttile
    [spec_magnitudes_test, spec_freq_test, spec_time_test] = spectrogram(sampled_data_test(:, 1), ...
        window_lengths(window_setting), window_overlaps(window_setting), [], sample_rate_test);
    spec_db_test = mag2db(abs(spec_magnitudes_test));
    spec_main_test = pcolor(spec_time_test, spec_freq_test, spec_db_test);
    spec_main_test.ZData = spec_main_test.CData;
    shading interp;
    db_colourbar = colorbar;
    db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
    title(["Window Length = " + window_lengths(window_setting) + " Samples", ...
        "and Window Overlap = " + window_overlaps(window_setting) + " Samples"])
    xlabel("Time (Seconds)")
    ylabel("Frequency (Hz)")
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log)
    
    % The same background noise point and the same desired signal point are
    % selected on each spectrogram. The ratio of the signal to backround noise
    % intensity will be calculated and used for comparison.

    % Signal points.
    signal_x1 = 0.934603;
    signal_y1 = 3962.11;
    hold on
    signal_point1 = scatter(signal_x1, signal_y1, "k", "filled", 'LineWidth', 2);
    signal_point_z1 = interp2(spec_main_test.XData,spec_main_test.YData,spec_main_test.CData, signal_x1, signal_y1);
    text(signal_x1 + 0.06, signal_y1, num2str(signal_point_z1));

    signal_x2 = 2.08399;
    signal_y2 = 7924.22;
    hold on
    signal_point2 = scatter(signal_x2, signal_y2, "k", "filled", 'LineWidth', 2);
    signal_point_z2 = interp2(spec_main_test.XData,spec_main_test.YData,spec_main_test.CData, signal_x2, signal_y2);
    text(signal_x2 + 0.06, signal_y2, num2str(signal_point_z2));
    
    signal_points_z_1_all(window_setting) = signal_point_z1;
    signal_points_z_2_all(window_setting) = signal_point_z2;

    % (Background) Noise points.
    noise_x1 = 0.16254;
    noise_y1 = 9474.61;
    hold on
    noise_point1 = scatter(noise_x1, noise_y1, "k", "filled", 'LineWidth', 2);
    noise_point_z1 = interp2(spec_main_test.XData,spec_main_test.YData,spec_main_test.CData, noise_x1, noise_y1);
    text(noise_x1 + 0.06, noise_y1, num2str(noise_point_z1));

    noise_x2 = 0.410431;
    noise_y2 = 16020.7;
    hold on
    noise_point2 = scatter(noise_x2, noise_y2, "k", "filled", 'LineWidth', 2);
    noise_point_z2 = interp2(spec_main_test.XData,spec_main_test.YData,spec_main_test.CData, noise_x2, noise_y2);
    text(noise_x2 + 0.06, noise_y2, num2str(noise_point_z2));

    noise_points_z_1_all(window_setting) = noise_point_z1;
    noise_points_z_2_all(window_setting) = noise_point_z2;
end

% Taking the Average of the Intensities of the Two Noise and Two Signal 
% Points and Then Calculating and Plotting the Signal-to-Noise Ratio (SNR)
% to Determine the Optimum Window Properties:
figure("Name", "Window Properties Effect on Signal-to-Noise Ratio (SNR)")

signal_points_z_aver = [];
noise_points_z_aver = [];
window_settings_x = {};
for window_setting = 1:length(window_lengths)
    signal_points_z_aver(window_setting) = mean([signal_points_z_1_all(window_setting), signal_points_z_2_all(window_setting)]);
    noise_points_z_aver(window_setting) = mean([noise_points_z_1_all(window_setting), noise_points_z_2_all(window_setting)]);
    temp_x_axis_label = "W.L = " + num2str(window_lengths(window_setting)) + ", W.O = " + num2str(window_overlaps(window_setting));
    window_settings_x = [window_settings_x, temp_x_axis_label];
end

signal_noise_ratios = signal_points_z_aver ./ noise_points_z_aver;
bar(categorical(window_settings_x, window_settings_x), signal_noise_ratios)
title("Window Properties Effect on Signal-to-Noise Ratio (SNR)")
xlabel("Window Length (W.L) and Window Overlap (W.O)")
ylabel("Signal-to-Noise Ratio (SNR)")

[max_snr, max_snr_index] = max(signal_noise_ratios);

% Final Window Properties Determined Using the SNR Calculations:
figure('Name', "Spectrograms Created Using Window Lengths 256 and 2048")
specs_window_compare_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');

nexttile
[spec_magnitudes_256, spec_freq_256, spec_time_256] = spectrogram(sampled_data_test(:, 1), 256, 256/2, ...
    [], sample_rate_test);
spec_db_256 = mag2db(abs(spec_magnitudes_256));
spec_main_256 = pcolor(spec_time_256, spec_freq_256, spec_db_256);
spec_main_256.ZData = spec_main_256.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title(["Spectrogram Created Using", "a Window Length of 256 Samples"])
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

nexttile
[spec_magnitudes_2048, spec_freq_2048, spec_time_2048] = spectrogram(sampled_data_test(:, 1), 2048, 2048/2, ...
    [], sample_rate_test);
spec_db_2048 = mag2db(abs(spec_magnitudes_2048));
spec_main_2048 = pcolor(spec_time_2048, spec_freq_2048, spec_db_2048);
spec_main_2048.ZData = spec_main_2048.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title(["Spectrogram Created Using", "a Window Length of 2048 Samples"])
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

window_length = 2048;
window_overlap = 1024;


% Generating the Spectrograms/Plots Needed for Analysis:

% A for loop will loop through each fluid and generate the spectrograms,
% and the plots needed for analysis.
for fluid = 1:length(fluids)

% The audio files are imported into MATLAB for each fluid, the 
% sampled data and sample rate are the outputs.
[sampled_data_low, sample_rate_low] = audioread("Recordings\" + file_prefix(fluid) + "_low.wav");
[sample_data_high, sample_rate_high] = audioread("Recordings\" + file_prefix(fluid) + "_high.wav");

% Main Spectrograms:
figure('Name', "Spectrograms of the " + fluids(fluid) + " Audio Files")
spectrograms_2d_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');

% The Spectrogram function from the Signal Processing Toolbox is now used to
% generate the spectrograms.
nexttile
[spec_magnitudes_low, spec_freq_low, spec_time_low] = spectrogram(sampled_data_low(:, 1), window_length, window_overlap, ...
    [], sample_rate_low);
spec_db_low = mag2db(abs(spec_magnitudes_low));
spec_main_low = pcolor(spec_time_low, spec_freq_low, spec_db_low);
spec_main_low.ZData = spec_main_low.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title("Spectrogram of " + fluids(fluid) + " at " + temps_low(fluid))
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

nexttile
[spec_magnitudes_high, spec_freq_high, spec_time_high] = spectrogram(sample_data_high(:, 1), window_length, window_overlap, ...
    [], sample_rate_high);
spec_db_high = mag2db(abs(spec_magnitudes_high));
spec_main_high = pcolor(spec_time_high, spec_freq_high, spec_db_high);
spec_main_high.ZData = spec_main_high.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title("Spectrogram of " + fluids(fluid) + " at " + temps_high(fluid))
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

if fluid ~= 6
% Spectrograms Overlaid with the Highest Sound Intensity Frequencies:
figure('Name', "Spectrograms of " + fluids(fluid) + " Overlaid with the Highest Sound Intensity Frequencies")
spectrograms_intensity_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');

nexttile
spec_db_low = mag2db(abs(spec_magnitudes_low));
spec_max_db_vals_low = [];
spec_max_freq_vals_low = [];
for y = 1:size(spec_db_low,2)
  [max_db_temp, max_db_temp_index] = max(spec_db_low(:, y));
  spec_max_db_vals_low(y) = max_db_temp;
  spec_max_freq_vals_low(y) = spec_freq_low(max_db_temp_index);
end
spec_main_low = pcolor(spec_time_low, spec_freq_low, spec_db_low);
spec_main_low.ZData = spec_main_low.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title(["Spectrogram of " + fluids(fluid) + " at " + temps_low(fluid), " Overlaid with the Highest Sound Intensity Frequencies"])
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
hold on
overlay_intensity_2d_low = plot(spec_time_low, spec_max_freq_vals_low, 'linewidth', 1.5, 'Color', [16, 48, 230]/255);
overlay_intensity_2d_low.ZData = spec_max_db_vals_low;
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

nexttile
spec_db_high = mag2db(abs(spec_magnitudes_high));
spec_max_db_vals_high = [];
spec_max_freq_vals_high = [];
for y = 1:size(spec_db_high, 2)
  [max_db_temp, max_db_temp_index] = max(spec_db_high(:, y));
  spec_max_db_vals_high(y) = max_db_temp;
  spec_max_freq_vals_high(y) = spec_freq_high(max_db_temp_index);
end
spec_main_high = pcolor(spec_time_high, spec_freq_high, spec_db_high);
spec_main_high.ZData = spec_main_high.CData;
shading interp;
db_colourbar = colorbar;
db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
title(["Spectrogram of " + fluids(fluid) + " at " + temps_high(fluid), " Overlaid with the Highest Sound Intensity Frequencies"])
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
hold on
overlay_intensity_2d_high = plot(spec_time_high, spec_max_freq_vals_high, 'linewidth', 1.5, 'Color', [232, 35, 21]/255);
overlay_intensity_2d_high.ZData = spec_max_db_vals_high;
set(gca, 'YScale', 'log')
yticks(y_ticks_log)


% Normalised Correlation Between the Spectrograms:
figure('Name', "Normalised Correlation Between the Spectrograms of " + fluids(fluid))
[spec_magnitudes_low_corr, spec_freq_low_corr, spec_time_low_corr] = spectrogram(sampled_data_low(:,1), window_length, window_overlap, ...
    [], sample_rate_low);
[spec_magnitudes_high_corr, spec_freq_high_corr, spec_time_high_corr] = spectrogram(sample_data_high(:,1), window_length, window_overlap, ...
    [], sample_rate_high);

shortest_spec_length = min(size(spec_magnitudes_low_corr, 2), size(spec_magnitudes_high_corr, 2));

spec_magnitudes_low_corr = spec_magnitudes_low_corr(:, 1:shortest_spec_length);
spec_magnitudes_high_corr = spec_magnitudes_high_corr(:, 1:shortest_spec_length);
spec_time_corr = spec_time_low_corr(1:shortest_spec_length);

spec_db_low_corr = mag2db(abs(spec_magnitudes_low_corr));
spec_db_high_corr = mag2db(abs(spec_magnitudes_high_corr));

f1 = spec_freq_low_corr;
f2 = spec_freq_high_corr;

% Calculating the correlation between the two spectrograms at each
% time-frequency pair.
% And length(spec_db_low_corr) == length(spec_db_high_corr) hence the
% dimensions of either can be used to set the size of the correlation values matrix.
spec_correlation_vals = zeros(size(spec_db_low_corr, 1), size(spec_db_low_corr, 2));
for col = 1:size(spec_db_low_corr, 2)
    for row = 1:size(spec_db_low_corr, 1)
        spec_correlation_vals(row, col) = xcorr2(spec_db_low_corr(row, col), spec_db_high_corr(row, col));
    end
end

spec_correlation_vals_norm = abs(normalize(spec_correlation_vals, 'range', [-1, 1]));

% Creating a Heatmap of The Correlation Values at Each Time-Frequency Pair:
spec_correlation_map = pcolor(spec_time_corr, f1, spec_correlation_vals_norm);
spec_correlation_map.ZData = spec_correlation_map.CData;
shading interp;
corr_colourbar = colorbar;
corr_colourbar.Label.String = "Normalised Correlation";
title(["Normalised Correlation Between the Spectrograms of", fluids(fluid) + " at Different Temperatures"]);
xlabel('Time (Seconds)');
ylabel('Frequency (Hz)');
set(gca, 'YScale', 'log')
yticks(y_ticks_log)


% Normalised Correlation Between the Spectrograms Overlaid with the Highest Sound Intensity Frequencies:
figure('Name', "Normalised Correlation Between the Spectrograms of " + fluids(fluid) + " Overlaid with the Highest Sound Intensity Frequencies")
spec_correlation_map = pcolor(spec_time_corr, f1, spec_correlation_vals_norm);
spec_correlation_map.ZData = spec_correlation_map.CData;
shading interp;
corr_colourbar = colorbar;
corr_colourbar.Label.String = "Normalised Correlation";
title(["Normalised Correlation Between the Spectrograms of", fluids(fluid) + " at Different Temperatures Overlaid", "with the Highest Sound Intensity Frequencies"]);
xlabel('Time (Seconds)');
ylabel('Frequency (Hz)');
set(gca, 'YScale', 'log')
yticks(y_ticks_log)

rows_overlay_high = size(spec_max_db_vals_high, 1);
cols_overlay_high = size(spec_max_db_vals_high, 2);
rows_overlay_low = size(spec_max_db_vals_low, 1);
cols_overlay_low = size(spec_max_db_vals_low, 2);

bring_to_surface_high = 100*ones(rows_overlay_high, cols_overlay_high);
bring_to_surface_low = 100*ones(rows_overlay_low, cols_overlay_low);

hold on
overlay_intensity_2d_low = plot(spec_time_low, spec_max_freq_vals_low, 'linewidth', 1.5,  'Color', [16, 48, 230]/255);
overlay_intensity_2d_low.ZData = bring_to_surface_low;
data_cursor_object = datacursormode(gcf);
data_cursor_object.UpdateFcn = @(obj, event_obj) sprintf('Time (s): %.2f, Frequency (Hz): %.2f', event_obj.Position(1), event_obj.Position(2));

hold on
overlay_intensity_2d_high = plot(spec_time_high, spec_max_freq_vals_high, 'linewidth', 1.5, 'Color', [232, 35, 21]/255);
overlay_intensity_2d_high.ZData = bring_to_surface_high;
data_cursor_object = datacursormode(gcf);
data_cursor_object.UpdateFcn = @(obj, event_obj) sprintf('Time (s): %.2f, Frequency (Hz): %.2f', event_obj.Position(1), event_obj.Position(2));

legend("", temps_low(fluid), temps_high(fluid));


% 3D Spectrograms:
figure('Name', "3D Spectrograms of the " + fluids(fluid) + " Audio Files")
spectrograms_3d_tiles = tiledlayout(2, 1, 'TileSpacing','Compact');

nexttile
surf(spec_time_low, spec_freq_low, mag2db(abs(spec_magnitudes_low)), 'EdgeColor','none')
colormap(turbo)
db_3d_colourbar = colorbar;
db_3d_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
view(-30,60)
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
zlabel(["Sound Intensity", "(Decibels)"])
title("3D Spectrogram of " + fluids(fluid) + " at " + temps_low(fluid))
set(gca, 'YScale', 'log')
yticks(y_ticks_log_3d)

nexttile
surf(spec_time_high, spec_freq_high, mag2db(abs(spec_magnitudes_high)), 'EdgeColor','none')
colormap(turbo)
db_3d_colourbar = colorbar;
db_3d_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
view(-30,60)
xlabel("Time (Seconds)")
ylabel("Frequency (Hz)")
zlabel(["Sound Intensity", "(Decibels)"])
title("3D Spectrogram of " + fluids(fluid) + " at " + temps_high(fluid))
set(gca, 'YScale', 'log')
yticks(y_ticks_log_3d)
end
end


% The Next Section Involves Generating the Spectrograms and Plots Needed
% for the Analysis Focussing on Water:

[sampled_data_low, sample_rate_low] = audioread("Recordings\water_low.wav");
[sampled_data_mid1, sample_rate_mid1] = audioread("Recordings\water_mid1.wav");
[sample_data_mid2, sample_rate_mid2] = audioread("Recordings\water_mid2.wav");
[sample_data_high, sample_rate_high] = audioread("Recordings\water_high.wav");

water_temps = ["4.7", "20.8", "40.0", "70.1"];
water_sampled_data = {sampled_data_low, sampled_data_mid1, sample_data_mid2, sample_data_high};
water_sample_rates = {sample_rate_low, sample_rate_mid1, sample_rate_mid2, sample_rate_high};
water_colours = {[16, 48, 230]/255, [155, 16, 230]/255, [230, 130, 16]/255, [232, 35, 21]/255};


% Main Spectrograms Only for the Water Audio Files:
figure('Name', "Spectrograms of the Water Audio Files (1/2)")
spectrograms_water_tiles_1 = tiledlayout(2, 1, 'TileSpacing', 'Compact');

for x = 1:4
    if x == 3
        figure('Name', "Spectrograms of the Water Audio Files (2/2)")
        spectrograms_water_tiles_2 = tiledlayout(2, 1, 'TileSpacing', 'Compact');
    end
    nexttile
    [spec_magnitudes_water, spec_freq_water, spec_time_water] = spectrogram(water_sampled_data{x}(:, 1), window_length, ...
        window_overlap, [], water_sample_rates{x});
    spec_main_water = pcolor(spec_time_water,spec_freq_water, mag2db(abs(spec_magnitudes_water)));
    shading interp;
    spec_main_water.ZData = spec_main_water.CData;
    db_colourbar = colorbar;
    db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
    title("Spectrogram of Water at " + water_temps(x) + "\circC")
    xlabel("Time (Seconds)")
    ylabel("Frequency (Hz)")
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log)
end


% Spectrograms of Water Overlaid with the Highest Sound Intensity Frequencies:
figure('Name', "Spectrograms of Water Overlaid with the Highest Sound Intensity Frequencies (1/2)")
specs_intensity_tiles_water_1 = tiledlayout(2, 1, 'TileSpacing', 'Compact');

for x = 1:4
    if x == 3
        figure('Name', "Spectrograms of Water Overlaid with the Highest Sound Intensity Frequencies (2/2)")
        specs_intensity_tiles_water_2 = tiledlayout(2, 1, 'TileSpacing', 'Compact');
    end
    nexttile
    [spec_magnitudes_water, spec_freq_water, spec_time_water] = spectrogram(water_sampled_data{x}(:, 1), window_length, ...
        window_overlap, [], water_sample_rates{x});
    spec_main_water = pcolor(spec_time_water,spec_freq_water, mag2db(abs(spec_magnitudes_water)));
    shading interp;
    spec_main_water.ZData = spec_main_water.CData;
    db_colourbar = colorbar;
    db_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
    title(["Spectrogram of Water at " + water_temps(x) + "\circC Overlaid" , "with the Highest Sound Intensity Frequencies"])
    xlabel("Time (Seconds)")
    ylabel("Frequency (Hz)")
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log)

    spec_db_water = mag2db(abs(spec_magnitudes_water));
    spec_max_db_vals_water = [];
    spec_max_freq_vals_water = [];
    for y = 1:size(spec_db_water,2)
        [max_db_temp, max_db_temp_index] = max(spec_db_water(:,y));
        spec_max_db_vals_water(y) = max_db_temp;
        spec_max_freq_vals_water(y) = spec_freq_water(max_db_temp_index);
    end
    hold on
    overlay_intensity_2d_water = plot(spec_time_water, spec_max_freq_vals_water, 'linewidth', 1.5, 'Color', water_colours{x}); 
    overlay_intensity_2d_water.ZData = spec_max_db_vals_water;
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log)
end


% Highest Sound Intensity Frequencies of Water at All Temperatures:
figure('Name', "Highest Sound Intensity Frequencies of Water at All Temperatures (All)")

for x = 1:4
    [spec_magnitudes_water, spec_freq_water, spec_time_water] = spectrogram(water_sampled_data{x}(:, 1), window_length, ...
        window_overlap, [], water_sample_rates{x});
    spec_db_water = mag2db(abs(spec_magnitudes_water));
    spec_max_db_vals_water = [];
    spec_max_freq_vals_water = [];
    for y = 1:size(spec_db_water,2)
        [max_db_temp, max_db_temp_index] = max(spec_db_water(:,y));
        spec_max_db_vals_water(y) = max_db_temp;
        spec_max_freq_vals_water(y) = spec_freq_water(max_db_temp_index);
    end

    hold on
    overlay_intensity_2d_water = plot(spec_time_water, spec_max_freq_vals_water, 'linewidth', 1.5, 'Color', water_colours{x}, 'DisplayName', water_temps(x) + "\circC");
    overlay_intensity_2d_water.ZData = spec_max_db_vals_water;
    title(["Highest Sound Intensity Frequencies", "of Water at All Temperatures"])
    xlabel("Time (Seconds)")
    ylabel(["Highest Sound Intensity", "Frequency (Hz)"])
    legend show
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log)
end


% 3D Spectrograms of Water:
figure('Name', "3D Spectrograms of the Water Audio Files (1/2)")
specs_3d_tiles_water_1 = tiledlayout(2, 1, 'TileSpacing','Compact');

for x = 1:4
    if x == 3
        figure('Name', "3D Spectrograms of the Water Audio Files (2/2)")
        specs_3d_tiles_water_2 = tiledlayout(2, 1, 'TileSpacing','Compact');
    end
    nexttile
    [spec_magnitudes_water, spec_freq_water, spec_time_water] = spectrogram(water_sampled_data{x}(:, 1), window_length, ...
        window_overlap, [], water_sample_rates{x});
    surf(spec_time_water, spec_freq_water, mag2db(abs(spec_magnitudes_water)), 'EdgeColor','none')
    colormap(turbo)
    db_3d_colourbar = colorbar;
    db_3d_colourbar.Label.String = ["Sound Intensity", "(Decibels)"];
    view(-30,60)
    xlabel("Time (Seconds)")
    ylabel("Frequency (Hz)")
    zlabel(["Sound Intensity", "(Decibels)"])
    title("3D Spectrogram of Water at " + water_temps(x) + "\circC")
    set(gca, 'YScale', 'log')
    yticks(y_ticks_log_3d)
end


% Normalised Correlations Between All Spectrograms of Water:
figure("Name", "Normalised Correlations Between All Spectrograms of Water (All)")

comparison_times_start = [0.18576, 0.394739, 0.557279, 0.278639];

correlation_water_values = [];
times = [];
for x = 1:4
    for y = 1:4
        if x ~= y
            [spec_magnitudes_w1_corr, spec_freq_w1_corr, spec_time_w1_corr] = spectrogram(water_sampled_data{x}(:,1), window_length, window_overlap, ...
                [], water_sample_rates{x});
            [spec_magnitudes_w2_corr, spec_freq_w2_corr, spec_time_w2_corr] = spectrogram(water_sampled_data{y}(:,1), window_length, window_overlap, ...
                [], water_sample_rates{y});

            [temp_time_start_w1_val, temp_time_start_w1_idx] = min(abs(spec_time_w1_corr - comparison_times_start(x)));
            [temp_time_start_w2_val, temp_time_start_w2_idx] = min(abs(spec_time_w2_corr - comparison_times_start(y)));

            spec_db_w1_corr = mag2db(abs(spec_magnitudes_w1_corr(temp_time_start_w1_idx:end)));
            spec_db_w2_corr = mag2db(abs(spec_magnitudes_w2_corr(temp_time_start_w2_idx:end)));

            spec_db_w1_corr = spec_db_w1_corr./max(spec_db_w1_corr);
            spec_db_w2_corr = spec_db_w2_corr./max(spec_db_w2_corr);

            shortest_spec_length = min(size(spec_db_w1_corr, 2), size(spec_db_w2_corr, 2));

            spec_db_w1_corr = spec_db_w1_corr(1:shortest_spec_length);
            spec_db_w2_corr = spec_db_w2_corr(1:shortest_spec_length);

            f1 = spec_freq_w1_corr;
            f2 = spec_freq_w2_corr;
                
            spec_correlation_w_vals = zeros(size(spec_db_w1_corr, 1), size(spec_db_w1_corr, 2));
            for col = 1:size(spec_db_w1_corr, 2)
                for row = 1:size(spec_db_w1_corr, 1)
                    spec_correlation_w_vals(row, col) = xcorr2(spec_db_w1_corr(row, col), spec_db_w2_corr(row, col));
                end
            end
            spec_correlation_w_vals_norm = abs(normalize(spec_correlation_w_vals, 'range', [-1, 1]));
            average_correlation = mean(spec_correlation_w_vals_norm, "all" );
            correlation_water_values(x, y) = average_correlation;
        else
            correlation_water_values(x, y) = 1;
        end
    end
end

all_water_correlations = pcolor(str2double(water_temps), str2double(water_temps), correlation_water_values);
all_water_correlations.ZData = all_water_correlations.CData;
shading interp;
corr_colourbar = colorbar;
corr_colourbar.Label.String = "Normalised Correlation";
title("Normalised Correlations Between All Spectrograms of Water")
xlabel("Water Temperature (\circC)")
ylabel("Water Temperature (\circC)")
