%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           SSP: Creating Gaussian Bandpass filter bank                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Takes in the frequency separation, delta f, the number of filters, the %
% variance, the centre frequency of the transducer, the transducer       %
% bandwidth, the input array, and the number of samples as its input.    %
% Creates a bank of gaussian bandpass filters returned as an array y,    %
% where the number of rows is determined by the number of filters and    %
% the number of columns is determined by the number of samples.          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = filterBank(delta_f_s, filters, sigma, centre_freq, ...
    bandwidth, input, N, Fs)
    
    % Filter centre frequencies
    f1 = centre_freq - (bandwidth/2); % first filter centre freq in MHz
    f1_s = f1 * N/Fs; % in sample number i.e 3.25 MHz = 217 sample
    
    coeffs = zeros(filters, N); % create empty array to store filter bank
    for i = 1 : filters
        mean = f1_s + (i-1) * delta_f_s;
        coeffs(i,:) = gaussian(input, sigma, mean);
    end
    y = coeffs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Gaussian Function                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = gaussian(val, var, mean)
    y = ((2 * pi * (var.^2)).^(-0.5)) * exp (((val - mean).^2)/(-2 * var.^2));
end
