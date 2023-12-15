

%% Maximum likelihood estimation
% Non Linear Model
% y(t) = x(t)*B(St) + e(t)
% e(t) ~ N(0,sig2(St))
% B(St) = B0(1-St)+B1(St)
% Sig2
% St = 0 or 1
clear;
clc;
%% Step 1: DGP %%
T = 10000;

St = zeros(T,1);
for v = [1 5 8]
    St(v*1000:(v*1000)+1000,1) = 1;
end

% Sig2
Sig2_1 = 0.1;
Sig2_2 = 0.5;

% Beta_0 and Beta_1
Beta_0 = 1.2;
Beta_1 = 5.9;

Ym = zeros(T,1);
X1m = 5*rand(T,1);
em = zeros(T,1);
emx = randn(T,1);

for t = 1:10000
    em(t) = sqrt(Sig2_1)*emx(t)*(1-St(t)) + sqrt(Sig2_2)*emx(t)*St(t);
end

for t = 1:10000
    Ym(t) = X1m(t)*Beta_0*(1-St(t)) + X1m(t)*Beta_1*St(t) + em(t);
end

%% Step 2: Estimation %%
% Data
Y = Ym; 
X = X1m; 
Data = [Y X];
T = rows(X);
k = cols(X);

% initial value 
theta0 = [0 ; 0 ; 2 ; 2 ];

% index
index = [1;2;3;4];
printi = 1;

% Optimization
[thetamx, fmax, Vj, Vinv] = SA_Newton(@lnlik,@paramconst,theta0,Data,printi,index);

% Compute t-value and p-value
diag_cov = diag(Vj);
stde = sqrt(diag_cov);
t_val = thetamx./stde; 
p_val = 2*(1 - cdf('t', abs(t_val), T-k)); 

%% Step 3: Results %%
disp('=========================================');
disp(['  Estimates ','  t value ', '  p value ']); 
disp('=========================================');
disp([thetamx t_val p_val]); 
disp('=========================================');

          