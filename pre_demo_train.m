clc; clear;

fs = 100e3;
N  = 4096;
t  = (0:N-1)/fs;

mods = ["AM","FM","PM","DSBSC","USB","LSB","NOISE"];
X = []; Y = [];

for m = mods
    for k = 1:50
        x = gen_signal(m, fs, t);
        x = add_awgn(x, 12);      % HIGH SNR
        f = extract_features_iq(x, fs);
        X = [X; f];
        Y = [Y; m];
    end
end

Y = categorical(Y);

% --- MANUAL STANDARDIZATION ---
mu = mean(X,1);
sigma = std(X,[],1) + eps;
Xn = (X - mu) ./ sigma;

% --- MULTI-CLASS SVM via ECOC ---
tSVM = templateSVM('KernelFunction','rbf');

SVM = fitcecoc(Xn, Y, ...
    'Learners', tSVM, ...
    'Coding','onevsone');

% --- CROSS VALIDATION ---
CVSVM = crossval(SVM,'KFold',5);
cvLoss = kfoldLoss(CVSVM);
cvAccuracy = (1-cvLoss)*100;

fprintf("Cross-Validated Accuracy: %.2f %%\n", cvAccuracy);

save('AMC_MODEL.mat','SVM','mu','sigma','fs','N','cvAccuracy');