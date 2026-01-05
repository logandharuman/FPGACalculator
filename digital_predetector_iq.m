function [isDigital, score] = digital_predetector_iq(x, fs, iqMode)

if iqMode
    env = abs(x);
else
    env = abs(hilbert(x));
end

p = histcounts(env,20,'Normalization','probability');
entropy_env = -sum(p.*log2(p+eps));

[r,lags] = xcorr(real(x),'coeff');
peak_ratio = max(r(lags~=0));

env_var = var(env);

T_entropy = 2.8;
T_peak    = 0.12;
T_var     = 0.06;

isDigital = entropy_env < T_entropy && ...
            peak_ratio > T_peak && ...
            env_var < T_var;

score = max(0,min(1,(T_entropy-entropy_env)/T_entropy));
end