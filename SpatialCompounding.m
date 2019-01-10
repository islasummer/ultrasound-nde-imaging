%%% Importing the text file
raw = importdata('11.1_hole3_10mm_far');
ch1 = raw(:,1:2:end); % channel 1 is odd columns

% PARAMETERS DEPENDENT ON SAMPLING CONDITIONS -- UPDATE IF NEEDED
Fs = 100e6;     % sampling frequency in Hz
res = 0.1;      % scanning resolution is 100um ie 0.1mm
beam_width = 2.2; % calculated as being 2.2 mm

% ISOLATING THE TEST SAMPLE FROM THE DATASET
% Extracting test sample reflections from entire dataset
[pks1, locs1] = findpeaks(ch1(:,1),'MinPeakProminence', 0.3, ...
    'MinPeakDistance', 500); % Find distance between transmit and first echo
index1 = locs1(2);    % removes area between transmitter and top of test piece
index2 = index1 + 1020; %locs1(3);    %locs2(3);

sample = ch1(index1:index2,:);
sample = sample.';                  % In form samples x segments

N = max(size(sample));              % Number of samples
segments = min(size(sample));       % Number of segments

full_scan = reshape(sample.', [], 1);
L = size(full_scan,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Finding location of defect                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flaw_peak = max(max(sample));
threshold = 0.8 * flaw_peak;
defect = sample > 0.6; % strongest echo reflections have a magnitude of 0.6V


overlap = round(beam_width / res);        % overlap in terms of segments
index = round(overlap/2);
new_sample = [];

for i = 1:segments
    if i > segments - index
        end_val = segments;
        start_val = i - index;
    elseif i < index + 1
        start_val = i;
        end_val = i + overlap;
    else
        end_val = i + index;
        start_val = i - index;
    end
    temp = sample(start_val:end_val , :);
    meanVal = mean(temp,1);
    new_sample(i,:) = meanVal;
end

FFT_sample = fft(new_sample,[],2); % 2 = FFT of each row, 1 = FFT of each col


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

%%%%%%%%%%%%%%%%%%%%%% A-scan plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(30)
subplot(2,1,1);
Adata = reshape(new_sample.', [], 1);
L = size(Adata,1);
time2 = linspace(0, L/Fs, L);
plot(time2, abs(Adata));
xlabel('Time [s]');
ylabel('Amplitude');
title('Ultrasound echo signal of the test sample after spatial compounding and applying SSP');

%%%%%%%%%%%%%%%%%%%%%% B-scan image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,2);
Bdata = new_sample.';
length = segments / 20;
x = (0:length);     % length mmm
y = (0:31.4);   % depth mm
clims = [0 1e-3];
imagesc(x, y, abs(Bdata));
title('B-scan of the test sample after spatial compounding and applying SSP');
xlabel('Length along test piece (mm)');
ylabel('Approximate depth from top of test piece (mm)');

%%%%%%%%%%%%%%%%%%%%% Grayscale Image %%%%%%%%%%%%%%%%%%%%%
I = mat2gray(abs(Bdata));
figure(31);
imshow(I);
axis on;
xticks([1 100 200]); %300 400 500 600 700 800 900 1024
xticklabels({'0','5','10'}); %'15', '20', '25', '30', '35', '40', '45','51'
xlabel('Length along test piece (mm)');

yticks([1 156 2*156 3*156 4*156 5*156 6*156 982]);
yticklabels({'0','5','10','15','20','25', '30' '31.4'});
ylabel('Approximate depth from top of test piece (mm)');