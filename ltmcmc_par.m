function [output] = ltmcmc_par(varargin)
% Transitional Markov Chain Monte Carlo sampler with Langevin MCMC
% -------------------------------------------------------------------------
% This program implements a gradient-based variant of the Transitional
% Markov Chain Monte Carlo (TMCMC) method originally proposed in:
%
%   Ching, J. and Chen, Y. (2007). "Transitional Markov Chain Monte Carlo
%   Method for Bayesian Model Updating, Model Class Selection, and Model
%   Averaging." J. Eng. Mech., 133(7), 816-832.
%
% In this implementation, the proposal mechanism is extended using 
% Langevin dynamics to accelerate convergence by leveraging gradient 
% information from the posterior distribution. The resulting algorithm is 
% referred to as Langevin Transitional MCMC (L-TMCMC).
%
% Compared to standard TMCMC, L-TMCMC updates samples at each transition
% stage using a modified Langevin-type proposal:
%
%     θ_new = θ_old + (ε^2 / 2) ∇logπ(θ_old) + ε * N(0, I)
%
% where ∇logπ(θ) is the gradient of the tempered log-posterior, and ε is 
% the Langevin step size.
%
% -------------------------------------------------------------------------
% Usage:
%   output = ltmcmc_par('nsamples', N, ...
%                       'loglikelihood', loglik, ...
%                       'priorpdf', priorpdf, ...
%                       'priorrnd', priorrnd, ...
%                       'burnin', M, ...
%                       'epsilon', eps);
%
% Inputs:
%   nsamples      – Number of samples per transitional stage
%   loglikelihood – Function handle for log-likelihood
%   priorpdf      – Function handle for prior PDF
%   priorrnd      – Function to draw samples from the prior
%   burnin        – Number of samples to estimate covariance at each stage
%   epsilon       – Langevin proposal step size (controls gradient weight)
%
% Outputs:
%   output.samples      – Samples from posterior
%   output.log_evidence – Estimated log model evidence
%   output.beta         – Sequence of β_j values (tempering schedule)
%
% -------------------------------------------------------------------------
% Authors and Contributions:
%   Diego Andres Alvarez   Jul-24-2013   – Original TMCMC framework
%   Ziang Zhang            Jan-01-2024   – Extended with Langevin proposal
%   and paralleling.
%
% Contact:
%   Original: daalvarez@unal.edu.co
%   Modified: zzhang88@cougarnet.uh.edu
%
% -------------------------------------------------------------------------

% Parse the information in the name/value pairs
pnames = {'nsamples', 'loglikelihood', 'priorpdf', 'priorrnd', 'burnin', 'lastburnin', 'beta','epsilon'};
dflts = {[], [], [], [], 0, 0, 0.2,0.01}; % Define default values
[nsamples, loglikelihood, priorpdf, priorrnd, burnin, lastBurnin, beta,epsilon] = ...
    internal.stats.parseArgs(pnames, dflts, varargin{:});
%% Number of cores
if ~isempty(gcp('nocreate'))
    pool = gcp;
    Ncores = pool.NumWorkers;
    fprintf('TMCMC is running on %d cores.\n', Ncores);
end
%% Initialization
j = 0;  % Transitional likelihood iteration counter
thetaj = priorrnd(nsamples); % Initial samples from prior
pj = 0; % Initial tempering parameter
Dimensions = size(thetaj, 2); % Dimensionality of samples

count = 1; % Counter
samps(:, :, count) = thetaj;
beta_j(count) = pj;
beta = 2.4./sqrt(Dimensions);
scale(count) = beta;
posterior_means_per_stage = [];

%% Main loop
while pj < 1
    j = j + 1;
    
    % Compute log-likelihoods for current samples
    log_fD_T_thetaj = zeros(nsamples, 1);
 parfor l = 1:nsamples
    log_fD_T_thetaj(l) = loglikelihood(thetaj(l, :));
    if isnan(log_fD_T_thetaj(l)) || isinf(log_fD_T_thetaj(l))
        log_fD_T_thetaj(l) = -1e10
    end
