% create_traffic_model.m - Trafik Işığı Simulink Modelini Otomatik Oluşturur

function create_traffic_model()
    % Mevcut modeli kapat ve temizle
    if bdIsLoaded('traffic_model')
        close_system('traffic_model', 0);
    end

    % Yeni model oluştur
    new_system('traffic_model');
    open_system('traffic_model');

    % Model parametrelerini ayarla
    set_param('traffic_model', 'StopTime', '120');
    set_param('traffic_model', 'FixedStep', '1');
    set_param('traffic_model', 'EnablePacing', 'on');
    set_param('traffic_model', 'PacingRate', '1');

    % Alt sistemleri oluştur
    subsystems = {'Vehicle_Generator', 'Queue_System', 'Traffic_Light_Controller', 'PID_Controller', 'Visualization'};
    for i = 1:length(subsystems)
        add_block('built-in/Subsystem', ['traffic_model/' subsystems{i}]);
    end

    % Alt sistemlerin içeriğini oluştur
    create_vehicle_generator();
    create_queue_system();
    create_traffic_light_controller();
    create_pid_controller();
    create_visualization();

    % Alt sistemleri bağla
    connect_subsystems();

    % Modeli düzenle ve kaydet
    set_param('traffic_model', 'ZoomFactor', 'FitSystem');
    Simulink.BlockDiagram.arrangeSystem('traffic_model');
    save_system('traffic_model');

    fprintf('Simulink modeli başarıyla oluşturuldu!\n');
    fprintf('Modeli açmak için: open_system(''traffic_model'')\n');
    fprintf('Simülasyonu başlatmak için: sim(''traffic_model'')\n');
end

function create_vehicle_generator()
    % Vehicle Generator alt sistemini oluştur
    path = 'traffic_model/Vehicle_Generator';
    
    % Blokları ekle
    add_block('simulink/Sources/Random Number', [path '/Random_Number']);
    add_block('built-in/RateLimiter', [path '/Rate_Limiter']);
    add_block('simulink/Math Operations/Gain', [path '/Poisson_Gain']);
    add_block('built-in/Outport', [path '/Out1']);
    
    % Parametreleri ayarla
    set_param([path '/Poisson_Gain'], 'Gain', '1/60');
    set_param([path '/Out1'], 'Port', '1');
    
    % Bağlantıları yap
    add_line(path, 'Random_Number/1', 'Rate_Limiter/1', 'autorouting', 'on');
    add_line(path, 'Rate_Limiter/1', 'Poisson_Gain/1', 'autorouting', 'on');
    add_line(path, 'Poisson_Gain/1', 'Out1/1', 'autorouting', 'on');
end

