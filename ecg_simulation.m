%% =========================================================================
%  ELNG 222: SIGNALS AND SYSTEMS INDIVIDUAL PROJECT 1
%  PROJECT TITLE: ANALYSIS OF HUMAN ECG SIGNALS
%  CHAPTER 9: MATLAB SIMULATION SCRIPT
%  =========================================================================
%  Name: [Your Name]
%  Index Number: [Your Index Number]
%  Programme: BSc. Electrical and Electronics Engineering
%  Lecturer: [Lecturer's Name]
%  Submission Date: Friday, 17th July, 2026
%  =========================================================================

clear; clc; close all;

%% 1. CORE SIGNAL PARAMETERS (Chapter 2 & 3)
fs = 360;                       % Sampling frequency (360 Hz)
T = 1 / fs;                     % Sampling period (2.78 ms)
duration = 10;                  % Duration of window (10 seconds)
t = 0:T:(duration - T);          % Continuous-time analog time axis
N = length(t);                  % Total number of samples (3600 samples)
n = 0:(N-1);                    % Discrete-time sample index

% Heart rate settings (72 BPM -> R-R interval of 0.833 seconds)
rr_interval = 0.833;            

%% 2. MATHEMATICAL MODEL OF SINGLE HEARTBEAT (Section 3.1 & 7.1)
% Gaussian pulse parameters: [amplitude (mV), time center (s), width (s)]
P_wave = [0.12,  -0.18,  0.035];
Q_wave = [-0.15, -0.05,  0.010];
R_wave = [1.20,   0.00,  0.012]; % High-amplitude QRS Spike
S_wave = [-0.25,  0.05,  0.015];
T_wave = [0.25,   0.22,  0.060];

% Pulse generator lambda function
gaussian_pulse = @(t_val, wave) wave(1) * exp(-(t_val - wave(2)).^2 / (2 * wave(3)^2));

%% 3. TILE CARDIAC CYCLES & ADD NOISE (Section 5.3 & 10.3)
ecg_clean = zeros(1, N);
r_peak_times = 0.4 : rr_interval : (duration - 0.2); % Placement of R-peaks

% Superposition of individual beats
for r_time = r_peak_times
    t_shifted = t - r_time; % Time shifting to place each beat
    ecg_clean = ecg_clean + ...
                gaussian_pulse(t_shifted, P_wave) + ...
                gaussian_pulse(t_shifted, Q_wave) + ...
                gaussian_pulse(t_shifted, R_wave) + ...
                gaussian_pulse(t_shifted, S_wave) + ...
                gaussian_pulse(t_shifted, T_wave);
end

% Add baseline drift (breathing) and high-frequency EMG noise
rng(42); % Seed for consistent noise generation
baseline_drift = 0.12 * sin(2 * pi * 0.15 * t); % Slow 0.15 Hz wander
emg_noise = 0.02 * randn(1, N);                 % Random physical noise
ecg_noisy = ecg_clean + baseline_drift + emg_noise; % Final recorded ECG signal

%% 4. GRAPH 1: ORIGINAL ECG SIGNAL (Section 9.1.1)
figure('Position', [100, 100, 900, 450]);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Graph 1: Original Lead II ECG Signal (x[n] @ f_s = 360 Hz)');
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 3]); % Zoomed to 3 seconds so waves are clearly visible
%% 5. GRAPH 2: TIME-SHIFTED SIGNAL (Section 6.1 & 9.1.2)
% We shift the signal by delay_time seconds (t0 > 0)
delay_time = 0.5;                      % 0.5 seconds delay (shifting right)
shift_samples = round(delay_time * fs); % Convert time delay to discrete samples

% Pre-allocate the shifted signal array with zeros (matches signal length N)
ecg_shifted = zeros(1, N);

% Apply the shift mathematically: y[n] = x[n - n0]
% The first 'shift_samples' positions will remain 0 (representing the delay)
ecg_shifted((shift_samples + 1):end) = ecg_noisy(1:(end - shift_samples));

% Plot the original and shifted signals vertically for clean comparison
figure('Position', [150, 150, 900, 500]);

