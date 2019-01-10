%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Plotting the Data taken in Block Measurement Mode           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Imports the data file containing the most recent scanning data.
% Plot the A-scan and B-scan without any post-processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IMPORT THE DATA FILE
fclose all;
raw = importdata('12.1_h4t6_50mm');
Fs = 100e6; %scp.SampleFrequency;           % sampling frequency
ch1 = raw(:,1:2:end);               % channel 1 is odd columns
N = size(ch1,1);                    % Number of samples
segments = size(ch1,2);
length = segments/20;

% Extracting test sample reflections from entire dataset
[pks, locs] = findpeaks(ch1(:,1),'MinPeakProminence', 0.3, ...
    'MinPeakDistance', 500); % Find distance between transmit and first echo
index1 = locs(2); %1726 %locs(1); %1400;    % removes area between transmitter and top of test piece
index2 = locs(2) + 1020; % 2746 %locs(1) + 1020;%2800; %2.42

sample = ch1(index1:index2, :);

% PLOT THE DATA WITHOUT ANY POST-PROCESSING
% A-scan over the complete time duration
Adata = reshape(sample, [], 1);
figure(10);
subplot(2,1,1);
L = size(Adata,1);
time = linspace(0, L/Fs, L);
plot(time, Adata);
title('A-scan of the test sample')
xlabel('Time (s)');
ylabel('Ampltiude (V)');

% B-scan of test sample
Bdata = abs(sample);
x = (0:length);                     % length mm
y = (0:31.4);                       % depth mm
subplot(2,1,2);
clims = [0 0.5];
imagesc(x, y, Bdata);
title('B-scan of the test sample')
xlabel('Length along the test piece (mm)');
ylabel('Approximate depth from the transducer (mm)');

% Greyscale B-scan image
figure(11)
I = mat2gray(abs(Bdata));
imshow(I);