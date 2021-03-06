clear;
clc;

% read the dataset
inputdata = readmatrix('Dataset.csv');
X = normalize(inputdata, 1);
Y = readmatrix('Target.csv');
% read the dataset

% split the data for cross-validation
samples4training = round(0.8*size(X,1));
dimension = size(X,2);
samples4testing = size(X,1) - (samples4training);
px = randperm(size(X,1));   %randperm returns a vector with a random permutation of the integers from 1 to n without repeating elements
% Creating matrixes to store training inputs and outputs
data4training = zeros(samples4training,dimension);
label4training = zeros(samples4training,1);
% Creating matrixes to store testing inputs and output
data4testing = zeros(samples4testing,dimension);
label4testing = zeros(samples4testing,1);

% Creating trainning dataset, initialize the index
index = 0;
% main loop creating training datasets
for k = 1:samples4training
         index = index + 1;
         data4training(index,:) = X(px(k),1:end);
         label4training(index,1) = Y(px(k),1);
% px is a vector containing a random permutation of the integers from 1 to n without repeating elements
% px here is used to randomize the sequence of the data
% no repeting elements is important
end

% Creating testing dataset
% initialize the index
index = 0;
% similar to how the training dataset is created
for k = samples4training + 1:samples4training + samples4testing 
        index = index + 1;
                data4testing(index,:) = X(px(k),1:end);
                label4testing(index,1) = Y(px(k),1);
end

% train the model
mdl = fitrsvm(data4training, label4training,'KernelFunction','rbf');

Yfit = predict(mdl, data4testing);

plot(label4testing,Yfit,'o');
hold on
plot(label4testing,label4testing);
ylabel('Predicted Data')
xlabel('Experiment Data')

RMSE = sqrt(mean((Yfit-label4testing).^2));

r = label4testing-Yfit;
 normr = norm(r);
 SSE = normr.^2;
 SST = norm(label4testing-mean(label4testing))^2;
 Rsqr = 1 - SSE/SST;

 RMSE
 Rsqr
