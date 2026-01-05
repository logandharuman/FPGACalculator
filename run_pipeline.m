function run_pipeline(x, fs, modelData, iqMode)

if nargin < 4
    iqMode = ~isreal(x);
end

model = modelData.SVM;
mu    = modelData.mu;
sigma = modelData.sigma;

[isDigital, digScore] = digital_predetector_iq(x, fs, iqMode);

if isDigital
    fprintf("DIGITAL-like detected | Score %.2f\n", digScore);
    return;
end

f = extract_features_iq(x, fs, iqMode);
fn = (f - mu) ./ sigma;

[label, score] = predict(model, fn);

conf = max(abs(score));

fprintf("Detected: %s | Confidence: %.2f\n", string(label), conf);

decision_logic(label, conf);
end