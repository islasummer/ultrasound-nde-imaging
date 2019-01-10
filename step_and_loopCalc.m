% Calculate the number of steps and number of loops requried to move

% Get the scanning distance
scan_dist = getappdata(0, 'scanDist');
% Get the resolution
resol = getappdata(0, 'res');

if resol == 1       % First drop-down option is 10 um
    res = 10;
elseif resol == 2   % Second drop-down option is 20 um
    res = 20;
elseif resol == 3   % Third drop-down option is 30 um
    res = 30;
elseif resol == 4
    res = 40;
elseif resol == 5
    res = 50;
elseif resol == 6
    res = 60;
elseif resol == 7
    res = 70;
elseif resol == 8
    res = 80;
elseif resol == 9
    res = 90;
else
    res = 100;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Microstep mode                             %
% Can only be used at a low RPM and for very small steps due to the      %
% unreliable I2C connnection                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NoofSteps = res/2.5; % Microstepping mode moves 2.5um in 1 step
% MaxDist = 110; % Maxmimum traversible distance of the scanner in mm
% MaxStepNo = 44000; % Number of steps required to move 110mm
% DistanceStep = (MaxStepNo/MaxDist) * scan_dist; % steps per mm * distance (mm)
% NoofLoops = DistanceStep/NoofSteps;
% NoofLoops = round(NoofLoops);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Single step mode                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NoofSteps = res/10; % Single mode moves 10um in 1 step
NoofLoops = scan_dist/(res*0.001); % converts res to mm
NoofLoops = round(NoofLoops);


% Number of steps and number of loops to be accessible outside this function
setappdata(0, 'steps', NoofSteps);
setappdata(0, 'loops', NoofLoops);
