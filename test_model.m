clc; clear; close all;

%% Load trained model
load trainedAMC_SVM.mat   % contains: SVM, mu, sigma, classNames

fs = 100e3;
N  = 4096;
t  = (0:N-1)/fs;

mods = classNames;
snrSweep = -8:2:-2;    % VERY POOR SNR

Ytrue = [];
Ypred = [];

fprintf("Testing SVM at very low SNR...\n");

for snr = snrSweep
    fprintf("SNR = %d dB\n", snr);
    
    for m = 1:length(mods)
        for k = 1:20
            
            % Generate IQ signal
            if mods(m) == "NOISE"
                x = randn(1,N) + 1j*randn(1,N);
            else
                x = gen_signal(mods(m), fs, t);
                x = awgn(x, snr, 'measured');
            end
            
            % Feature extraction
            f = extract_features_iq(x, fs);
            fn = (f - mu) ./ sigma;
            
            % Prediction
            [label, score] = predict(SVM, fn);
            
            % Confidence-based rejection
            if max(score) < 0.6
                label = "NOISE";
            end
            
            Ytrue = [Ytrue; mods(m)];
            Ypred = [Ypred; label];
        end
    end
end

%% Accuracy
acc = mean(Ytrue == Ypred)*100;
fprintf("\nOverall Low-SNR Accuracy: %.2f %%\n", acc);

%% Confusion Matrix
figure;
confusionchart(Ytrue, Ypred);
title("AMC Confusion Matrix @ Very Low SNR");