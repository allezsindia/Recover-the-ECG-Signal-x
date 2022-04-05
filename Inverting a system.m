b = [0.5 zeros(1, 9) 2 zeros(1, 9) 1];
a = 1;
% y = filter(b, a, x);

y = load('ecg_distorted.txt');     %load data

% Definition of step and impulse
u = @(n) (n >= 0)
del = @(n) (n == 0);

ly = length(y)

%% Impulse response h
n = -ly:ly;
h = 0.5 * del(n) + 2 * del(n-10) + del(n-20);
figure(1)
stem(n, h)
title('h')
grid on;

%% impulse response g
n = -ly:ly;
g = filter(a,b,del(n));
figure(2)
stem(n, g);
xlim([0 50]);
title('convolutional inverse impulse response g')
grid on;

%% Another Method to find g: (Partial fraction expansion)
%[r, p, k] = residue([a],b)  
%g = 0
%for m = 1:20
    %g1 = r(m) * p(m).^n .* u(n);
    %g = g1 + g;
%end
%figure(2)
%stem(n, g);
%xlim([0 50]);
%title('convolutional inverse impulse response g')
%grid on;

%% Verify the inverse system
% Verify that the convolution of h and g is an impulse

f = conv(h, g);
figure(3)
l = -2*ly:2*ly;
stem(l, f)
title('conv(h, g)')
xlim([-40 40]);
grid on;

%% Plot the recovered ECG signal x
% method 1 to calculate signal x
% can make length(x) larger than output signal length(y) but it is OK.
% x = conv(y,g);    

% method 2 to calculate signal x
N = ly;
% Forward implementation
xf = zeros(1, N);
for n = 11:N
    xf(n) = sqrt(2)/(2^0.5+1)*y(n) - sqrt(2)/(2^0.5+1)*xf(n-10);
end

% Backward implementation
% Let the output of Forward xf as the input of Backward (Chain in the
% system)
xb = zeros(1, N);
for n = N-10:-1:1
    xb(n) = xf(n+10) - (2^0.5-1)/sqrt(2)*xb(n+10)
end

% Let x = xb as the recovered ECG Signal x
x = xb
n = 0:N-1;

figure(4)
clf
%subplot(3, 1, 1)
%stem(n, y, 'filled', 'black', 'markersize', 3) 
%title('Input signal')
%ylim([-2 2])

%subplot(3, 1, 2)
%stem(n, xf, 'filled', 'black', 'markersize', 3) 
%title('Output signal using forward implementation') 
%ylim([-10 10])

%subplot(3, 1, 3)
plot(n, x) 
%title('Output signal x using backward implementation') 
xlim([0 ly]);
ylim([-0.5 1.5]);
title('Recovered ECG Signal x')
grid on;

%% Text file (.txt) of my recovered ECG signal x

save('ECG_x.txt', 'x', '-ascii');
