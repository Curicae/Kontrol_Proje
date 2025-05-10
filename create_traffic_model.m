function create_traffic_model()
    % Trafik ışığı Simulink modeli otomatik oluşturma scripti
    modelName = 'traffic_light_model';
    % Var olan modeli kapat
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    % Yeni model oluştur ve aç
    new_system(modelName);

    open_system(modelName);
    % Model ayarları
    set_param(modelName, 'StopTime', '300');
    set_param(modelName, 'SolverType', 'Fixed-step');
    set_param(modelName, 'Solver', 'ode4');
    set_param(modelName, 'FixedStep', '1');
    set_param(modelName, 'EnablePacing', 'on');
    set_param(modelName, 'PacingRate', '1');
    % Alt sistemleri oluştur
    create_api_data_interface(modelName);
    create_vehicle_generator(modelName);
    create_queue_system(modelName);
    create_traffic_light_controller(modelName);
    create_pid_controller(modelName);
    create_visualization(modelName);
    % Bağlantılar
    connect_subsystems(modelName);
    % Düzenle, kaydet ve bildir
    set_param(modelName, 'ZoomFactor', 'FitSystem');
    Simulink.BlockDiagram.arrangeSystem(modelName);
    save_system(modelName);
    fprintf('Model "%s" başarıyla oluşturuldu.\n', modelName);
end

