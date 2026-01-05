function run_pipeline(x, fs, model, iqMode)

if nargin < 4
    iqMode = isreal(x) == 0;
end

[xDigital, digScore] = digital_predetector_iq(x, fs, iqMode);

if xDigital
    fprintf("DIGITAL-like signal detected | Score %.2f\n", digScore);
    return;
end

f = extract_features_iq(x, fs, iqMode);
[label, score] = predict(model, f);

confidence = max(abs(score));

fprintf("Detected: %s | Confidence: %.2f\n", label, confidence);

decision_logic(label, confidence);
end