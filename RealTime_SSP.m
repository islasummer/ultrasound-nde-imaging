%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Real-time SSP                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = RealTime_SSP(streamdata, Fs)
N = max(size(streamdata)); % Number of samplea
    
FFT_data = fft(streamdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Split Spectrum Processing                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALUES FROM THE TRANSDUCER DATA SHEET
CENTRE_FREQ = 5.08e6; % 5.08 MHz
PEAK_FREQ = 5.48e6; % 5.48 MHz
HPBW = 3.66e6; % Half Power Bandwidth is 3.66 MHz
FBW = 10e6; % Full bandwidth of transducer is 10 MHz
WAVEFORM_DURATION = 1.656e-6; % -14dB=0.328us, -20dB=0.408, -40dB=1.656us

% USING SSP EQUATIONS FROM LITERATURE
delta_f = 1 / WAVEFORM_DURATION;          % Frequency separation in Hz
delta_f_s = round(delta_f * N/ Fs);       % Frequency separation in samples
Nu = 1 + round(HPBW * WAVEFORM_DURATION); % Number of uncorrelated filters
variance_s = delta_f_s / 2;               % Variance in samples (10 to 20)

% CREATE BANK OF BANDPASS FILTERS BASED ON SSP EQUATIONS
input = (1:N);
coeffs = filterBank(delta_f_s, Nu, variance_s, CENTRE_FREQ, HPBW, input, N, Fs);

% SPLIT FREQUENCY SPECTRUM OF CHANNEL 1 USING BAND OF BANDPASS FILTERS AND 
% RECOMBINE USING POLARITY THRESHOLDING AND MINIMISATION ALGORITHM
y = splitBands(coeffs, FFT_data);
end
