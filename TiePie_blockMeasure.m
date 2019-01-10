%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Saving Measurements in Block Mode                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Takes the data from the scope and saves to a matFile named 'blockData'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import LibTiePie.Const.*
import LibTiePie.Enum.*

% Wait for measurement to complete:
while ~scp.IsDataReady
    display('waiting for measurements to complete');
    pause(10e-3); % 10 ms delay, to save CPU time.
end

% Get all data from the scope:
wSeg = 1;
arData = scp.getData();
while scp.IsDataReady
    wSeg = wSeg + 1;
    arData(:,:,wSeg) = scp.getData();
end

% Add new scope measurements arData to blockData file
dlmwrite('blockData', arData);