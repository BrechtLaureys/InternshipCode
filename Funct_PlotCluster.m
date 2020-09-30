function Funct_PlotCluster(name_title, Tval_perm, Tval_real, thresh_T)
% Plot the clusters, see if real data is significant

n_bins = 40;

% Histogram of permuted data
hist(Tval_perm,n_bins);
xlabel('Maximum cluster sizes'), ylabel('Number of observations');
title(name_title,'Interpreter','none','FontSize',18);

% Real data
line([Tval_real, Tval_real], ylim, 'LineWidth', 1, 'Color', 'r');

% Threshold
line([thresh_T, thresh_T], ylim, 'LineWidth', 1, 'Color', 'k');

legend('Permuted data','Real data', 'P-value = 0.05')
