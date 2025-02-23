%% Basic variables
map = 'C:\Users\brech\OneDrive\Documenten\Ugent\EXAMPLE__UNFOLD_LaserHEP'; %Change to your map
cd 'C:\Users\brech\OneDrive\Documenten\Ugent\EXAMPLE__UNFOLD_LaserHEP' %Change to your map
sub_list = [1:10];

%% Load data
for i_sub = sub_list % Load seperate data in single dataset
i_string = num2str(i_sub);

load(['EEG_S' i_string '.mat']);
EEG_start(i_sub) = EEG;
end

%% Identify R-peak latencies
for i_sub = sub_list
i_string = num2str(i_sub);

EEG = EEG_start(i_sub)
[EEG_Rpeaks(i_sub)] = Funct__Find_RPeaks(EEG, 32, map, ['remove' i_string '.set']);
end

%% ICA
for i_sub = sub_list 
EEG_ICA(i_sub) = pop_runica(EEG_Rpeaks(i_sub), 'icatype', 'runica', 'extended',1,'interrupt','on');
end

%% SASICA and EEG_withCFA & EEG_noCFA
for i_sub = sub_list 
EEG = EEG_ICA(i_sub);
[EEG_withCFA(i_sub) EEG_noCFA(i_sub)] = Funct__RemoveArtifacts(EEG) 
end

%% ERPs: normal ERPs & UNFOLD ERPs
for i_sub = sub_list
[L_CFA1_DEC0(i_sub,:) R_CFA1_DEC0(i_sub,:) L_CFA1_DEC1(i_sub,:) R_CFA1_DEC1(i_sub,:)] = Funct__CalculateERP(EEG_withCFA(i_sub), -0.4, 1, 11);
end

for i_sub = sub_list 
[L_CFA0_DEC0(i_sub,:) R_CFA0_DEC0(i_sub,:) L_CFA0_DEC1(i_sub,:) R_CFA0_DEC1(i_sub,:)] = Funct__CalculateERP(EEG_noCFA(i_sub), -0.4, 1, 11);
end

%% Example Research question 1: compare normal ERPs with UNFOLD ERPs
% Datasets for comparison
RQ1_Laser(1,:,:) = L_CFA1_DEC0;
RQ1_Laser(2,:,:) = L_CFA1_DEC1;

RQ1_Rpeak(1,:,:) = R_CFA1_DEC0;
RQ1_Rpeak(2,:,:) = R_CFA1_DEC1;

% Permutations
n_perm = 1000;

[RQ1_Laser_perm] = Funct__Permutation(RQ1_Laser, n_perm);
[RQ1_Rpeak_perm] = Funct__Permutation(RQ1_Rpeak, n_perm);

% Cluster calculation for real data
pval = 0.05;

[Tval_real_Laser MaxCluster_real_Laser] = Funct_TvalueMaxCluster(RQ1_Laser, pval);
[Tval_real_Rpeak MaxCluster_real_Rpeak] = Funct_TvalueMaxCluster(RQ1_Rpeak, pval);

% Cluster calculation for permutation data
for i_perm = 1:n_perm
[Tval_perm_Laser(i_perm) MaxCluster_perm_Laser(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ1_Laser_perm(i_perm,:,:,:)), pval);
[Tval_perm_Rpeak(i_perm) MaxCluster_perm_Rpeak(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ1_Rpeak_perm(i_perm,:,:,:)), pval);
end

% Cluster significance
thresh_T_Laser = prctile(Tval_perm_Laser,100-(100*pval));
thresh_T_Rpeak = prctile(Tval_perm_Rpeak,100-(100*pval));

figure(1);
Funct_PlotCluster('Laser', Tval_perm_Laser, Tval_real_Laser, thresh_T_Laser)
figure(2);
Funct_PlotCluster('Rpeak', Tval_perm_Rpeak, Tval_real_Rpeak, thresh_T_Rpeak)

%% Example Research question 2: compare normal ERPs with UNFOLD ERPs after CFA removal
% Datasets for comparison
RQ2_Laser(1,:,:) = L_CFA0_DEC0;
RQ2_Laser(2,:,:) = L_CFA0_DEC1;

RQ2_Rpeak(1,:,:) = R_CFA0_DEC0;
RQ2_Rpeak(2,:,:) = R_CFA0_DEC1;

% Permutations
n_perm = 100;

[RQ2_Laser_perm] = Funct__Permutation(RQ2_Laser, n_perm);
[RQ2_Rpeak_perm] = Funct__Permutation(RQ2_Rpeak, n_perm);

% Cluster calculation for real data
pval = 0.05;

[Tval_real_Laser MaxCluster_real_Laser] = Funct_TvalueMaxCluster(RQ2_Laser, pval);
[Tval_real_Rpeak MaxCluster_real_Rpeak] = Funct_TvalueMaxCluster(RQ2_Rpeak, pval);

% Cluster calculation for permutation data
for i_perm = 1:n_perm
[Tval_perm_Laser(i_perm) MaxCluster_perm_Laser(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ2_Laser_perm(i_perm,:,:,:)), pval);
[Tval_perm_Rpeak(i_perm) MaxCluster_perm_Rpeak(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ2_Rpeak_perm(i_perm,:,:,:)), pval);
end

% Cluster significance
thresh_T_Laser = prctile(Tval_perm_Laser,100-(100*pval));
thresh_T_Rpeak = prctile(Tval_perm_Rpeak,100-(100*pval));

figure(3);
Funct_PlotCluster('Laser', Tval_perm_Laser, Tval_real_Laser, thresh_T_Laser)
figure(4);
Funct_PlotCluster('Rpeak', Tval_perm_Rpeak, Tval_real_Rpeak, thresh_T_Rpeak)

%% Example Research question 3: compare UNFOLD ERPs before & after CFA removal
% Datasets for comparison
RQ3_Laser(1,:,:) = L_CFA0_DEC1;
RQ3_Laser(2,:,:) = L_CFA1_DEC1;

RQ3_Rpeak(1,:,:) = R_CFA0_DEC1;
RQ3_Rpeak(2,:,:) = R_CFA1_DEC1;

% Permutations
n_perm = 100;

[RQ3_Laser_perm] = Funct__Permutation(RQ3_Laser, n_perm);
[RQ3_Rpeak_perm] = Funct__Permutation(RQ3_Rpeak, n_perm);

% Cluster calculation for real data
pval = 0.05;

[Tval_real_Laser MaxCluster_real_Laser] = Funct_TvalueMaxCluster(RQ3_Laser, pval);
[Tval_real_Rpeak MaxCluster_real_Rpeak] = Funct_TvalueMaxCluster(RQ3_Rpeak, pval);

% Cluster calculation for permutation data
for i_perm = 1:n_perm
[Tval_perm_Laser(i_perm) MaxCluster_perm_Laser(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ2_Laser_perm(i_perm,:,:,:)), pval);
[Tval_perm_Rpeak(i_perm) MaxCluster_perm_Rpeak(i_perm,:)] = Funct_TvalueMaxCluster(squeeze(RQ2_Rpeak_perm(i_perm,:,:,:)), pval);
end

% Cluster significance
thresh_T_Laser = prctile(Tval_perm_Laser,100-(100*pval));
thresh_T_Rpeak = prctile(Tval_perm_Rpeak,100-(100*pval));

figure(5);
Funct_PlotCluster('Laser', Tval_perm_Laser, Tval_real_Laser, thresh_T_Laser)
figure(6);
Funct_PlotCluster('Rpeak', Tval_perm_Rpeak, Tval_real_Rpeak, thresh_T_Rpeak)
