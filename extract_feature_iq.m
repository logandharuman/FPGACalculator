function f = extract_features_iq(x, fs, iqMode)

if iqMode
    env = abs(x);
    phase = unwrap(angle(x));
    inst_freq = diff(phase);
else
    env = abs(hilbert(x));
    inst_freq = diff(angle(hilbert(x)));
end

env_var = var(env);
freq_var = var(inst_freq);

zcr = sum(abs(diff(sign(real(x)))))/length(x);

X = abs(fft(real(x)));
X = X(1:end/2);
X = X / sum(X);

freq = linspace(0, fs/2, length(X));
centroid = sum(freq .* X);

flatness = geomean(X+eps)/mean(X+eps);

kurt = kurtosis(real(x));

f = [env_var freq_var zcr centroid flatness kurt];
end