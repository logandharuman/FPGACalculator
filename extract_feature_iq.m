function f = extract_features_iq(x, fs, iqMode)
    x = x(:).'; 
    if ~iqMode || isreal(x), x = hilbert(x); end
    x = x / (sqrt(mean(abs(x).^2)) + eps);
    env = abs(x);
    
    % 1. DSB-SC vs PM Identifier: Variance of squared envelope
    % DSB-SC envelope fluctuates heavily; PM is near constant
    gamma_env = var(env.^2) / (mean(env.^2)^2 + eps);

    % 2. Frequency/Phase Jitter
    inst_freq = [0, diff(unwrap(angle(x)))];
    std_freq = std(inst_freq);
    kurt_freq = kurtosis(inst_freq);

    % 3. HOS for Digital/Noise robustness
    m20 = mean(x.^2); m21 = mean(abs(x).^2); m42 = mean(abs(x).^4);
    C42 = abs(m42 - abs(m20)^2 - 2*m21^2);
    q_c42 = C42 / (m21^2 + eps); 

    % 4. Spectral "Peak-to-Average" (Carrier vs FM)
    X_fft = abs(fft(x, 1024));
    sfm = geomean(X_fft+eps) / mean(X_fft+eps); % Spectral Flatness

    f = [gamma_env, std_freq, kurt_freq, q_c42, sfm];
end
