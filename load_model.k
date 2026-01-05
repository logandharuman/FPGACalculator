function model = load_model()
data = load('AMC_MODEL.mat');
model = data.SVM;
end