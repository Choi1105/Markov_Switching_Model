%% Application 1 : Hamilton's Markov-Switching Model of Business Fluctuations
% Textbook : 78p ~ 81p

% Y(t) = log(y_t) - log(y_t-1) 
% Y(t) - Mu(St) = phi1*(Y(t-1) - Mu(St-1)) + phi2*(Y(t-2) - Mu(St-2))  
% + phi3*(Y(t-3) - Mu(St-3)) + phi4*(Y(t-4) - Mu(St-4)) +  e(t)

% e(t) ~ iidN(0, Sig2)
% Mu(St) = Mu0(St-1) + Mu1(St)

% Pr[St = 1 | St-1 = 1] = p
% Pr[St = 1 | St-1 = 0] = 1 - p
% Pr[St = 0 | St-1 = 0] = q
% Pr[St = 0 | St-1 = 1] = 1 - q

clear;
clc;

%% Step 1: DGP %%
DATA = readmatrix("Data.xlsx" , "Range", "C3:C254");

figure
parcorr(DATA);
hY3 = adftest(DATA,Model="ts",Lags=4);

Ym_New = DATA;
nT = rows(Ym_New);

%% Step 2: Estimation %%
% Data
Y = Ym_New(5:end); 
X = [Ym_New(1:nT-4) Ym_New(2:nT-3) Ym_New(3:nT-2) Ym_New(4:nT-1)]; 
Data = [Y X];
T = rows(X);
k = cols(X);

% initial value 
% Beta1 Beta2 Phi1 Phi2 Phi3 Phi4 Sig2 p0 q0
theta0 = [0.4 ; 2.6 ; 0.16 ;0.1; 0.2 ; 0.2 ; 0.3 ; 0.8 ; 0.8];

% index
index = [1;2;3;4;5;6;7;8;9];
printi = 1;

% Optimization
[thetamx, fmax, Vj, Vinv] = SA_Newton(@lnlik,@paramconst,theta0,Data,printi,index);
[~, Spm] = lnlik(thetamx, Data);


%% Step 3: Results %%
% Date Generate
start_year = 1961;
start_quarter = 2;
end_year = 2023;
end_quarter = 1;

quarters_per_year = 4;
total_years = end_year - start_year;
total_quarters = total_years * quarters_per_year;
ts = datetime(start_year, start_quarter * 3, 1) + calquarters(0:total_quarters-1);

Data = DATA(5:end,1);

% Plot
figure;
yyaxis left;  % 왼쪽 y축 사용
plot(ts, Data, 'color', [0, 0, 1], 'LineWidth', 1);
ylabel('Data', 'FontSize', 12);
ylim([min(Data)-2 max(Data)+2]);  % 데이터에 맞게 y축 범위 설정

yyaxis right;  % 오른쪽 y축 사용
plot(ts, Spm(:, 1), 'r', 'LineWidth', 1);
ylabel('Spm(:,1)', 'FontSize', 12);
ylim([min(Spm(:, 1)) max(Spm(:, 1))+0.1]);  % 데이터에 맞게 y축 범위 설정

xlim([ts(1) ts(end)]);  % x축 범위 설정

% x축 라벨 설정
xtickformat('yyyy-Q1');
xticks(ts(1:quarters_per_year:end));
xtickangle(45);

% 레전드 추가
legend('Data', 'Spm(:,1)', 'FontSize', 12);
 
%% 
MiSpm = Spm(:,1)*(-1);

 % Plot
figure;
yyaxis left;  % 왼쪽 y축 사용
plot(ts, Data, 'color', [0, 0, 1], 'LineWidth', 1);
ylabel('Data', 'FontSize', 12);
ylim([min(Data) max(Data)]);  % 데이터에 맞게 y축 범위 설정

yyaxis right;  % 오른쪽 y축 사용
plot(ts, MiSpm(:, 1), 'r', 'LineWidth', 1);
ylabel('Spm(:,1)', 'FontSize', 12);
ylim([min(MiSpm(:, 1)) max(MiSpm(:, 1))]);  % 데이터에 맞게 y축 범위 설정

xlim([ts(1) ts(end)]);  % x축 범위 설정

% x축 라벨 설정
xtickformat('yyyy-Q1');
xticks(ts(1:quarters_per_year:end));
xtickangle(45);

% 레전드 추가
legend('Data', 'Spm(:,1)', 'FontSize', 12);