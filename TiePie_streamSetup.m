%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Setup Stream Mode                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The measured data is transferred directly to the computer, without using
% the internal memory of the instrument. Measured data arrives in chunks.
% Each chunk contains record length samples which are sampled at the sample
% speed. These settings determine the time it takes for a chunk of data to
% be measured, which is the time between the arrival  of two consecutive
% chunks called the update rate. The 'Data Collector' I/O object can be
% used to collect the successive measuerements and combine them into one
% big chunk of data of up to 20 million samples.
% ++ Long measurements
% -- Sample speed limited by data transfer rate and computer speed
% -- Trigger of measurements is not available
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INITALISE THE TIEPIE
if verLessThan('matlab', '8')
    error('Matlab 8.0 (R2012b) or higher is required.');
end

% Open LibTiePie and display library info if not yet opened:
import LibTiePie.Const.*
import LibTiePie.Enum.*

if ~exist('LibTiePie', 'var')
    % Open LibTiePie:
    LibTiePie = LibTiePie.Library
end

% Update device list:
LibTiePie.DeviceList.update();

% SETUP STREAM MEASUREMENT MODE
clear scp;
for k = 0 : LibTiePie.DeviceList.Count - 1
    item = LibTiePie.DeviceList.getItemByIndex(k);
    if item.canOpen(DEVICETYPE.OSCILLOSCOPE)
        scp = item.openOscilloscope();
        if ismember(MM.STREAM, scp.MeasureModes)
            break;
        else
            clear scp;
        end
    end
end

if exist('scp', 'var')
    % Set measure mode:
    scp.MeasureMode = MM.STREAM;

    % Set sample frequency, max value is 20 MHz:
    scp.SampleFrequency = 20e6; % 20 MHz

    % Set record length:
    scp.RecordLength = 30e3; % 30 kS for 20 MHz

    % For all channels:
    for ch = scp.Channels
        % Enable channel to measure it:
        ch.Enabled = false;

        % Set range:
        ch.Range = 2; % 2V

        % Set coupling:
        ch.Coupling = CK.DCV; % DC Volt

        clear ch;
    end
    
    % Enable Channel 1 but not Channel 2
    scp.Channels(1).Enabled = true;
    scp.Channels(2).Enabled = false;

    % Print oscilloscope info:
    display(scp);

    % Create an empty array to store scope measurements
    data_points = getappdata(0, 'loops');
    sample = 200; % this is how many samples from start of emitter to bottom of sample
    setappdata(0, 'samples', sample);
    
    filtered_data = zeros(sample, data_points);     % samples x data points
    sample_data = zeros(sample * data_points, 1);   % total samples x 1
    raw = [];
else
    error('No oscilloscope available with stream measurement support!');
end
    