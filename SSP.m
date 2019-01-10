%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               SSP                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Split Spectrum Processing technique is applied to the imported data
% file which is in array of the form (samples x segements) for block
% measurement mode. Only the data containing the ultrasound echoes from the
% test piece is retained and processed using the SSP algorithm with PT and
% AM. The result is then plotted as an A-scan and B-scan.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTING THE DATA FILE
raw = importdata('blockData');

ch1 = raw(:,1:2:end); % channel 1 is odd columns

% PARAMETERS DEPENDENT ON SAMPLING CONDITIONS -- UPDATE IF NEEDED
Fs = 100e6; % sampling frequency in Hz

% ISOLATING THE TEST SAMPLE FROM THE DATASET
% Extracting test sample reflections from entire dataset
[pks1, locs1] = findpeaks(ch1(:,1),'MinPeakHeight', 0.6, ...
    'MinPeakDistance', 500); % Find distance between transmit and first echo
index1 = locs1(2);    % removes area between transmitter and top of test piece
[pks2, locs2] = findpeaks(ch1(:,1),'MinPeakHeight', 0.3, ...
    'MinPeakDistance', 500); % Finding backwall reflection
index2 = 2.5e3; %locs2(3);

sample = ch1(index1:index2,:);
sample = sample.';                  % in form samples x segments
N = max(size(sample));              % Number of samples
segments = min(size(sample));       % Number of segments

full_scan = reshape(sample, [], 1);
L = size(full_scan,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Pre-processing: performing FFT on channel 1              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FFT_sample = fft(sample,[],2); % 2 = FFT of each row, 1 = FFT of each col

% plot original signal in frequency domain
% FFT_CH1 = fft(full_scan);
% freq = linspace(0,Fs, L); % plot from 0 to Fs by increments of L
% figure(61); 
% plot(freq,abs(FFT_CH1));
% xlabel('Frequency [Hz]');
% ylabel('Amplitude');
% title('Ultrasonic signal frequency response');

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
coeffs = filterBank(delta_f_s, Nu, variance_s, CENTRE_FREQ, HPBW,...
    input, N, Fs);
% figure(62);
% plot(freq, coeffs);
% xlabel('Frequency [Hz]');
% ylabel('Amplitude');
% title('Gaussian filter coefficients frequency response');

% SPLIT FREQUENCY SPECTRUM OF CHANNEL 1 USING BAND OF BANDPASS FILTERS AND 
% RECOMBINE USING POLARITY THRESHOLDING AND MINIMISATION ALGORITHM
Bands = zeros(segments,N);
for i = 1:segments
    Bands(i,:) = splitBands(coeffs, FFT_sample(i,:));
end
Bands = Bands.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Displaying the Results                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A-SCAN
figure(65)
subplot(2,1,1);
Adata = reshape(Bands, [], 1);
L = size(Adata,1);
time2 = linspace(0, L/Fs, L);
plot(abs(Adata));
xlabel('Time (s)');
ylabel('Amplitude');
title('Ultrasound echo signal following SSP with PT and minimisation');

% B-SCAN
subplot(2,1,2);
length = segments / 10;
Bdata = Bands;
x = (0:length);     % length mmm
y = (0:31.4);   % depth mm

imagesc(x, y, abs(Bands));
title('B-scan of the test sample after SSP is applied');
xlabel('Length along test piece (mm)');
ylabel('Approximate depth from top of test piece (mm)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GREYSCALE IMAGE
I = mat2gray(Bdata);
figure(5);
imshow(I);