subplot(2,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Original Signal x[n]');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoomed to 4 seconds to inspect the shift clearly

subplot(2,1,2);
plot(t, ecg_shifted, 'b-', 'LineWidth', 1.2);
grid on;
title(['Time-Shifted Signal y[n] = x[n - ', num2str(shift_samples), '] (Delayed by ', num2str(delay_time), 's)']);
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoomed to the same range to show the 0.5s shift
%% 6. GRAPH 3: AMPLITUDE & TIME-SCALED SIGNAL (Section 6.3, 6.4 & 9.1.3)
% --- Amplitude Scaling ---
A_factor = 1.5;                        % Amplification factor (1.5x gain)
ecg_amp_scaled = A_factor * ecg_noisy; % y_amp[n] = A * x[n]

% --- Time Scaling (Compression / Down-sampling) ---
m_factor = 2;                          % Compression factor (keeps every 2nd sample)
ecg_time_scaled = ecg_noisy(1:m_factor:end); % Down-sample the signal array

% To visually show compression (making it play 2x faster in time):
% We plot the compressed samples against the original time spacing starting from t = 0
t_compressed = t(1:length(ecg_time_scaled)); 

% Plotting the results with FIXED limits so changes are visually obvious!
figure('Position', [200, 200, 900, 650]);

% Subplot 1: Original Signal
subplot(3,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Original Signal x[n]');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to 4 seconds
ylim([-0.5 2.0]); % Fixed y-limits to compare heights fairly!

% Subplot 2: Amplitude-Scaled Signal (Vertical expansion is now obvious!)
subplot(3,1,2);
plot(t, ecg_amp_scaled, 'm-', 'LineWidth', 1.2);
grid on;
title(['Amplitude-Scaled Signal: y_a[n] = ', num2str(A_factor), ' * x[n] (Stretched Vertically)']);
ylabel('Amplitude (mV)');
xlim([0 4]);
ylim([-0.5 2.0]); % Same y-limits as original to show the 1.5x boost!

% Subplot 3: Time-Scaled Signal (Horizontal compression is now obvious!)
subplot(3,1,3);
plot(t_compressed, ecg_time_scaled, 'g-', 'LineWidth', 1.2);
grid on;
title(['Time-Scaled (Compressed) Signal: y_t[n] = x[', num2str(m_factor), 'n] (Compressed 2x Horizontally)']);
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Same x-limits to show the compression!
ylim([-0.5 2.0]);
%% 7. GRAPH 4: TIME-REVERSED SIGNAL (Section 6.2 & 9.1.4)
% Time reversal: Flip the signal array horizontally from end to start
ecg_reversed = ecg_noisy(end:-1:1);

% Plotting the original and time-reversed signals side-by-side (vertically)
figure('Position', [250, 250, 900, 500]);

% Subplot 1: Original Signal
subplot(2,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Original Signal x[n]');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to first 4 seconds for a clear visual comparison

% Subplot 2: Time-Reversed Signal
subplot(2,1,2);
plot(t, ecg_reversed, 'k-', 'LineWidth', 1.2);
grid on;
title('Time-Reversed Signal: y_r[n] = x[-n] (Flipped Horizontally)');
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to first 4 seconds to inspect the reversed shape
%% 8. GRAPH 5: EVEN AND ODD COMPONENTS (Section 6.5 & 9.1.5)
% Calculate Even and Odd parts using original and reversed signals
ecg_even = 0.5 * (ecg_noisy + ecg_reversed);
ecg_odd  = 0.5 * (ecg_noisy - ecg_reversed);

% Plotting the results
figure('Position', [300, 100, 900, 700]);

% Subplot 1: Original Signal
subplot(3,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Original Signal x[n]');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to 4 seconds for consistency

% Subplot 2: Even Component (Symmetric)
subplot(3,1,2);
plot(t, ecg_even, 'b-', 'LineWidth', 1.2);
grid on;
title('Even Component: x_e[n] = 0.5 * (x[n] + x[-n])');
ylabel('Amplitude (mV)');
xlim([0 4]);

% Subplot 3: Odd Component (Anti-symmetric)
subplot(3,1,3);
plot(t, ecg_odd, 'g-', 'LineWidth', 1.2);
grid on;
title('Odd Component: x_o[n] = 0.5 * (x[n] - x[-n])');
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]);
%% 9. GRAPH 6: MOVING AVERAGE FILTER (Section 7.1 & 9.2.1)
% Define the window size (number of points to average)
M = 5; 

% Create the filter coefficients: b is an array of 1/M repeated M times, a is 1
b = (1/M) * ones(1, M);
a = 1;

% Apply the Moving Average filter using MATLAB's built-in 'filter' function
ecg_ma_filtered = filter(b, a, ecg_noisy);

% Plotting the original noisy signal vs the Moving Average filtered signal
figure('Position', [350, 150, 900, 600]);

% Subplot 1: Noisy ECG Signal (What we are trying to fix)
subplot(2,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Noisy ECG Signal (With Baseline Drift & Muscle Noise)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to 4 seconds to inspect the noise closely
ylim([-1.0 2.0]);

% Subplot 2: Filtered ECG Signal (Smooth and clean!)
subplot(2,1,2);
plot(t, ecg_ma_filtered, 'b-', 'LineWidth', 1.2);
grid on;
title(['Filtered Signal: ', num2str(M), '-Point Moving Average Filter']);
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to the same 4 seconds for a fair comparison
ylim([-1.0 2.0]);
%% 10. GRAPH 7: IIR FILTER (Section 7.2 & 9.2.2)
% Define the smoothing coefficient (alpha)
% A higher alpha (closer to 1) means smoother output but slightly more delay
alpha = 0.85; 

% Set up the filter coefficients based on the difference equation:
% y[n] - alpha*y[n-1] = (1 - alpha)*x[n]
b = 1 - alpha;      % Feedforward coefficient
a = [1, -alpha];    % Feedback coefficients

% Apply the IIR filter using MATLAB's built-in filter function
ecg_iir_filtered = filter(b, a, ecg_noisy);

% Plotting the original noisy signal vs the IIR filtered signal
figure('Position', [400, 100, 900, 600]);

% Subplot 1: Noisy ECG Signal
subplot(2,1,1);
plot(t, ecg_noisy, 'r-', 'LineWidth', 1.2);
grid on;
title('Noisy ECG Signal (With Baseline Drift & Muscle Noise)');
ylabel('Amplitude (mV)');
xlim([0 4]); % Zoom to 4 seconds
ylim([-1.0 2.0]);

% Subplot 2: Filtered ECG Signal (Notice how clean the baseline is!)
subplot(2,1,2);
plot(t, ecg_iir_filtered, 'b-', 'LineWidth', 1.2);
grid on;
title(['Filtered Signal: 1st-Order IIR Low-Pass Filter (\alpha = ', num2str(alpha), ')']);
xlabel('Time (seconds)');
ylabel('Amplitude (mV)');
xlim([0 4]);
ylim([-1.0 2.0]);