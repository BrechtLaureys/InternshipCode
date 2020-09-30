%% Description:
% input: dataset (conditions * subjects * samples), p-value
% output: summed T-values for max. significant cluster

function [TvalueMaxCluster only_MaxCluster] = Funct_TvalueMaxCluster(dataset, pval)

% Define variables
n_cond = size(dataset,1);
n_sub = size(dataset,2);
n_samples = size(dataset,3);

% % % Plot conditions
% % for i_cond = 1:n_cond
% %     for i_sub = 1:n_sub
% %     figure(i_cond);
% %     plot(squeeze(RQ1_Rpeak(i_cond,i_sub,:))); hold on;
% %     end
% % end

% % % Define arrays
% % diff_conditions_sub = NaN(n_sub, n_samples);
% % diff_conditions = NaN(1,n_samples);
% % std_diff = NaN(1,n_samples);
% % std_error = NaN(1,n_samples);
% % T_values = NaN(1,n_samples);

% Calculate variables for T-tests 
for i_sub = 1:n_sub
diff_conditions_sub(i_sub,:) = dataset(1,i_sub,:) - dataset(2,i_sub,:);
end

% % % plot
% % clf
% % for i_sub = 1:20
% %     plot(diff_conditions_sub(i_sub,:)); hold on;
% % end

diff_conditions = squeeze(mean(diff_conditions_sub,1));

% % Plot 
% plot(diff_conditions);


total_mean = squeeze(mean(diff_conditions,2));
total_std = std(abs(diff_conditions));

%% T test (H0: mean = 0, std = std of diff_conditions) + Tvalue Threshold
% Take the T-value as threshold do calculate significant cluster

% T test
signif_ttest = ttest(diff_conditions);

% Calculate threshold
mean_h0 = 0;
T_threshold = norminv([pval 1-pval],mean_h0,total_std);


%% T values for each sample of mean difference

% Calculate T-values
for i_sample = 1:n_samples
    T_values(i_sample) = diff_conditions(i_sample) / (total_std / sqrt(n_sub));
end


%% Find max significant cluster

% Threshold at p-value, by setting subthreshold values to 0
for i_sample = 1:n_samples
    if diff_conditions(i_sample) > T_threshold(1) & diff_conditions(i_sample) < T_threshold(2)
        thresh_diff_conditions(i_sample) = 0;
    else
        thresh_diff_conditions(i_sample) = diff_conditions(i_sample);
    end
end
 

% Find biggest cluster
signif_clusters = bwconncomp(thresh_diff_conditions);

if numel(signif_clusters.PixelIdxList)>0
    
    % Count sizes of clusters
    tempclustsizes = cellfun(@length,signif_clusters.PixelIdxList);
    
    % Store biggest cluster --> size, number, x-values
    [max_cluster_size which_cluster] = max(tempclustsizes);
    xval_cluster = squeeze(signif_clusters.PixelIdxList{which_cluster});
    xval_cluster = xval_cluster';
    
    % Data with only max cluster
    for i_sample = 1:n_samples
        if any(xval_cluster(:) == i_sample)
            only_MaxCluster(i_sample) = diff_conditions(i_sample);
        else
            only_MaxCluster(i_sample) = 0;
        end
    end
        
    % Calculate T value sum of cluster
    cluster_Tvalues = T_values(xval_cluster);
    TvalueMaxCluster = sum(abs(cluster_Tvalues));  
else
    TvalueMaxCluster = 0;
    only_MaxCluster = zeros(1,n_samples);
end

% % %% Plot
% % 
% % for i_plot = 2
% % close all;
% % figure(i_plot); subplot(3,1,1);
% % title('mean_diff');
% % 
% % hold on;plot(1:n_samples,thresh_diff_conditions);
% % y1 = T_threshold(1);
% % y2 = T_threshold(2);
% % line([0,n_samples],[y1,y1])
% % line([0,n_samples],[y2,y2])
% % 
% % subplot(3,1,2);
% % plot(T_values);
% % title('T values');
% % 
% % subplot(3,1,3);
% % plot(only_MaxCluster);
% % title('Max Cluster');
% % end
