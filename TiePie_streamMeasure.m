%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Measurements in Stream Mode                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The data is measured in 10 chunks, each of sample length 25,000. The   %
% scope is started at the beginning of the measurement section and the   %
% 555 triggered. In each data chunk, 25,000 samples are taken and of     %
% only the section showing the ultrasound reflections from the sample    %
% are shown as an A-scan and B-scan. This is done by comparing each      %
% data point to a threshold voltage. This reduced data set is then       %
% digitally processed using the SSP algorithm with absolute minimisation %
% and polarity thresholding. The unprocessed and processed data is then  %
% displayed as an A-scan and a B-scan.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import LibTiePie.Const.*
import LibTiePie.Enum.*

% SAMPLING AND EXPERIMENTAL PARAMETERS
Fs = scp.SampleFrequency;               % Sampling frequency
record_length = scp.RecordLength;       % No of samples in each data chunk
no_samples = getappdata(0, 'samples');  % No of samples from top of test piece to bottom
length = getappdata(0, 'scanDist');     % Scanning length along test piece
threshold = 0.5;                        % 0.5V
offset = 350;  				% Removes area between transmitter and top of test piece
sample_size = record_length - no_samples - offset;
loop_no = getappdata(0, 'scan_progress'); % Gets number of motor loops

% START MEASURING
scp.start();    % start the scope

timerPulse;   % trigger the 555 Timer

% Create empty arrays to store results
usefulData = [];
dataOut = [];

% Measure 10 chunks:
for k = 1 : 10 % N.B. keep update rate below 10 updates per second
    
    % Wait for measurement to complete: N.B. MAY NEED TO COMMENT OUT
    while ~(scp.IsDataReady || scp.IsDataOverflow)
        pause(10e-3) % 10 ms delay, to save CPU time.
    end
    
    % Get data:
    newData = scp.getData();
    channel1 = newData(:,1); 	% Only taking channel 1
    raw = [raw; channel1]; 	% Add new data to array
    i = 1;
    while(i < sample_size)
        if channel1(i) > threshold      % Check for values above 0.5V - I.e.for ultrasound transmit pulse
            sample = [];
            j = i + offset;     	% save only the data corresponding to the test piece
            for k = 1 : no_samples
                sample(k) = channel1(j);
                j = j + 1;
            end
            i = i + 10e3; 		% skip a number of samples for next transmit pulse
            
            % APPLYING THE SSP ALGORITHM TO THE SELECTED DATA SET
            ssp_out = RealTime_SSP(sample, Fs);
            ssp_out = ssp_out.';
            sample = sample.';
            
            lower = 1 + (no_samples * (loop_no-1));
            upper = no_samples * loop_no;
            
            sample_data(lower:upper,1) = sample(:,1);
            filtered_data(:,loop_no) = ssp_out(:,1);
            
        end
        i = i + 1;
    end
end

scp.stop(); % end measurements