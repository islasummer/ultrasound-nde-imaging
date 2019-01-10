%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    SSP: Splitting the input signal into a number of frequency bands    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function decomposes the original received ultrasound signal       %
% frequency spectrum into a number of frequency bands using the          %
% previously created bank of Gaussian Bandpass filters.                  %
% This function takes in the filter bank and the input signal frequency  %
% spectrum as its input, multiplies each filter bank to this frequency   %
% spectrum and returns the result as array.                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function recomb_pt = splitBands(filter_bank, input_spectrum)
    
    % Multiply the Gaussian filter bank with the input spectrum
    [filters, samples] = size(filter_bank); % rows = filters, cols = samples
    y = zeros(filters, samples);
    for i = 1:filters
        y(i,:) = filter_bank(i,:) .* input_spectrum;
    end

% CONVERT OUTPUTS OF THE FILTER BANK BACK TO THE TIME DOMAIN
bands_ifft = zeros(filters,samples);
for j = 1:filters
    bands_ifft(j,:) = real(ifft(y(j,:)));
end


% RECOMBINATION
recomb_pt =  zeros(1,samples);

for k = 1:samples
    if (bands_ifft(:,k) > 0)
        recomb_pt(k) = min(bands_ifft(:,k)); % full_scan(k);
    elseif (bands_ifft(:,k) < 0)
        recomb_pt(k) = min(bands_ifft(:,k));  
    else
        recomb_pt(k) = 0;
    end
end

end