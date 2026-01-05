clc; clear;
mods = ["AM","DSBSC","FM","CARRIER","DIGITAL","NOISE","PM"];
X = []; Y = [];
fs_list = [50e3, 100e3, 200e3]; % Varying Sampling Rates

for fs = fs_list
    t = (0:4095)/fs;
    for m = mods
        fprintf("Training %s at fs=%.0f...\n", m, fs);
        for k = 1:500 % High volume for variety
            x = gen_signal(m, fs, t);
            
            % FOCUS on the 0-10dB region specifically
            if m ~= "NOISE"
                snr_train = 0 + 15*rand(); % Random SNR between 0 and 15 dB
                x = add_awgn(x, snr_train);
            end
            
            f = extract_features_iq(x, fs, 1);
            X = [X; f];
            Y = [Y; m];
        end
    end
end

% Manual Standardization
Y = categorical(Y);
mu = mean(X, 1); sigma = std(X, [], 1) + eps;
Xn = (X - mu) ./ sigma;

% Use a weighted RBF SVM for better low-SNR boundaries
tSVM = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto');
SVM = fitcecoc(Xn, Y, 'Learners', tSVM, 'Coding', 'onevsall');

save('AMC_MODEL.mat', 'SVM', 'mu', 'sigma');
