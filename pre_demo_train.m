clc; clear;

fs = 100e3;
N  = 4096;
t  = (0:N-1)/fs;

mods = ["AM","FM","PM","DSBSC","USB","LSB","NOISE"];
X = []; Y = [];

for m = mods
    for k = 1:50
        x = gen_signal(m, fs, t);
        x = add_awgn(x, 12);      % HIGH SNR TRAINING
        f = extract_features_iq(x, fs);
        X = [X; f];
        Y = [Y; m];
    end
end

% Train base SVM
SVM = fitcsvm(X,Y,...
    'KernelFunction','rbf',...
    'Standardize',true);

% --- CROSS VALIDATION ---
CVSVM = crossval(SVM,'KFold',5);
cvLoss = kfoldLoss(CVSVM);
cvAccuracy = (1 - cvLoss)*100;

fprintf("\n📊 Cross-Validated Accuracy: %.2f %%\n", cvAccuracy);

% --- CONFUSION MATRIX ---
pred = kfoldPredict(CVSVM);
confMat = confusionmat(Y,pred);

disp("Confusion Matrix:");
disp(confMat);

save('AMC_MODEL.mat','SVM','fs','N','cvAccuracy','confMat');