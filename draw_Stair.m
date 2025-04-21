%%%%%%%%plot fig3%%%%%%%%%%%%%%%%%%%%
load('D:\desktop\MT\MT forward\data\types\5_05.mat')
data =output_langevin.samples;

rh_q05 = quantile(data(:, 1:6), 0.05);
rh_q95 = quantile(data(:, 1:6), 0.95);

thickness_q05 = quantile(data(:, 7:end), 0.05);
thickness_q95 = quantile(data(:, 7:end), 0.95);

mean2 = mean(data);

%-----------------------------------------------------------------
result = [500, 1000, 100, 500, 1000, 200, 210, 1624, 1346, 1435, 1800];  

rh = [500, 1000, 100, 500, 1000, 200];
thickness = [-210, -1624, -1346, -1435, -1800, -Inf]; 

rh_result = result(1:6); 
thickness_result = [-result(7:end), -10000]; 

rh_mean2 = mean2(1:6); 
thickness_mean2 = [-mean2(7:end), -10000]; 

%-------------------------------------------------------
rh_lower = rh_q05;
rh_upper = rh_q95;

thickness_upper_bound = -thickness_q05; 
thickness_lower_bound = -thickness_q95;  

thickness_upper = [thickness_upper_bound, -1000000];
thickness_lower = [thickness_lower_bound, -1000000];


thickness_stairs_result = repelem(thickness_result, 2);
thickness_stairs_result = thickness_stairs_result(1:end-1);
thickness_stairs_result = [0, thickness_stairs_result];
for i = 2:5
    thickness_stairs_result(2*i) = thickness_stairs_result(2*i-1) + thickness_stairs_result(2*i);
    thickness_stairs_result(2*i+1) = thickness_stairs_result(2*i);
end
rh_stairs_result = repelem(rh_result, 2);


thickness_stairs_mean2 = repelem(thickness_mean2, 2);
thickness_stairs_mean2 = thickness_stairs_mean2(1:end-1);
thickness_stairs_mean2 = [0, thickness_stairs_mean2];
for i = 2:5
    thickness_stairs_mean2(2*i) = thickness_stairs_mean2(2*i-1) + thickness_stairs_mean2(2*i);
    thickness_stairs_mean2(2*i+1) = thickness_stairs_mean2(2*i);
end
rh_stairs_mean2 = repelem(rh_mean2, 2);

rh_stairs_upper = repelem(rh_upper, 2);
rh_stairs_lower = repelem(rh_lower, 2);

thickness_stairs_upper = repelem(thickness_upper, 2);
thickness_stairs_upper = thickness_stairs_upper(1:end-1);
thickness_stairs_upper = [0, thickness_stairs_upper];
for i = 2:5
    thickness_stairs_upper(2*i) = thickness_stairs_upper(2*i-1) + thickness_stairs_upper(2*i);
    thickness_stairs_upper(2*i+1) = thickness_stairs_upper(2*i);
end

thickness_stairs_lower = repelem(thickness_lower, 2);
thickness_stairs_lower = thickness_stairs_lower(1:end-1);
thickness_stairs_lower = [0, thickness_stairs_lower];
for i = 2:5
    thickness_stairs_lower(2*i) = thickness_stairs_lower(2*i-1) + thickness_stairs_lower(2*i);
    thickness_stairs_lower(2*i+1) = thickness_stairs_lower(2*i);
end


x_fill = [rh_stairs_upper, fliplr(rh_stairs_lower)];
y_fill = [thickness_stairs_upper, fliplr(thickness_stairs_lower)];

figure;


stairs(rh_stairs_result, thickness_stairs_result, ...
       'b-', 'LineWidth', 1.5, 'DisplayName', 'True Values');
hold on;
stairs(rh_stairs_mean2, thickness_stairs_mean2, ...
       'g--', 'LineWidth', 1.5, 'DisplayName', 'Predicted Mean');


fill(x_fill, y_fill, 'r', ...
     'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
     'DisplayName', '5%-95% Uncertainty Region');


xlabel('Resistivity (\Omega\cdotm)', 'FontSize', 22);
ylabel('Thickness (m)',             'FontSize', 22);
set(gca, 'FontSize', 22);       

grid on;
xlim([0, 1200]);
ylim([-7000, 500]);

legend('Location','northwest', 'FontSize', 10);

hold off;