end

    
    % Compute new tempering parameter
    pj1 = calculate_pj1(log_fD_T_thetaj, pj);
    fprintf('TMCMC: Iteration j = %2d, pj1 = %f\n', j, pj1);
    
    % Compute weights
    a = (pj1 - pj) * log_fD_T_thetaj;
    wj = exp(a);
    wj_norm = wj ./ sum(wj);% Normalize weights
    
    % Resample and Langevin MCMC updates
    fprintf('Markov chains with Langevin MCMC ...\n');
    idx = randsample(nsamples, nsamples, true, wj_norm);
    % mu = zeros(1, Dimensions);
    % parfor l = 1:nsamples
    %     mu = mu + wj_norm(l)*thetaj(l,:);
    % end
    % 
    % cov_gauss = zeros(Dimensions);
    % parfor k = 1:nsamples
    %     tk_mu = thetaj(k,:) - mu;
    %     cov_gauss = cov_gauss + wj_norm(k)*(tk_mu'*tk_mu);
    % end
    % cov_gauss = beta^2 * cov_gauss + 1e-10*eye(size(cov_gauss));
    thetaj1 = zeros(nsamples, Dimensions);
    parfor i = 1:nsamples
        weight_current=1;
        x_current = thetaj(idx(i), :);
        % if wj_norm(i)>1/nsamples
        %     weight_current=weight_current*0.9;
        % elseif wj_norm(i)<1/nsamples
        %     weight_current=weight_current*1.5;
        % end
        %weight_current = 1/sqrt(wj_norm(idx(i)));
  
        for k = 1:burnin
            % Compute gradient of log posterior
            grad = log_posterior_grad(x_current, priorpdf, loglikelihood, pj1);

            % Langevin MCMC update
            %noise = sqrt(epsilon) * randn(size(x_current))*sqrt(cov_gauss);
            noise = sqrt(epsilon) * randn(size(x_current));
            x_proposed = x_current + weight_current*(epsilon / 2) * grad + noise;

            % Compute acceptance probability
            log_post_current = log_posterior(x_current, priorpdf, loglikelihood, pj1);
            log_post_proposed = log_posterior(x_proposed, priorpdf, loglikelihood, pj1);
            log_acceptance = log_post_proposed - log_post_current;

            % Accept/reject step
            if log(rand) < log_acceptance
                x_current = x_proposed; % Accept the proposal
            end
        end
        thetaj1(i, :) = x_current; % Save the final sample
    end

    % Prepare for next iteration
    count = count + 1;
    samps(:, :, count) = thetaj1;
    thetaj = thetaj1;
    pj = pj1;
    beta_j(count) = pj;

% acceptance = zeros(1, nsamples); % 每次迭代的接受率
% 
% 
% parfor i = 1:nsamples
%     x_current = thetaj(idx(i), :);
%     local_accept_count = 0; % 当前样本的接受计数
% 
%     for k = 1:burnin
%         % Compute gradient of log posterior
%         grad = log_posterior_grad(x_current, priorpdf, loglikelihood, pj1);
% 
%         % Langevin MCMC update
%         noise = sqrt(epsilon) * randn(size(x_current)) * sqrt(cov_gauss);
%         x_proposed = x_current + (epsilon / 2) * grad + noise;
% 
%         % Compute acceptance probability
%         log_post_current = log_posterior(x_current, priorpdf, loglikelihood, pj1);
%         log_post_proposed = log_posterior(x_proposed, priorpdf, loglikelihood, pj1);
%         log_acceptance = log_post_proposed - log_post_current;
% 
%         % Accept/reject step
%         if log(rand) < log_acceptance
%             x_current = x_proposed; % Accept the proposal
%             local_accept_count = local_accept_count + 1; 
%         end
%     end
%     thetaj1(i, :) = x_current; % Save the final sample
%     acceptance(i) = local_accept_count/burnin ; 
% end
% 
% % Prepare for next iteration
% acceptance_rate = mean(acceptance); % 当前迭代的平均接受率
% target_acceptance = 0.21 / Dimensions + 0.23; % 目标接受率
% c_a = (acceptance_rate - target_acceptance) / sqrt(j);% 调整系数
% beta = beta * exp(c_a); % 更新 beta
% scale(count) = beta; % 保存 beta 的值

% count = count + 1;
% samps(:, :, count) = thetaj1;
% thetaj = thetaj1;
% pj = pj1;
% beta_j(count) = pj;
% 
    posterior_samples{j} = thetaj; 
    posterior_probs{j} = arrayfun(@(l) log(priorpdf(thetaj(l, :))) + pj1 * loglikelihood(thetaj(l, :)), 1:nsamples);
    posterior_mean{j} = mean(arrayfun(@(l) log(priorpdf(thetaj(l, :))) + pj1 * loglikelihood(thetaj(l, :)), 1:nsamples));
    posterior_means_per_stage = [posterior_means_per_stage, posterior_mean];
end

% Final outputs
output.allsamples = samps;
output.samples = samps(:, :, end);
output.beta = beta_j;

output.posterior_samples = posterior_samples;
output.posterior_probs = posterior_probs;     
output.posterior_mean = posterior_mean;
output.posterior_means_per_stage = posterior_means_per_stage;

end







%% Gradient of log posterior
function grad = log_posterior_grad(t, priorpdf, loglikelihood, pj1)
    delta = 1e-6;
    grad = zeros(size(t));
    for d = 1:numel(t)
        t_forward = t; t_backward = t;
        t_forward(d) = t_forward(d) + delta;
        t_backward(d) = t_backward(d) - delta;
        grad(d) = (log(priorpdf(t_forward)) + pj1 * loglikelihood(t_forward) ...
                 - log(priorpdf(t_backward)) - pj1 * loglikelihood(t_backward)) / (2 * delta);
    end
end

%%% Maybe can try in higher dimensionall
% function grad = log_posterior_grad(t, priorpdf, loglikelihood, pj1)
% 
%     t_ad = myAD(t); 
% 
% 
%     posterior = @(x) log(priorpdf(x)) + pj1 * loglikelihood(x);
% 
% 
%     y = posterior(t_ad);
% 
% 
%     grad = getderivs(y);
% end


%% Log posterior
function logpost = log_posterior(t, priorpdf, loglikelihood, pj1)
    logpost = log(priorpdf(t)) + pj1 * loglikelihood(t);
end

%% Calculate the tempering parameter p(j+1)
function pj1 = calculate_pj1(log_fD_T_thetaj, pj)
    threshold = 1; % Coefficient of variation threshold
    wj = @(e) exp(abs(e) * log_fD_T_thetaj);
    fmin = @(e) std(wj(e)) - threshold * mean(wj(e)) + realmin;
    e = abs(fzero(fmin, 0));
    pj1 = min(1, pj + e);
end
