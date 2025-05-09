% create_traffic_controller.m - Trafik Işığı Kontrolcüsünü Oluşturur

% Traffic Light Controller alt sistemini aç
if ~bdIsLoaded('traffic_model')
    error('Önce create_traffic_model.m scriptini çalıştırın!');
end

% State Machine alt sistemini oluştur
tlc_path = 'traffic_model/Traffic_Light_Controller';
state_machine_path = [tlc_path '/State_Machine'];

% State Machine alt sistemini oluştur
add_block('built-in/Subsystem', state_machine_path);

% Durum makinesi için blokları ekle
add_block('built-in/UnitDelay', [state_machine_path '/State_Delay']);
add_block('built-in/Constant', [state_machine_path '/NS_Green_State']);
add_block('built-in/Constant', [state_machine_path '/NS_Yellow_State']);
add_block('built-in/Constant', [state_machine_path '/EW_Green_State']);
add_block('built-in/Constant', [state_machine_path '/EW_Yellow_State']);
add_block('built-in/Switch', [state_machine_path '/State_Switch']);
add_block('built-in/Compare', [state_machine_path '/Timer_Compare']);

% Durum değerlerini ayarla
set_param([state_machine_path '/NS_Green_State'], 'Value', '1');
set_param([state_machine_path '/NS_Yellow_State'], 'Value', '2');
set_param([state_machine_path '/EW_Green_State'], 'Value', '3');
set_param([state_machine_path '/EW_Yellow_State'], 'Value', '4');

% Blokları bağla
add_line(state_machine_path, 'State_Delay/1', 'State_Switch/1', 'autorouting', 'on');
add_line(state_machine_path, 'NS_Green_State/1', 'State_Switch/2', 'autorouting', 'on');
add_line(state_machine_path, 'NS_Yellow_State/1', 'State_Switch/3', 'autorouting', 'on');
add_line(state_machine_path, 'EW_Green_State/1', 'State_Switch/4', 'autorouting', 'on');
add_line(state_machine_path, 'EW_Yellow_State/1', 'State_Switch/5', 'autorouting', 'on');

% Modeli kaydet
save_system('traffic_model');

fprintf('Trafik Işığı Kontrolcüsü başarıyla oluşturuldu!\n'); 