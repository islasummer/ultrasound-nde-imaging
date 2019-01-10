%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stream Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Applies a 1 MHz to 15 MHz bandpass filter to the test piece dataset to
% remove DC drift and then plots as A-scan and B-scan.
% Plots results after applying SSP algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONVERT TO THE FREQUENCY DOMAIN
fft_sample = fft(sample_data);
N = size(fft_sample,1);

% PRODUCE A BANDPASS FILTER TO REMOVE DRIFT
Index1M = round((1e6/Fs) * N+1) ; % Index at 1Mhz 
Index99M = round((N+2) - Index1M); % mirror for 99Mhz
fft_sample(1 : Index1M) = 0; % Remove all frequencies above 1Mhz
fft_sample(Index99M : N) = 0; % Remove all frequencies below 99Mhz for mirror

Index15M = round((15e6/Fs) * N+1) ; % Index at 1Mhz 
Index85M = round((N+2) - Index15M); % mirror for 99Mhz
fft_sample(Index15M : N/2) = 0; % Remove all frequencies above 1Mhz
fft_sample(N/2 : Index85M) = 0; % Remove all frequencies below 99Mhz for mirror

% CONVERT BACK TO THE TIME DOMAIN
ifft_sample = real(ifft(fft_sample));

% PLOT THE DATA WITHOUT ANY POST-PROCESSING
% A-scan over the complete time duration
figure(20);
Adata = ifft_sample;
subplot(2,2,1)
L = size(Adata,1);
time = linspace(0, L/Fs, L);
plot(time, abs(Adata));
title('A-scan of the test piece without applying SSP');
xlabel('Time (s)');
ylabel('Amplitude (V)');

% Plot B-scan:
subplot(2,2,3)
length = getappdata(0, 'scanDist') - 0.05;
Bdata = reshape(ifft_sample, no_samples, []);
y = [0.05 length];      % distance from transducer
x = [0 31.4];
clims = [0.1 0.3];
imagesc(y, x, abs(Bdata), clims);
title('B-scan of the test piece without applying SSP');
xlabel('Length along the test piece (mm)');
ylabel('Depth of test piece (mm)');


% PLOTTING THE DATA AFTER SSP
% A-scan:
Adata = reshape(filtered_data, [], 1);
subplot(2,2,2)
L = size(Adata,1);
time = linspace(0, L/Fs, L);
plot(time, abs(Adata));
title('A-scan of the test piece after applying SSP');
xlabel('Time (s)');
ylabel('Amplitude');

% B-scan:
subplot(2,2,4);
Bdata = filtered_data;
y = [0.05 length];      % distance from transducer
x = [0 31.4];
clims = [0 0.002];
imagesc(y, x, abs(Bdata), clims);
title('B-scan of the test piece after applying SSP');
xlabel('Length along the test piece (mm)');
ylabel('Depth of test piece (mm)');

% Greyscale B-scan image
figure(22);
I = mat2gray(abs(Bdata));
imshow(I);