function [RelativePower,RelativePowerLn] = freq_bands(f,fs,startend,freq_bands)

% Function for computing the Relative Power (RP) of a signal
%% Processing:
% First, we get the Power Spectral Density (PSD):
signal = f;
f = linspace(-fs/2,fs/2,length(signal));

%We get the positive index in the band-pass:
bandpass = logical((f >= startend(1)) & (f <= startend(2)));

num_bands = size(freq_bands,1);
RelativePower = NaN(1,num_bands);

%For each frequency band considered:
for i = 1:num_bands
    %The positive indexes in the frequency band are looked for:
    ind_frequency_band = min(find(f >= freq_bands(i,1))):max(find(f <= freq_bands(i,2)));
    %We compute the absolute power in the frequency band considered:
    RelativePower(i) = sum(signal(ind_frequency_band));
end
RelativePower= (abs(RelativePower)).^2;
RelativePower = real(RelativePower / sum(signal(bandpass)));
RelativePowerLn = real(log(exp(1).*RelativePower./min(RelativePower)));

