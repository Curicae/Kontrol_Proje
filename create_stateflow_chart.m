% create_stateflow_chart.m - Trafik Işığı Stateflow Chart'ını Oluşturur

% Stateflow Chart'ı oluştur
chart = Stateflow.Chart;
chart.Name = 'TrafficLightController';
chart.UpdateMethod = 'Discrete';
chart.SampleTime = 1;

% Durumları oluştur
ns_green = Stateflow.State;
ns_green.Name = 'NS_green';
ns_green.LabelString = 'NS_green\nentry: green_duration = green_duration_NS;';

ns_yellow = Stateflow.State;
ns_yellow.Name = 'NS_yellow';
ns_yellow.LabelString = 'NS_yellow\nentry: green_duration = yellow_duration;';

ew_green = Stateflow.State;
ew_green.Name = 'EW_green';
ew_green.LabelString = 'EW_green\nentry: green_duration = green_duration_EW;';

ew_yellow = Stateflow.State;
ew_yellow.Name = 'EW_yellow';
ew_yellow.LabelString = 'EW_yellow\nentry: green_duration = yellow_duration;';

% Durumları chart'a ekle
chart.add(ns_green);
chart.add(ns_yellow);
chart.add(ew_green);
chart.add(ew_yellow);

% Geçişleri oluştur
trans1 = Stateflow.Transition;
trans1.Source = ns_green;
trans1.Destination = ns_yellow;
trans1.LabelString = 'after(green_duration)';

trans2 = Stateflow.Transition;
trans2.Source = ns_yellow;
trans2.Destination = ew_green;
trans2.LabelString = 'after(green_duration)';

trans3 = Stateflow.Transition;
trans3.Source = ew_green;
trans3.Destination = ew_yellow;
trans3.LabelString = 'after(green_duration)';

trans4 = Stateflow.Transition;
trans4.Source = ew_yellow;
trans4.Destination = ns_green;
trans4.LabelString = 'after(green_duration)';

% Geçişleri chart'a ekle
chart.add(trans1);
chart.add(trans2);
chart.add(trans3);
chart.add(trans4);

% Chart'ı kaydet
save_system('traffic_light_simulink');

fprintf('Stateflow Chart başarıyla oluşturuldu!\n'); 