function create_api_data_interface(modelName)
    % API verisi alt sistemi
    subsystemPath = [modelName '/API_Data_Interface'];
    add_block('built-in/Subsystem', subsystemPath);

    % API çıktı portları ekleme
    add_block('built-in/Outport', [subsystemPath '/north_density'], 'Port', '1', 'Position', [400, 50, 420, 70]);
    add_block('built-in/Outport', [subsystemPath '/south_density'], 'Port', '2', 'Position', [400, 100, 420, 120]);
    add_block('built-in/Outport', [subsystemPath '/east_density'], 'Port', '3', 'Position', [400, 150, 420, 170]);
    add_block('built-in/Outport', [subsystemPath '/west_density'], 'Port', '4', 'Position', [400, 200, 420, 220]);

    % Sabit değer kaynakları (gerçek API'yi simüle etmek için)
    add_block('simulink/Sources/Constant', [subsystemPath '/North_Const'], 'Value', '0.5', 'Position', [50, 50, 100, 70]);
    add_block('simulink/Sources/Constant', [subsystemPath '/South_Const'], 'Value', '0.6', 'Position', [50, 100, 100, 120]);
    add_block('simulink/Sources/Constant', [subsystemPath '/East_Const'], 'Value', '0.4', 'Position', [50, 150, 100, 170]);
    add_block('simulink/Sources/Constant', [subsystemPath '/West_Const'], 'Value', '0.3', 'Position', [50, 200, 100, 220]);
    
    % Rastgele değişimler
    add_block('simulink/Sources/Uniform Random Number', [subsystemPath '/Random_Var'], 'Position', [50, 250, 100, 270], 'Minimum', '-0.1', 'Maximum', '0.1');
    
    % Karıştırma bloğu (mixer)
    add_block('simulink/Math Operations/Add', [subsystemPath '/Mix_North'], 'Inputs', '++', 'Position', [200, 50, 230, 80]);
    add_block('simulink/Math Operations/Add', [subsystemPath '/Mix_South'], 'Inputs', '++', 'Position', [200, 100, 230, 130]);
    add_block('simulink/Math Operations/Add', [subsystemPath '/Mix_East'], 'Inputs', '++', 'Position', [200, 150, 230, 180]);
    add_block('simulink/Math Operations/Add', [subsystemPath '/Mix_West'], 'Inputs', '++', 'Position', [200, 200, 230, 230]);
    
    % Bağlantılar
    add_line(subsystemPath, 'North_Const/1', 'Mix_North/1', 'autorouting', 'on');
    add_line(subsystemPath, 'South_Const/1', 'Mix_South/1', 'autorouting', 'on');
    add_line(subsystemPath, 'East_Const/1', 'Mix_East/1', 'autorouting', 'on');
    add_line(subsystemPath, 'West_Const/1', 'Mix_West/1', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Random_Var/1', 'Mix_North/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Random_Var/1', 'Mix_South/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Random_Var/1', 'Mix_East/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Random_Var/1', 'Mix_West/2', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Mix_North/1', 'north_density/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Mix_South/1', 'south_density/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Mix_East/1', 'east_density/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Mix_West/1', 'west_density/1', 'autorouting', 'on');
    
    % İsteğe bağlı - MATLAB Function bloğunu karışık versiyonlarda çalışmayabilir diye eklemiyoruz
    % Bu yorum satırını kaldırarak ve alttaki `try-catch` bloğunu etkinleştirerek
    % MATLAB Function bloğunu etkinleştirebiliriz.
    
    % try
    %     % MATLAB Function bloğu ekleyip deneyelim
    %     matlabFcnPath = [subsystemPath '/Get_API_Data'];
    %     add_block('simulink/User-Defined Functions/MATLAB Function', matlabFcnPath, 'Position', [150, 300, 250, 350]);
    %     
    %     % Bu, MATLAB Function bloğu için bir temel yapı
    %     % Her MATLAB sürümünde farklı bir yapısı olabilir, bu temel bir başlangıç
    %     fcnCode = ['function [north, south, east, west] = fcn()\n',...
    %                '    persistent data last_time;\n',...
    %                '    \n',...
    %                '    if isempty(data)\n',...
    %                '        data = struct(''north'', 0.5, ''south'', 0.5, ''east'', 0.4, ''west'', 0.3);\n',...
    %                '        last_time = 0;\n',...
    %                '    end\n',...
    %                '    \n',...
    %                '    north = data.north;\n',...
    %                '    south = data.south;\n',...
    %                '    east = data.east;\n',...
    %                '    west = data.west;\n',...
    %                'end'];
    %     
    %     % MATLAB Function bloğunu güncelleyelim
    %     blk = find_system(matlabFcnPath, 'LookUnderMasks', 'all');
    %     if ~isempty(blk)
    %         set_param(blk{1}, 'MATLABFcn', fcnCode);
    %     end
    % catch e
    %     fprintf('MATLAB Function bloğu eklenirken hata: %s\n', e.message);
    %     fprintf('Sabit değerler kullanılıyor.\n');
    % end
end

function create_vehicle_generator(modelName)
    % Araç üretim alt sistemi
    path = [modelName '/Vehicle_Generator']; 
    add_block('built-in/Subsystem', path);
    
    add_block('simulink/Sources/Uniform Random Number', [path '/Random_Number'], 'Position', [50, 50, 100, 80], 'Minimum', '0', 'Maximum', '1');
    add_block('built-in/RateLimiter', [path '/Rate_Limiter'], 'Position', [150, 50, 200, 80]);
    add_block('simulink/Math Operations/Gain', [path '/Poisson_Gain'], 'Position', [250, 50, 300, 80]);
    add_block('built-in/Outport', [path '/Out1'], 'Port', '1', 'Position', [350, 50, 370, 80]);
    
    set_param([path '/Poisson_Gain'], 'Gain', '1/60');
    
    add_line(path, 'Random_Number/1', 'Rate_Limiter/1', 'autorouting', 'on');
    add_line(path, 'Rate_Limiter/1', 'Poisson_Gain/1', 'autorouting', 'on');
    add_line(path, 'Poisson_Gain/1', 'Out1/1', 'autorouting', 'on');
end

function create_queue_system(modelName)
    % Kuyruk sistemi alt modülü
    path = [modelName '/Queue_System']; 
    add_block('built-in/Subsystem', path);
    
    % Parametreler
    maxDep = 0.5; 
    Ts = 1; 
    depGain = sprintf('%g*%g', maxDep, Ts);
    capacity = '100'; 
    epsV = '2.2204e-16';
    
    % Giriş/Çıkış
    add_block('built-in/Inport', [path '/InArr'], 'Port', '1', 'Position', [50, 50, 70, 70]);
    add_block('built-in/Inport', [path '/InLight'], 'Port', '2', 'Position', [50, 150, 70, 170]);
    add_block('built-in/Outport', [path '/QueueLen'], 'Port', '1', 'Position', [500, 50, 520, 70]);
    add_block('built-in/Outport', [path '/WaitTime'], 'Port', '2', 'Position', [500, 150, 520, 170]);
    
    % Bloklar
    add_block('simulink/Math Operations/Gain', [path '/DepGain'], 'Gain', depGain, 'Position', [150, 150, 180, 170]);
    add_block('simulink/Discrete/Unit Delay', [path '/Delay'], 'InitialCondition', '0', 'Position', [350, 200, 380, 230]);
    add_block('simulink/Math Operations/Sum', [path '/Sum'], 'Inputs', '++', 'Position', [200, 50, 230, 80]);
    add_block('simulink/Math Operations/Sum', [path '/Sub'], 'Inputs', '+-', 'Position', [300, 50, 330, 80]);
    add_block('simulink/Discontinuities/Saturation', [path '/Sat'], 'UpperLimit', capacity, 'LowerLimit', '0', 'Position', [400, 50, 430, 80]);
    add_block('simulink/Math Operations/Divide', [path '/Div'], 'SampleTime', '-1', 'Position', [200, 250, 230, 280]);
    add_block('simulink/Sources/Constant', [path '/Zero'], 'Value', '0', 'Position', [200, 300, 230, 330]);
    
    % R2024b uyumlu bir yaklaşım - Compare To Zero bloğu ekleyelim
    add_block('simulink/Logic and Bit Operations/Compare To Zero', [path '/Compare'], 'Operator', '~=', 'Position', [250, 350, 280, 380]);
    
    % R2024b uyumlu Switch kullanımı (Criteria: u2 ~= 0)
    add_block('simulink/Signal Routing/Switch', [path '/Switch'], 'Criteria', 'u2 ~= 0', 'Position', [350, 150, 380, 180]);
    
    % Bağlantılar
    add_line(path, 'InLight/1', 'DepGain/1', 'autorouting', 'on');
    add_line(path, 'Delay/1', 'Sum/1', 'autorouting', 'on');
    add_line(path, 'InArr/1', 'Sum/2', 'autorouting', 'on');
    add_line(path, 'Sum/1', 'Sub/1', 'autorouting', 'on');
    add_line(path, 'DepGain/1', 'Sub/2', 'autorouting', 'on');
    add_line(path, 'Sub/1', 'Sat/1', 'autorouting', 'on');
    add_line(path, 'Sat/1', 'Delay/1', 'autorouting', 'on');
    add_line(path, 'Sat/1', 'QueueLen/1', 'autorouting', 'on');
    add_line(path, 'Delay/1', 'Div/1', 'autorouting', 'on');
    add_line(path, 'InArr/1', 'Div/2', 'autorouting', 'on');
    add_line(path, 'Div/1', 'Switch/1', 'autorouting', 'on');
    add_line(path, 'InArr/1', 'Compare/1', 'autorouting', 'on');
    add_line(path, 'Compare/1', 'Switch/2', 'autorouting', 'on'); 
    add_line(path, 'Zero/1', 'Switch/3', 'autorouting', 'on');
    add_line(path, 'Switch/1', 'WaitTime/1', 'autorouting', 'on');
end

function create_traffic_light_controller(modelName)
    % Trafik ışığı kontrolcüsü alt modu
    path = [modelName '/Traffic_Light_Controller'];
    add_block('built-in/Subsystem', path);
    
    % Durum Makinesi alt sistemi
    sm = [path '/State_Machine'];
    add_block('built-in/Subsystem', sm);
    
    % Ana sistem port tanımları
    add_block('built-in/Inport', [path '/In1'], 'Port', '1', 'Position', [50, 50, 70, 70]);
    add_block('built-in/Outport', [path '/Out1'], 'Port', '1', 'Position', [350, 50, 370, 70]);
    
    % Durum Makinesi içindeki portlar
    add_block('built-in/Inport', [sm '/In1'], 'Port', '1', 'Position', [50, 50, 70, 70]);
    add_block('built-in/Outport', [sm '/Out1'], 'Port', '1', 'Position', [250, 50, 270, 70]);
    
    % Durum Makinesi içinde basit bir geçirgen mantık (Through Logic)
    add_block('simulink/Signal Routing/Manual Switch', [sm '/Manual_Control'], 'Position', [150, 50, 180, 80]);
    set_param([sm '/Manual_Control'], 'sw', '0');
    
    % Durum Makinesi bağlantıları
    add_line(sm, 'In1/1', 'Manual_Control/1', 'autorouting', 'on');
    add_line(sm, 'Manual_Control/1', 'Out1/1', 'autorouting', 'on');
    
    % Ana sistem bağlantıları
    add_line(path, 'In1/1', 'State_Machine/1', 'autorouting', 'on');
    add_line(path, 'State_Machine/1', 'Out1/1', 'autorouting', 'on');
end

function create_pid_controller(modelName)
    % PID kontrol alt birimi
    path = [modelName '/PID_Controller'];
    add_block('built-in/Subsystem', path);
    
    % Giriş portları
    dirs = {'north', 'south', 'east', 'west'};
    for i = 1:4
        add_block('built-in/Inport', [path '/' dirs{i} '_in'], 'Port', num2str(i), 'Position', [50, 50*i, 70, 50*i+20]);
    end
    
    % Ortalama fark hesaplama
    add_block('simulink/Math Operations/Add', [path '/Sum_NS'], 'Inputs', '++', 'Position', [150, 75, 180, 105]);
    add_block('simulink/Math Operations/Gain', [path '/Gain_NS'], 'Gain', '0.5', 'Position', [200, 75, 230, 105]);
    add_block('simulink/Math Operations/Add', [path '/Sum_EW'], 'Inputs', '++', 'Position', [150, 175, 180, 205]);
    add_block('simulink/Math Operations/Gain', [path '/Gain_EW'], 'Gain', '0.5', 'Position', [200, 175, 230, 205]);
    add_block('simulink/Math Operations/Sum', [path '/Error'], 'Inputs', '+-', 'Position', [280, 125, 310, 155]);
    
    % P-I-D blokları
    add_block('simulink/Math Operations/Gain', [path '/P'], 'Gain', '1', 'Position', [350, 75, 380, 105]);
    add_block('simulink/Discrete/Discrete-Time Integrator', [path '/I'], 'IntegratorMethod', 'Forward Euler', 'SampleTime', '-1', 'Position', [350, 125, 380, 155]);
    add_block('simulink/Discrete/Discrete Derivative', [path '/D'], 'Position', [350, 175, 380, 205]);
    add_block('simulink/Math Operations/Sum', [path '/PID_Sum'], 'Inputs', '+++', 'Position', [430, 125, 460, 155]);
    add_block('built-in/Outport', [path '/Out1'], 'Port', '1', 'Position', [520, 125, 540, 155]);
    
    % Bağlantılar
    add_line(path, 'north_in/1', 'Sum_NS/1', 'autorouting', 'on');
    add_line(path, 'south_in/1', 'Sum_NS/2', 'autorouting', 'on');
    add_line(path, 'Sum_NS/1', 'Gain_NS/1', 'autorouting', 'on');
    add_line(path, 'east_in/1', 'Sum_EW/1', 'autorouting', 'on');
    add_line(path, 'west_in/1', 'Sum_EW/2', 'autorouting', 'on');
    add_line(path, 'Sum_EW/1', 'Gain_EW/1', 'autorouting', 'on');
    add_line(path, 'Gain_NS/1', 'Error/1', 'autorouting', 'on');
    add_line(path, 'Gain_EW/1', 'Error/2', 'autorouting', 'on');
    add_line(path, 'Error/1', 'P/1', 'autorouting', 'on');
    add_line(path, 'Error/1', 'I/1', 'autorouting', 'on');
    add_line(path, 'Error/1', 'D/1', 'autorouting', 'on');
    add_line(path, 'P/1', 'PID_Sum/1', 'autorouting', 'on');
    add_line(path, 'I/1', 'PID_Sum/2', 'autorouting', 'on');
    add_line(path, 'D/1', 'PID_Sum/3', 'autorouting', 'on');
    add_line(path, 'PID_Sum/1', 'Out1/1', 'autorouting', 'on');
end

function create_visualization(modelName)
    % Görselleştirme alt sistemi
    path = [modelName '/Visualization'];
    add_block('built-in/Subsystem', path);
    
    % Giriş portları ekle
    add_block('built-in/Inport', [path '/In1'], 'Port', '1', 'Position', [50, 50, 70, 70]);
    add_block('built-in/Inport', [path '/In2'], 'Port', '2', 'Position', [50, 120, 70, 140]);
    add_block('built-in/Inport', [path '/In3'], 'Port', '3', 'Position', [50, 190, 70, 210]);
    
    % Görüntüleyici (Scope) blokları ekle
    add_block('simulink/Sinks/Scope', [path '/Queue_Scope'], 'Position', [200, 45, 230, 75]);
    set_param([path '/Queue_Scope'], 'NumInputPorts', '1');
    
    add_block('simulink/Sinks/Scope', [path '/Wait_Scope'], 'Position', [200, 115, 230, 145]);
    set_param([path '/Wait_Scope'], 'NumInputPorts', '1');
    
    add_block('simulink/Sinks/Scope', [path '/Light_Scope'], 'Position', [200, 185, 230, 215]);
    set_param([path '/Light_Scope'], 'NumInputPorts', '1');
    
    % Çalışma Alanına Aktar (To Workspace) blokları ekle
    add_block('simulink/Sinks/To Workspace', [path '/Queue_Data'], 'Position', [350, 45, 400, 75]);
    set_param([path '/Queue_Data'], 'VariableName', 'queueData');
    
    add_block('simulink/Sinks/To Workspace', [path '/Wait_Data'], 'Position', [350, 115, 400, 145]);
    set_param([path '/Wait_Data'], 'VariableName', 'waitData');
    
    add_block('simulink/Sinks/To Workspace', [path '/Light_Data'], 'Position', [350, 185, 400, 215]);
    set_param([path '/Light_Data'], 'VariableName', 'lightData');
    
    % Bağlantılar
    add_line(path, 'In1/1', 'Queue_Scope/1', 'autorouting', 'on');
    add_line(path, 'In1/1', 'Queue_Data/1', 'autorouting', 'on');
    
    add_line(path, 'In2/1', 'Wait_Scope/1', 'autorouting', 'on');
    add_line(path, 'In2/1', 'Wait_Data/1', 'autorouting', 'on');
    
    add_line(path, 'In3/1', 'Light_Scope/1', 'autorouting', 'on');
    add_line(path, 'In3/1', 'Light_Data/1', 'autorouting', 'on');
end

function connect_subsystems(modelName)
    % Alt sistemler arasındaki bağlantıları oluştur
    
    % API_Data_Interface çıkışlarını PID_Controller girişlerine bağla
    add_line(modelName, 'API_Data_Interface/1', 'PID_Controller/1', 'autorouting', 'on');
    add_line(modelName, 'API_Data_Interface/2', 'PID_Controller/2', 'autorouting', 'on');
    add_line(modelName, 'API_Data_Interface/3', 'PID_Controller/3', 'autorouting', 'on');
    add_line(modelName, 'API_Data_Interface/4', 'PID_Controller/4', 'autorouting', 'on');
    
    % PID_Controller çıkışını Trafik_Işığı_Kontrolcüsü girişine bağla
    add_line(modelName, 'PID_Controller/1', 'Traffic_Light_Controller/1', 'autorouting', 'on');
    
    % Trafik_Işığı_Kontrolcüsü çıkışını Kuyruk_Sistemi girişine bağla
    add_line(modelName, 'Traffic_Light_Controller/1', 'Queue_System/2', 'autorouting', 'on');
    
    % Araç_Üretici çıkışını Kuyruk_Sistemi girişine bağla
    add_line(modelName, 'Vehicle_Generator/1', 'Queue_System/1', 'autorouting', 'on');
    
    % Kuyruk_Sistemi ve Trafik_Işığı_Kontrolcüsü çıkışlarını Görselleştirme'ye bağla
    add_line(modelName, 'Queue_System/1', 'Visualization/1', 'autorouting', 'on');
    add_line(modelName, 'Queue_System/2', 'Visualization/2', 'autorouting', 'on');
    add_line(modelName, 'Traffic_Light_Controller/1', 'Visualization/3', 'autorouting', 'on');
    
    fprintf('Alt sistemler arasındaki bağlantılar kuruldu.\n');
end