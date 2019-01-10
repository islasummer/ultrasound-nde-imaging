%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Block Mode                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complete measuerments are recoreded in  the instrument's memory. After
% the full record has been measured the data is transferred to the computer
% The next measuremnt is started after the data is processed therefore
% there are gaps between the measurements.
% ++ This mode is fast and measurements can be triggered
% -- The record length is limited by instrument memory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INITIALISE THE TIEPIE
if verLessThan('matlab', '8')
    error('Matlab 8.0 (R2012b) or higher is required.');
end

% Open LibTiePie and display library info if not yet opened:
import LibTiePie.Const.*
import LibTiePie.Enum.*

if ~exist('LibTiePie', 'var')
    % Open LibTiePie:
    LibTiePie = LibTiePie.Library;
end

% Search for devices:
LibTiePie.DeviceList.update();

% SETUP BLOCK MEASUREMENT MODE
clear scp;
for k = 0 : LibTiePie.DeviceList.Count - 1
    item = LibTiePie.DeviceList.getItemByIndex(k);
    if item.canOpen(DEVICETYPE.OSCILLOSCOPE)
        scp = item.openOscilloscope();
        if ismember(MM.BLOCK, scp.MeasureModes)
            break;
        else
            clear scp;
        end
    end
end
clear item

if exist('scp', 'var')
    % Type of Measure mode: either block or stream
    scp.MeasureMode = MM.BLOCK;
    
    % Set sampling frequency to 100MHz
    scp.SampleFrequency = 100e6;

    % Set record length to 8,000 samples (N = t * Fs)
    scp.RecordLength =  20e3;

    % Set sample ratio to 0%
    scp.PreSampleRatio = 0; % 0%
    
    % Set segment count (= distance/resolution)
    data_points = getappdata(0, 'loops'); % gets number of times the motor will have to move the desired res to travel the specified length
    scp.SegmentCount = 2 * data_points; % Total segments for Ch1 and Ch2
    
    % For all channels:
    for ch = scp.Channels
        % Enable channels:
        ch.Enabled = false; % disable all channels
    
        % Set range:
        ch.Range = 2; % 2 V
    
        % Set coupling:
        ch.Coupling = CK.DCV; % DC Volt
 
        % Remove channel
        clear ch;
    end
    
    % Enable channel 1
    scp.Channels(1).Enabled = true;
    
    % Disable all channel trigger sources:
    for ch = scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
    end
    
    % SET THE EXTERNAL TRIGGER
    % Setup channel trigger:
    chTr = scp.Channels(1).Trigger; % Ch1 will be triggered externally

    % Enable trigger source:
    chTr.Enabled = true;
    
    % Set trigger timeout:
    scp.TriggerTimeOut = -1; % Waits indefinitely for a trigger pulse

    % Kind:
    chTr.Kind = TK.RISINGEDGE; % Rising edge

    % Level:
    chTr.Levels(1) = 0.5; % 50%

    % Hysteresis:
    chTr.Hystereses(1) = 0.05; % 5%

    % Release reference:
    clear chTr;
    
    scp.Channels(2).Enabled = false; % Ch1 triggered by Ch2
    
    % display oscilloscope info:
    display(scp);
    
else
    error('No oscilloscope available with block measurement support!');
end