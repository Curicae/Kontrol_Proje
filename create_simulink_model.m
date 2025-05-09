% create_simulink_model.m - Trafik Işığı Simulink Modelini Otomatik Oluşturur

% Mevcut modeli kapat ve yeni model oluştur
close_system('traffic_light_simulink', 0);
new_system('traffic_light_simulink');
open_system('traffic_light_simulink');

% Model parametrelerini ayarla
set_param('traffic_light_simulink', 'StopTime', '3600');
set_param('traffic_light_simulink', 'FixedStep', '1');

% Alt sistemleri oluştur
subsystems = {'Vehicle_Generator', 'Queue_System', 'Traffic_Light_Controller', 'PID_Controller', 'Visualization'};
for i = 1:length(subsystems)
    add_block('simulink/Subsystems/Subsystem', ['traffic_light_simulink/' subsystems{i}]);
end

% Vehicle Generator alt sistemi
vehicle_gen_path = 'traffic_light_simulink/Vehicle_Generator';
add_block('simulink/Sources/Random Number', [vehicle_gen_path '/Random_Number']);
add_block('simulink/Discrete/Rate Limiter', [vehicle_gen_path '/Rate_Limiter']);
add_block('simulink/Math Operations/Gain', [vehicle_gen_path '/Poisson_Gain']);
set_param([vehicle_gen_path '/Poisson_Gain'], 'Gain', '1/60'); % Dakikada araç sayısı

% Queue System alt sistemi
queue_path = 'traffic_light_simulink/Queue_System';
add_block('simulink/Discrete/Unit Delay', [queue_path '/Queue_Delay']);
add_block('simulink/Math Operations/Sum', [queue_path '/Queue_Sum']);
add_block('simulink/Math Operations/Subtract', [queue_path '/Queue_Subtract']);

% Traffic Light Controller alt sistemi
tlc_path = 'traffic_light_simulink/Traffic_Light_Controller';
add_block('sflib/Chart', [tlc_path '/Stateflow_Chart']);

% Stateflow Chart içeriğini oluştur
chart_path = [tlc_path '/Stateflow_Chart'];
set_param(chart_path, 'ChartUpdate', 'Discrete');
set_param(chart_path, 'SampleTime', '1');

% PID Controller alt sistemi
pid_path = 'traffic_light_simulink/PID_Controller';
add_block('simulink/Math Operations/Sum', [pid_path '/Error_Sum']);
add_block('simulink/Math Operations/Gain', [pid_path '/Proportional_Gain']);
add_block('simulink/Continuous/Integrator', [pid_path '/Integral']);
add_block('simulink/Continuous/Derivative', [pid_path '/Derivative']);
add_block('simulink/Math Operations/Sum', [pid_path '/PID_Sum']);

% PID parametrelerini ayarla
set_param([pid_path '/Proportional_Gain'], 'Gain', '0.5');  % Kp
set_param([pid_path '/Integral'], 'Gain', '0.1');          % Ki
set_param([pid_path '/Derivative'], 'Gain', '0.05');       % Kd

% Visualization alt sistemi
viz_path = 'traffic_light_simulink/Visualization';
add_block('simulink/Sinks/Scope', [viz_path '/Queue_Length_Scope']);
add_block('simulink/Sinks/Scope', [viz_path '/Wait_Time_Scope']);
add_block('simulink/Sinks/Display', [viz_path '/Light_State_Display']);

% Blokları bağla
% Vehicle Generator -> Queue System
add_line('traffic_light_simulink', 'Vehicle_Generator/1', 'Queue_System/1', 'autorouting', 'on');

% Queue System -> PID Controller
add_line('traffic_light_simulink', 'Queue_System/1', 'PID_Controller/1', 'autorouting', 'on');

% PID Controller -> Traffic Light Controller
add_line('traffic_light_simulink', 'PID_Controller/1', 'Traffic_Light_Controller/1', 'autorouting', 'on');

% Traffic Light Controller -> Queue System
add_line('traffic_light_simulink', 'Traffic_Light_Controller/1', 'Queue_System/2', 'autorouting', 'on');

% Queue System -> Visualization
add_line('traffic_light_simulink', 'Queue_System/1', 'Visualization/1', 'autorouting', 'on');
add_line('traffic_light_simulink', 'Queue_System/2', 'Visualization/2', 'autorouting', 'on');
add_line('traffic_light_simulink', 'Traffic_Light_Controller/1', 'Visualization/3', 'autorouting', 'on');

% Modeli düzenle ve kaydet
set_param('traffic_light_simulink', 'ZoomFactor', 'FitSystem');
save_system('traffic_light_simulink');

fprintf('Simulink modeli başarıyla oluşturuldu!\n');
fprintf('Modeli açmak için: open_system(''traffic_light_simulink'')\n');
fprintf('Simülasyonu başlatmak için: sim(''traffic_light_simulink'')\n'); 