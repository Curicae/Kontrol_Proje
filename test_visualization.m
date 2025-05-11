% test_visualization.m
% Trafik kontrol sistemi için test verisi oluşturur ve görselleştirir

% Test verisi oluştur
fprintf('Test verisi oluşturuluyor...\n');

% Zaman verisi (5 saniyelik simülasyon, 0.01 adımlarla)
log_time = 0:0.01:5;
log_time = log_time(:); % Sütun vektörü yap

% Doğu-Batı ve Kuzey-Güney kuyruk uzunlukları
% Farklı sinüs fonksiyonları ile gerçekçi trafik dalgalanmaları oluştur
log_vehicle_queues = zeros(length(log_time), 2);

% Doğu-Batı kuyruk uzunluğu (maksimum 5 araç)
log_vehicle_queues(:,1) = 5 * (sin(log_time/2).^2 + 0.2*sin(log_time*3));
log_vehicle_queues(:,1) = max(0, log_vehicle_queues(:,1)); % Negatif değerleri sıfırla

% Kuzey-Güney kuyruk uzunluğu (maksimum 4 araç, farklı fazda)
log_vehicle_queues(:,2) = 4 * (sin((log_time+1)/2).^2 + 0.3*sin(log_time*2));
log_vehicle_queues(:,2) = max(0, log_vehicle_queues(:,2)); % Negatif değerleri sıfırla

% Trafik yoğunlukları 
density_EW = log_vehicle_queues(:,1) / 5; % 0-1 arası yoğunluk
density_NS = log_vehicle_queues(:,2) / 4; % 0-1 arası yoğunluk

% Ortalama bekleme süreleri (yoğunluğa bağlı olarak hesaplanır)
average_wait_time_EW = 3 * density_EW.^2 + 0.5*sin(log_time);
average_wait_time_NS = 2.5 * density_NS.^2 + 0.4*cos(log_time);

% Işık süreleri (saniye)
green_duration_EW = 30 + 20*sin(log_time/5);
green_duration_NS = 25 + 15*cos(log_time/5);

% PID parametreleri
PID_gains_EW = [0.8, 0.2, 0.1]; % [Kp, Ki, Kd]
PID_gains_NS = [0.7, 0.3, 0.1]; % [Kp, Ki, Kd]

% Diğer değişkenler
t = log_time; % Alternatif zaman değişkeni
queue_lengths = log_vehicle_queues; % Alternatif kuyruk değişkeni

% Simulink modelindeki simOut benzeri bir yapı
simOut = struct();
simOut.tout = t;
simOut.yout = queue_lengths;

% Verileri çalışma alanına aktar (workspace)
fprintf('Veriler çalışma alanına (workspace) aktarılıyor...\n');
assignin('base', 'log_time', log_time);
assignin('base', 'log_vehicle_queues', log_vehicle_queues);
assignin('base', 'density_EW', density_EW);
assignin('base', 'density_NS', density_NS);
assignin('base', 'average_wait_time_EW', average_wait_time_EW);
assignin('base', 'average_wait_time_NS', average_wait_time_NS);
assignin('base', 'green_duration_EW', green_duration_EW);
assignin('base', 'green_duration_NS', green_duration_NS);
assignin('base', 'PID_gains_EW', PID_gains_EW);
assignin('base', 'PID_gains_NS', PID_gains_NS);
assignin('base', 't', t);
assignin('base', 'queue_lengths', queue_lengths);
assignin('base', 'simOut', simOut);

% Görselleştirme fonksiyonunu çağır
fprintf('Görselleştirme fonksiyonu çağrılıyor...\n');
% İki seçenek:
% 1. Ayrı bir fonksiyon olarak tanımladıysak: traffic_visualization();
% 2. Script olarak tanımladıysak: run('traffic_visualization.m');

% Burada fonksiyon olarak çağırıyoruz
traffic_visualization();

fprintf('Görselleştirme tamamlandı.\n');

% Not: Dosyayı script olarak çalıştırmak için "Run" düğmesine basın veya
% MATLAB komut penceresine "test_visualization" yazın 