function create_queue_system()
    % Queue System alt sistemini oluştur
    path = 'traffic_model/Queue_System';

    % Parametreler (önerilen değerler)
    maxDeparturesPerSecond = 0.5; % Yeşil ışıkta saniyede ayrılabilecek maksimum araç
    Ts_val = 1; % Modelin FixedStep değeriyle aynı olmalı
    departureGainValue = sprintf('%g*%g', maxDeparturesPerSecond, Ts_val); % Gain değeri için string
    queueCapacityValue = '100'; % Maksimum kuyruk kapasitesi
    epsValue = 'eps'; % Sıfıra bölme için eşik değeri

    % (1) Open and clear out any default ports
    open_system(path);
    % Mevcut blokları ve hatları temizle (özellikle yeniden çalıştırırken önemli)
    all_lines = find_system(path, 'FindAll', 'on', 'type', 'line');
    for k = 1:length(all_lines)
        try % Bazen hatlar zaten silinmiş olabilir
            delete_line(get(all_lines(k),'SrcBlockHandle'), get(all_lines(k),'DstBlockHandle'));
        catch
        end
    end
    all_blocks = find_system(path, 'SearchDepth', 1, 'Type', 'Block');
    % Ana subsystem'i silmemek için kontrol
    for k = 1:length(all_blocks)
        if ~strcmp(get_param(all_blocks{k}, 'Name'), 'Queue_System')
             try
                delete_block(all_blocks{k});
             catch
             end
        end
    end
    % Portları da temizleyelim (find_system ile gelen Inport/Outport'ları sildikten sonra da kalabilir)
    % delete_block(find_system(path, 'BlockType', 'Inport'));
    % delete_block(find_system(path, 'BlockType', 'Outport'));


    % (2) Explicitly add Inports
    add_block('built-in/Inport', [path '/In1']); % Arrivals (lambda for wait time)
    set_param([path '/In1'], 'Port', '1');
    add_block('built-in/Inport', [path '/In2']); % Light Signal (0 or 1 from TLC)
    set_param([path '/In2'], 'Port', '2');

    % (3) Add Outports: Out1 for Queue Length (L), Out2 for Wait Time (W)
    add_block('built-in/Outport', [path '/Out1']); % Queue Length (L_new)
    set_param([path '/Out1'], 'Port', '1');
    add_block('built-in/Outport', [path '/Out2']); % Wait Time (W)
    set_param([path '/Out2'], 'Port', '2');

    % (4) Departure Control Blocks
    add_block('simulink/Math Operations/Gain', [path '/Departure_Gain']);
    set_param([path '/Departure_Gain'], 'Gain', departureGainValue);

    % (5) Main blocks for queue logic
    add_block('simulink/Discrete/Unit Delay', [path '/Queue_Delay']); % Stores L_old
    set_param([path '/Queue_Delay'], 'InitialCondition', '0'); % Başlangıçta kuyruk boş
    add_block('simulink/Math Operations/Sum', [path '/Queue_Sum_Arrivals']); % L_old + Arrivals
    set_param([path '/Queue_Sum_Arrivals'], 'Inputs', '++');
    add_block('simulink/Math Operations/Sum', [path '/Queue_Subtract_Departures']); % (L_old + Arrivals) - Actual_Departures = L_new_raw
    set_param([path '/Queue_Subtract_Departures'], 'Inputs', '+-');
    add_block('simulink/Discontinuities/Saturation', [path '/Queue_Saturate']); % L_new_saturated
    set_param([path '/Queue_Saturate'], 'UpperLimit', queueCapacityValue, 'LowerLimit', '0');

    % (6) Blocks for Wait Time calculation (W = L_old / lambda, protected)
    add_block('simulink/Math Operations/Divide', [path '/Protected_WaitTime_Divide']);
    set_param([path '/Protected_WaitTime_Divide'], 'SampleTime', '-1'); % Inherit sample time
    add_block('simulink/Sources/Constant', [path '/ZeroConst_For_WaitTime']);
    set_param([path '/ZeroConst_For_WaitTime'], 'Value', '0');
    add_block('simulink/Signal Routing/Switch', [path '/Wait_Switch']);
    set_param([path '/Wait_Switch'], 'Criteria', 'u2 > Threshold', 'Threshold', epsValue);

    % (7) Wire up the connections
    % Departure Control Path
    add_line(path, 'In2/1', 'Departure_Gain/1', 'autorouting', 'on'); % Light Signal to Departure_Gain

    % Queue Logic Path: L_new = saturate(L_old + Arrivals - Actual_Departures)
    add_line(path, 'Queue_Delay/1', 'Queue_Sum_Arrivals/1', 'autorouting', 'on');      % L_old to Sum1
    add_line(path, 'In1/1', 'Queue_Sum_Arrivals/2', 'autorouting', 'on');              % Arrivals to Sum1
    add_line(path, 'Queue_Sum_Arrivals/1', 'Queue_Subtract_Departures/1', 'autorouting', 'on'); % (L_old + Arrivals) to Sum2
    add_line(path, 'Departure_Gain/1', 'Queue_Subtract_Departures/2', 'autorouting', 'on'); % Actual_Departures to Sum2
    add_line(path, 'Queue_Subtract_Departures/1', 'Queue_Saturate/1', 'autorouting', 'on'); % L_new_raw to Saturation
    add_line(path, 'Queue_Saturate/1', 'Queue_Delay/1', 'autorouting', 'on');  % L_new_saturated back to Delay (becomes L_old for next step)
    add_line(path, 'Queue_Saturate/1', 'Out1/1', 'autorouting', 'on');        % L_new_saturated to Out1 (Queue Length)

    % Wait Time Calculation Path: W = (lambda > eps) ? (L_old / lambda) : 0
    add_line(path, 'Queue_Delay/1', 'Protected_WaitTime_Divide/1', 'autorouting', 'on'); % L_old to Divide Numerator
    add_line(path, 'In1/1', 'Protected_WaitTime_Divide/2', 'autorouting', 'on');         % lambda to Divide Denominator
    
    add_line(path, 'Protected_WaitTime_Divide/1', 'Wait_Switch/1', 'autorouting', 'on'); % (L_old/lambda) to Switch (if true)
    add_line(path, 'In1/1', 'Wait_Switch/2', 'autorouting', 'on');                       % lambda to Switch (control)
    add_line(path, 'ZeroConst_For_WaitTime/1', 'Wait_Switch/3', 'autorouting', 'on');    % 0 to Switch (if false)
    add_line(path, 'Wait_Switch/1', 'Out2/1', 'autorouting', 'on');                      % W to Out2 (Wait Time)
end

function create_traffic_light_controller()
    % Traffic Light Controller alt sistemini oluştur
    path = 'traffic_model/Traffic_Light_Controller';
    state_machine_path = [path '/State_Machine'];
    
    % Blokları ekle
    add_block('simulink/Ports & Subsystems/Subsystem', state_machine_path);
    
    % Varsayılan portları sil
    delete_line(state_machine_path, 'In1/1', 'Out1/1');
    delete_block([state_machine_path '/In1']);
    delete_block([state_machine_path '/Out1']);
    
    % Yeni portları ekle
    add_block('built-in/Inport', [state_machine_path '/In1']);
    add_block('built-in/Outport', [state_machine_path '/Out1']);
    add_block('built-in/Inport', [path '/In1']);
    add_block('built-in/Outport', [path '/Out1']);
    
    % Parametreleri ayarla
    set_param([state_machine_path '/In1'], 'Port', '1');
    set_param([state_machine_path '/Out1'], 'Port', '1');
    set_param([path '/In1'], 'Port', '1');
    set_param([path '/Out1'], 'Port', '1');
    
    % Bağlantıları yap
    add_line(state_machine_path, 'In1/1', 'Out1/1', 'autorouting', 'on');
    add_line(path, 'In1/1', 'State_Machine/1', 'autorouting', 'on');
    add_line(path, 'State_Machine/1', 'Out1/1', 'autorouting', 'on');
end

function create_pid_controller()
    % PID Controller alt sistemini oluştur
    path = 'traffic_model/PID_Controller';
    
    % Blokları ekle
    add_block('built-in/Inport', [path '/In1']); % Input: Queue Length (Ölçülen Değer)
    add_block('simulink/Sources/Constant', [path '/Setpoint_Constant']); % Ayar Noktası
    add_block('simulink/Discrete/Unit Delay', [path '/Feedback_Delay']); % Cebirsel döngüyü kırmak için
    add_block('simulink/Math Operations/Sum', [path '/Error_Sum']); % Hata = Ayar Noktası - Ölçülen Değer
    add_block('simulink/Math Operations/Gain', [path '/Proportional_Gain']);
    add_block('simulink/Discrete/Discrete-Time Integrator', [path '/Discrete_Time_Integrator']); % Ayrık Zamanlı İntegral
    add_block('simulink/Discrete/Discrete Derivative', [path '/Discrete_Derivative']); % Sürekli yerine Ayrık Türev
    add_block('simulink/Math Operations/Sum', [path '/PID_Sum']);
    add_block('built-in/Outport', [path '/Out1']); % Output: Kontrol Sinyali
    
    % Parametreleri ayarla
    set_param([path '/In1'], 'Port', '1');
    set_param([path '/Setpoint_Constant'], 'Value', '10'); % Hedef kuyruk uzunluğu (ayarlanabilir)
    set_param([path '/Error_Sum'], 'Inputs', '+-'); % Hata = Giriş1 - Giriş2
    set_param([path '/Proportional_Gain'], 'Gain', '0.5');
    set_param([path '/Discrete_Time_Integrator'], 'IntegratorMethod', 'Forward Euler');
    set_param([path '/Discrete_Time_Integrator'], 'SampleTime', '-1'); % Kalıtımsal örnekleme zamanı
    % Discrete_Derivative için özel bir ayar gerekirse buraya eklenebilir.
    set_param([path '/PID_Sum'], 'Inputs', '+++');
    set_param([path '/Out1'], 'Port', '1');
    
    % Bağlantıları yap
    add_line(path, 'In1/1', 'Feedback_Delay/1', 'autorouting', 'on'); % Ölçülen Değer -> Gecikme Bloğu
    add_line(path, 'Setpoint_Constant/1', 'Error_Sum/1', 'autorouting', 'on'); % Ayar Noktası -> Hata_Sum Giriş1
    add_line(path, 'Feedback_Delay/1', 'Error_Sum/2', 'autorouting', 'on');    % Gecikmiş Ölçülen Değer -> Hata_Sum Giriş2

    add_line(path, 'Error_Sum/1', 'Proportional_Gain/1', 'autorouting', 'on');
    add_line(path, 'Error_Sum/1', 'Discrete_Time_Integrator/1', 'autorouting', 'on'); % Hata -> Ayrık Zamanlı İntegral
    add_line(path, 'Error_Sum/1', 'Discrete_Derivative/1', 'autorouting', 'on'); % Hata -> Ayrık Türev
    
    add_line(path, 'Proportional_Gain/1', 'PID_Sum/1', 'autorouting', 'on');
    add_line(path, 'Discrete_Time_Integrator/1', 'PID_Sum/2', 'autorouting', 'on'); % Ayrık İntegral Çıkışı -> PID_Sum
    add_line(path, 'Discrete_Derivative/1', 'PID_Sum/3', 'autorouting', 'on'); % Ayrık Türev Çıkışı -> PID_Sum
    add_line(path, 'PID_Sum/1', 'Out1/1', 'autorouting', 'on');
end

function create_visualization()
    % Visualization alt sistemini oluştur
    path = 'traffic_model/Visualization';

    % Mevcut tüm blokları ve hatları temizle
    open_system(path); % Alt sistemi aç
    all_lines = find_system(path, 'FindAll', 'on', 'type', 'line');
    for k = 1:length(all_lines)
        try delete_line(get(all_lines(k),'Handle')); catch; end
    end
    all_blocks = find_system(path, 'SearchDepth', 1, 'Type', 'Block');
    for k = 1:length(all_blocks)
        if ~strcmp(get_param(all_blocks{k}, 'Name'), 'Visualization') % Ana subsystem'i silme
            try delete_block(all_blocks{k}); catch; end
        end
    end

    % Inport'leri ekle ve pozisyonlarını ayarla
    add_block('built-in/Inport', [path '/In1']); 
    set_param([path '/In1'],'Port','1', 'Position', '[50, 58, 80, 72]'); % Queue Length
    add_block('built-in/Inport', [path '/In2']); 
    set_param([path '/In2'],'Port','2', 'Position', '[50, 118, 80, 132]'); % Wait Time
    add_block('built-in/Inport', [path '/In3']); 
    set_param([path '/In3'],'Port','3', 'Position', '[50, 178, 80, 192]'); % Light State

    % Scope bloklarını ekle ve pozisyonlarını ayarla
    add_block('simulink/Sinks/Scope', [path '/Queue_Length_Scope']);
    set_param([path '/Queue_Length_Scope'], 'Position', '[200, 40, 260, 90]', 'NumInputPorts', '1', 'OpenAtSimulationStart', 'on');

    add_block('simulink/Sinks/Scope', [path '/Wait_Time_Scope']);
    set_param([path '/Wait_Time_Scope'], 'Position', '[200, 100, 260, 150]', 'NumInputPorts', '1', 'OpenAtSimulationStart', 'on');

    add_block('simulink/Sinks/Scope', [path '/Light_State_Scope']);
    set_param([path '/Light_State_Scope'], 'Position', '[200, 160, 260, 210]', 'NumInputPorts', '1', 'OpenAtSimulationStart', 'on');
    
    % To Workspace bloklarını ekle ve pozisyonlarını ayarla (Scope'ların sağına)
    add_block('simulink/Sinks/To Workspace', [path '/Queue_ToWS']);
    set_param([path '/Queue_ToWS'], 'VariableName', 'queueLengthData', 'SaveFormat', 'Array', 'Position', '[350, 40, 410, 90]');

    add_block('simulink/Sinks/To Workspace', [path '/Wait_ToWS']);
    set_param([path '/Wait_ToWS'], 'VariableName', 'waitTimeData', 'SaveFormat', 'Array', 'Position', '[350, 100, 410, 150]');

    add_block('simulink/Sinks/To Workspace', [path '/Light_ToWS']);
    set_param([path '/Light_ToWS'], 'VariableName', 'lightStateData', 'SaveFormat', 'Array', 'Position', '[350, 160, 410, 210]');
    
    % Hatları hem Scope'lara hem de To Workspace bloklarına bağla
    add_line(path, 'In1/1', 'Queue_Length_Scope/1','autorouting','on');
    add_line(path, 'In1/1', 'Queue_ToWS/1','autorouting','on');

    add_line(path, 'In2/1', 'Wait_Time_Scope/1','autorouting','on');
    add_line(path, 'In2/1', 'Wait_ToWS/1','autorouting','on');

    add_line(path, 'In3/1', 'Light_State_Scope/1','autorouting','on');
    add_line(path, 'In3/1', 'Light_ToWS/1','autorouting','on');

    % Alt sistemin içini otomatik düzenle
    Simulink.BlockDiagram.arrangeSystem(path);
end

function connect_subsystems()
    % Verify and display Queue_System port counts before getting handles
    qsPorts = get_param('traffic_model/Queue_System', 'Ports');
    disp(['Queue_System Port Configuration (In, Out, En, Tr, St, LConn, RConn, Ifaction): ', mat2str(qsPorts)]);

    % Get PortHandles for all subsystems
    vgPH = get_param('traffic_model/Vehicle_Generator', 'PortHandles');
    qsPH = get_param('traffic_model/Queue_System', 'PortHandles');
    disp(['Number of Inports in Queue_System according to PortHandles: ', num2str(length(qsPH.Inport))]);
    disp(['Number of Outports in Queue_System according to PortHandles: ', num2str(length(qsPH.Outport))]);

    pidPH = get_param('traffic_model/PID_Controller', 'PortHandles');
    tlcPH = get_param('traffic_model/Traffic_Light_Controller', 'PortHandles');
    visPH = get_param('traffic_model/Visualization', 'PortHandles');

    % Alt sistemleri birbirine bağla
    % Vehicle Generator -> Queue System (in1)
    add_line('traffic_model', vgPH.Outport(1), qsPH.Inport(1), 'autorouting', 'on');
    
    % Queue System (out1) -> PID Controller
    add_line('traffic_model', qsPH.Outport(1), pidPH.Inport(1), 'autorouting', 'on');
    
    % PID Controller -> Traffic Light Controller
    add_line('traffic_model', pidPH.Outport(1), tlcPH.Inport(1), 'autorouting', 'on');
    
    % Traffic Light Controller -> Queue System (in2)
    add_line('traffic_model', tlcPH.Outport(1), qsPH.Inport(2), 'autorouting', 'on');
    
    % Queue System & Traffic Light Controller -> Visualization
    add_line('traffic_model', qsPH.Outport(1), visPH.Inport(1), 'autorouting', 'on');       % Queue Length from Queue_System Out1
    add_line('traffic_model', qsPH.Outport(2), visPH.Inport(2), 'autorouting', 'on');        % Wait Time from Queue_System Out2
    add_line('traffic_model', tlcPH.Outport(1), visPH.Inport(3), 'autorouting', 'on');       % Light State from TLC Out1
end 