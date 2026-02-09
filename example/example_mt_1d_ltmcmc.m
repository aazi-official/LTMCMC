clc; clear; close all;

thisFileDir = fileparts(mfilename('fullpath'));
srcDir = fullfile(thisFileDir, '..', 'src');
addpath(genpath(srcDir));

%%%
num_layers = 5; 
%%%
sigma_res = 0.1;
sigma_phase = 0.01;
NumFreq = 50;    
frequency = logspace(-3, 2, NumFreq); 

res_true = [500, 1000, 100, 500, 1000, 200]; 
thickness_true = [210, 1624, 1346, 1435, 1800];  

[AppRes_obs, Phase_obs] = deal(zeros(NumFreq, 1));
for j = 1:NumFreq
    [tmp1, tmp2, ~] = MTmodeling1D(res_true, thickness_true, frequency(j));
    AppRes_obs(j) = tmp1 * (1 + randn * sigma_res);  
    Phase_obs(j) = tmp2 * (1 + randn * sigma_phase); 
end

disp('AppRes_obs:');
disp(AppRes_obs);
disp('Phase_obs:');
disp(Phase_obs);
disp('Frequency:');
disp(frequency);

sigma_res1 = 5;
sigma_phase1 = 5;

priorpdf = @(theta) double(all([ ...
    theta(1) > 200 && theta(1) < 700, ...
    theta(2) > 500 && theta(2) < 1500, ...
    theta(3) > 50  && theta(3) < 550, ...
    theta(4) > 100 && theta(4) < 600, ...
    theta(5) > 500 && theta(5) < 1500, ...
    theta(6) > 10  && theta(6) < 510, ...
    theta(7) > 100 && theta(7) < 2100, ...
    theta(8) > 100 && theta(8) < 2100, ...
    theta(9) > 100 && theta(9) < 2100, ...
    theta(10) > 100 && theta(10) < 2100, ...
    theta(11) > 100 && theta(11) < 2100 ...
]));


priorrnd = @(n) [ ...
    rand(n, 1) * 500 + 200,  ...   % theta(1)
    rand(n, 1) * 1000 + 500, ...   % theta(2)
    rand(n, 1) * 500 + 50,   ...   % theta(3)
    rand(n, 1) * 500 + 100,  ...   % theta(4)
    rand(n, 1) * 1000 + 500, ...   % theta(5)
    rand(n, 1) * 500 + 10,   ...   % theta(6)
    rand(n, 1) * 2000 + 100, ...   % theta(7)
    rand(n, 1) * 2000 + 100, ...   % theta(8)
    rand(n, 1) * 2000 + 100, ...   % theta(9)
    rand(n, 1) * 2000 + 100, ...   % theta(10)
    rand(n, 1) * 2000 + 100];      % theta(11)
   

loglikelihood_handle = @(theta) loglikelihood(theta, AppRes_obs, Phase_obs, frequency, sigma_res1, sigma_phase1, num_layers, NumFreq);



fprintf('Running Langevin TMCMC...\n');
tic;
output_langevin1 = ltmcmc_solver_par('nsamples', 50000, ...
                             'loglikelihood', loglikelihood_handle, ...
                             'priorpdf', priorpdf, ...
                             'priorrnd', priorrnd, ...
                             'burnin', 20, ...
                             'epsilon', 0.1);
time_ltmcmc = toc;

%samples_langevin3 = output_langevin1.samples;
save('output_langevin5000', 'output_langevin1');
save('time_ltmcmc5000', 'time_ltmcmc');
% 


function loglike = loglikelihood(theta, AppRes_obs, Phase_obs, frequency, sigma_res1, sigma_phase1, num_layers, NumFreq)
    misfit_res = zeros(NumFreq, 1);
    misfit_phase = zeros(NumFreq, 1);

    for j = 1:NumFreq
        [tmp_res, tmp_phase, ~] = MTmodeling1D(theta(1:num_layers), theta(num_layers+1:end), frequency(j));
        misfit_res(j) = (AppRes_obs(j) - tmp_res) / sigma_res1;
        misfit_phase(j) = (Phase_obs(j) - tmp_phase) / sigma_phase1;
    end

    loglike = -0.5 * (norm(misfit_res)^2 + norm(misfit_phase)^2);
end
