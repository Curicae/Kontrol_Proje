% initialize_parameters.m - Simülasyon parametrelerini tanımlar

fprintf('Simülasyon parametreleri yükleniyor...\n');

% Simülasyon Zamanlama
total_simulation_duration = 3600;  % saniye (örn. 1 saat)
time_step_size = 1;               % saniye (simülasyon hassasiyeti)

% Kavşak ve Trafik Işığı Parametreleri
yellow_light_duration = 3;        % saniye (sabit)
min_green_duration = 15;          % saniye
max_green_duration = 90;          % saniye
base_green_duration = 30;         % saniye (başlangıç veya varsayılan yeşil süre)

% Trafik Verisi Simülasyon Parametreleri
% Varış oranları (Poisson dağılımı için lambda - saniyede araç sayısı)
% Bu değerler farklı trafik koşullarını simüle etmek için değiştirilebilir (yoğun, normal)
arrival_rates = struct(...
    'North_peak', 10/60, ...     % dakikada 10 araç
    'South_peak', 12/60, ...
    'East_peak',  8/60, ...
    'West_peak',  9/60, ...
    'North_normal', 5/60, ...    % dakikada 5 araç
    'South_normal', 6/60, ...
    'East_normal',  4/60, ...
    'West_normal',  4.5/60 ...
);

% Mevcut varış oranı profilini seç (örn. 'peak' veya 'normal')
current_arrival_profile = 'peak';  % Simülasyon sırasında veya senaryoya göre değiştirilebilir

% Yaklaşan araçlar için zaman penceresi (yoğunluk hesaplaması için)
approaching_vehicle_time_window = 10;  % saniye

% Araç özellikleri
vehicles_per_second_green = 1;  % Yeşil ışık saniyesinde geçebilecek araç sayısı

% PID Kontrolcü Parametreleri
% Kuzey-Güney yönü kontrolü için
PID_gains_NS = struct('Kp', 0.5, 'Ki', 0.1, 'Kd', 0.05);

% Doğu-Batı yönü kontrolü için (aynı veya farklı olabilir)
PID_gains_EW = struct('Kp', 0.5, 'Ki', 0.1, 'Kd', 0.05);

% PID Target Density/Error Definition
% Option 1: Target a specific density (e.g., an ideal low number)
% target_density_threshold = 5; % Example: aim for less than 5 vehicles contributing to density
% Option 2: Balance against opposing traffic (this is often more dynamic)
% (This means error will be current_dir_density - opposing_dir_density)

fprintf('Parametreler yüklendi.\n'); 