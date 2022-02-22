clear all; close all;
% Sampling
fs = 32;     % Sampling rate [Hz]
Ts = 1/fs;     % Sampling period [s]
fNy = fs / 2;  % Nyquist frequency [Hz]
duration = 1; % Duration [s]
% Sampling
t = 0: 1/(5*pi) :pi ;
noSamples = length(t);    % Number of samples

%%
x = sin(t);
plt = plot(x,'DisplayName','x')
hold on
x1 = sin(2.* t);
plot(x1,'DisplayName','x1')
x2 = sin(4 .* t);
plot(x2,'DisplayName','x2')
x3 = sin(20 .* t);
plot(x3,'DisplayName','x3')
% x4 = sin(100 .* t);
% plot(x4)
hold off
legend show
xn = x + x1 + x2 + x3;
% Frequency analysis
f = 0 : fs/noSamples : fs - fs/noSamples; % Frequency vector
% FFT
x_fft = abs(fft(x));
xn_fft = abs(fft(xn));
% Plot
figure(1);
subplot(2,2,1);
plot(t, x);
subplot(2,2,2);
plot(t, xn);
subplot(2,2,3);
plot(f,x_fft);
xlim([0 fNy]);
subplot(2,2,4);
plot(f,xn_fft);
xlim([0 fNy]);
