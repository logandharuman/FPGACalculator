clc; clear;

model = load_model();

data = readmatrix('logged_iq.csv');

if size(data,2) == 2
    I = data(:,1);
    Q = data(:,2);
    x = I + 1j*Q;
    iqMode = true;
else
    x = data(:,1);
    iqMode = false;
end

fs = 100e3;   % operator-provided or metadata

run_pipeline(x, fs, model, iqMode);