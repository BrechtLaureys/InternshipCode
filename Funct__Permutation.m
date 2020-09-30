%% Description:
% input: dataset (conditions * subjects * samples), number of permutations
% output: permuted dataset (number of permutations * conditions * subjects * samples)

function [permuted_data] = Funct__Permutation(dataset, n_perm)

% Define variables
n_cond = size(dataset,1);
n_sub = size(dataset,2);
n_samples = size(dataset,3);

% Create permuted dataset array
permuted_data = NaN(n_perm, n_cond, n_sub, n_samples);

for i_perm = 1:n_perm % for each permutation
    for i_sub = 1:n_sub % for each subject
        rand_cond = randperm(n_cond,n_cond);
        for i_cond = 1:n_cond
            permuted_data(i_perm, i_cond, i_sub, :) = dataset(rand_cond(i_cond),i_sub,:);
        end
    end  
end

% % %     Comment: Plot to check
% %     clf;
% %     for i_perm = 1:n_perm
% %         diff_cond = squeeze(mean(permuted_data(i_perm, 1, :, :))-mean(permuted_data(i_perm, 2, :, :)));
% %         figure(1); plot(1:n_samples,diff_cond);hold on;
% %     end
% % 
% %     