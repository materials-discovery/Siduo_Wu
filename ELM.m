clear;
clc;

% load data
load dataset.mat; % reading the data set
load Y.mat;
%split the dataset to a three different input
Input_Data = Dataset

%normalize dataset and save as X
X=normalize(Input_Data,1);

%% split the data for cross-validation
samples4training = round(0.75*size(X,1));
dimension = size(X,2);
samples4testing = size(X,1) - (samples4training);
px = randperm(size(X,1));   %randperm returns a vector with a random permutation of the integers from 1 to n without repeating elements
% Creating matrixes to store training inputs and outputs
data4training = zeros(samples4training,dimension);
label4training = zeros(samples4training,1);
% Creating matrixes to store testing inputs and output
data4testing = zeros(samples4testing,dimension);
label4testing = zeros(samples4testing,1);

%%
% Creating trainning dataset
% initialize the index
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
%%
% Creating testing dataset
% initialize the index
index = 0;
% similar to how the training dataset is created
for k = samples4training + 1:samples4training + samples4testing 
        index = index + 1;
                data4testing(index,:) = X(px(k),1:end);
                label4testing(index,1) = Y(px(k),1);
end
%%
% generating simulated data

Ns=floor(0.75*length(Y))+1;        % first 75% of the data is used for training 

[data4training,mux,sigmax] = zscore(data4training);       % z-score normalization
[label4training,muy,sigmay] = zscore(label4training);

Neurons_HL=200;                              % Neurons in the hidden layer
Input_Features=size(data4training,2);

Inputweights=rand(Neurons_HL,Input_Features)*2-1;               % randomly generated input weights
Bias_HL=rand(Neurons_HL,1);Biasmatrix=Bias_HL(:,ones(1,Ns));    % randomly generated biases

Prod=data4training*Inputweights';
H=Prod+Biasmatrix';                                             % output of the hidden layer

AF='sig';              % chossing activation function
if strcmp(AF,'tanh')
    Hout=tanh(H);
elseif strcmp(AF,'sig')
    Hout=1./(1+exp(-H));
elseif strcmp(AF,'sin')
    Hout=sin(H);
elseif strcmp(AF,'cos')
    Hout=cos(H);
elseif strcmp(AF,'RBF')
    Hout=radbas(H);
elseif strcmp(AF,'tf')
    Hout=tribas(H);
end

type='OT';
if strcmp(type,'MP')
    Hinv=pinv(Hout);
elseif strcmp(type,'RCOD')
    Hinv=RCOD(Hout);
elseif strcmp(type,'OT')
    lambda=10000;
    Hinv=ORT(Hout,lambda);
end

Outputweights=(Hinv)*label4training;
ModelOutputs=Hout*Outputweights;  % ELM outputs predicted on the training dataset
%%
% testing the ELM model

xnew=(data4testing-mux)./sigmax;       % test data is normalized

Prod=Inputweights*xnew';
H=Prod+Bias_HL(:,ones(1,size(xnew,1)));  

if strcmp(AF,'tanh')            % chossing activation function
    Hout=tanh(H);
elseif strcmp(AF,'sig')
    Hout=1./(1+exp(-H));
elseif strcmp(AF,'sin')
    Hout=sin(H);
elseif strcmp(AF,'cos')
    Hout=cos(H);
elseif strcmp(AF,'RBF')
    Hout=radbas(H);
elseif strcmp(AF,'tf')
    Hout=tribas(H);
end

Ypred=Hout'*Outputweights;

ypred=Ypred*sigmay+muy;

R=corr(label4testing,ypred);            %Pearson correlation coefficient
fprintf('R= %4.4f \n',R)

RMSE=sqrt(mean((ypred-label4testing).^2));
fprintf('RMSE= %4.4f \n',RMSE)

figure
plot(label4testing,ypred,'o')
hold on
plot(label4testing,label4testing)
legend('Predictions','Optimal')
ylabel('Predicted Data')
xlabel('Experiment Data')

%% Section to calculate the correlation coefficient for training and testing
% for testing
R2_testing = rsquare(label4testing,ypred)
% 
R2_training=rsquare(label4training,ModelOutputs)

 [R2_training R2_testing];

