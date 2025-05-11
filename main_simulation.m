% main_simulation.m - PID Kontrollü Trafik Işığı Simülasyonu
% Ana simülasyon dosyası

clear;
clc;
close all;

% MATLAB yolunu düzenle - API ve diğer dosyalar için
cur_dir = pwd;
if strcmp(cur_dir(end-12:end), 'Kontrol_Proje')
    % Ana dizindeyiz, doğrudan ekle
    addpath(genpath('src'));
    addpath('utils');
    fprintf('Yollar ana dizinden eklendi.\n');
else
    % Ana dizinde değiliz, düzelt
    if exist('Kontrol_Proje', 'dir')
        cd('Kontrol_Proje');
        addpath(genpath('src'));
        addpath('utils');
        fprintf('Ana dizine geçildi ve yollar eklendi.\n');
    else
        error('Lütfen Kontrol_Proje klasörünün içinde çalıştırın.');
    end
end

fprintf('Trafik Işığı Simülasyonu Başlatılıyor...\n');

% 1. Parametreleri Yükle
run('initialize_parameters.m');
% PID parametrelerini artır - daha dinamik tepki için
PID_gains_NS.Kp = PID_gains_NS.Kp * 3.0; % P kazancını artır
PID_gains_NS.Ki = PID_gains_NS.Ki * 2.0; % I kazancını artır
PID_gains_NS.Kd = PID_gains_NS.Kd * 1.5; % D kazancını artır

PID_gains_EW.Kp = PID_gains_EW.Kp * 3.0; % P kazancını artır
PID_gains_EW.Ki = PID_gains_EW.Ki * 2.0; % I kazancını artır
PID_gains_EW.Kd = PID_gains_EW.Kd * 1.5; % D kazancını artır

fprintf('Parametreler yüklendi ve PID kazançları artırıldı.\n');

% 2. Araç Kuyruklarını Başlat
vehicle_queues = struct('north', [], 'south', [], 'east', [], 'west', []);

% 3. Trafik Işığı Durumlarını Başlat
current_light_state = 'NS_green';  % Başlangıç durumu
time_in_current_state = 0;         % Mevcut durum için zamanlayıcı
green_duration_NS = base_green_duration;
green_duration_EW = base_green_duration;

% 4. PID Kontrolcü Değişkenlerini Başlat
previous_error_NS = 0;
previous_error_EW = 0;
integral_term_NS = 0;
integral_term_EW = 0;

% 5. Yeşil Işık Sürelerini Başlat
next_green_duration_NS = base_green_duration;
next_green_duration_EW = base_green_duration;

% 6. Metrik Depolama Dizilerini Başlat
average_wait_times_over_time = zeros(total_simulation_duration / time_step_size, 4);
queue_lengths_over_time = zeros(total_simulation_duration / time_step_size, 4);
light_durations_over_time = zeros(total_simulation_duration / time_step_size, 3);
log_api_densities = zeros(total_simulation_duration / time_step_size, 2); % API verilerini saklamak için
total_vehicles_passed = 0;

% Data logging for visualization
log_time = zeros(1, total_simulation_duration / time_step_size);
log_vehicle_queues_north = zeros(1, total_simulation_duration / time_step_size);

% Overpass API konfigürasyonunu yükle
try
    fprintf('API yapılandırması yükleniyor...\n');
    config_data = load('config.mat');
    fprintf('API yapılandırması yüklendi: %s koordinatları kullanılacak.\n', ...
        [num2str(config_data.configuration.intersection_location.lat), ', ', ...
         num2str(config_data.configuration.intersection_location.long)]);
catch config_error
    fprintf('API yapılandırması yüklenemedi, yerel trafik hesaplamaları kullanılacak.\n');
end

% Görselleştirme pencerelerini oluştur
h_fig_intersection = figure('Name', 'Kavşak Görselleştirmesi', 'NumberTitle', 'off', 'Position', [100, 300, 600, 500]);
h_fig_metrics = figure('Name', 'Performans Metrikleri', 'NumberTitle', 'off', 'Position', [750, 300, 600, 500]);

fprintf('Simülasyon başlatılıyor...\n');
fprintf('İki ayrı görselleştirme penceresi açılacak.\n\n');

% Ana Simülasyon Döngüsü
for t = 1:time_step_size:total_simulation_duration
    current_time = t;
    fprintf('Zaman: %d s\n', current_time);

    % 1. Yeni Araçları Oluştur
    vehicle_queues = generate_vehicles(vehicle_queues, current_time, arrival_rates, current_arrival_profile, time_step_size);
    fprintf('  Araçlar oluşturuldu.\n');

    % 2. Trafik Işığı Durumunu Güncelle
    [current_light_state, phase_changed, remaining_phase_time] = update_light_state(...
        current_light_state, time_in_current_state, green_duration_NS, green_duration_EW, ...
        yellow_light_duration, time_step_size, strcmp(current_light_state, 'NS_green'));
    
    if phase_changed
        time_in_current_state = 0;
    else
        time_in_current_state = time_in_current_state + time_step_size;
    end
    
    fprintf('  Işık durumları güncellendi. Mevcut durum: %s, Süre: %.1f s\n', current_light_state, time_in_current_state);

    % 2. Overpass API'den gerçek trafik yoğunluğunu al
        try
            % API'den trafik verisini al
            api_traffic_data = traffic_data();
        
            % API'den gelen trafik yoğunluklarını kullan ve değerleri abartılı hale getir
            density_NS = (api_traffic_data.north_density + api_traffic_data.south_density) / 2;
            density_EW = (api_traffic_data.east_density + api_traffic_data.west_density) / 2;
            
            % Yoğunlukları daha belirgin hale getir - kontrast artır
            density_NS = 0.5 + (density_NS - 0.5) * 1.8;  % 0.5'ten uzaklaştır
            density_EW = 0.5 + (density_EW - 0.5) * 1.8;  % 0.5'ten uzaklaştır
            
            % Sınırları kontrol et
            density_NS = max(0.1, min(0.9, density_NS));
            density_EW = max(0.1, min(0.9, density_EW));
            
            % Her 20 simülasyon adımında bir, yoğunlukları karşıt yönlerde rastgele değiştir
            if mod(t, 20) == 0
                % Yoğunlukları ters yönlere ittir
                random_shift = 0.15 * rand();
                if density_NS > density_EW
                    density_NS = density_NS + random_shift;
                    density_EW = density_EW - random_shift;
                else
                    density_NS = density_NS - random_shift;
                    density_EW = density_EW + random_shift;
                end
                % Sınırları tekrar kontrol et
                density_NS = max(0.1, min(0.9, density_NS));
                density_EW = max(0.1, min(0.9, density_EW));
            end
            
            fprintf('  API veri alındı. Gerçek trafik yoğunlukları kullanılıyor (artırılmış).\n');
        catch api_error
            % API çalışmazsa ya da hata verirse, hesaplanan yoğunlukları kullan
            [density_NS, density_EW] = calculate_density(vehicle_queues, approaching_vehicle_time_window, current_light_state);
            
            % Her 20 simülasyon adımında bir, yoğunlukları karşıt yönlerde rastgele değiştir
            if mod(t, 20) == 0
                % Yoğunlukları ters yönlere ittir
                random_shift = 0.2 * rand();
                if density_NS > density_EW
                    density_NS = density_NS + random_shift;
                    density_EW = density_EW - random_shift;
                else
                    density_NS = density_NS - random_shift;
                    density_EW = density_EW + random_shift;
                end
                % Sınırları tekrar kontrol et
                density_NS = max(0.1, min(0.9, density_NS));
                density_EW = max(0.1, min(0.9, density_EW));
            end
            
            fprintf('  API hatası, hesaplanan trafik yoğunlukları kullanılıyor (artırılmış).\n');
        end
        fprintf('  Trafik yoğunlukları hesaplandı. NS: %.2f, EW: %.2f\n', density_NS, density_EW);
    
        % API verilerini loglama
        log_api_densities(t / time_step_size, 1) = density_NS;
        log_api_densities(t / time_step_size, 2) = density_EW;

    % 4. PID Kontrolcü ile Yeşil Işık Süresini Ayarla
    if phase_changed
        if strcmp(current_light_state, 'NS_green')
            % Kuzey-Güney yönü için PID kontrolü
            error_signal = density_NS - density_EW;
            % Hatayı büyüt
            error_signal = error_signal * 2.0;
            [pid_output_NS, integral_term_NS, derivative_NS] = pid_controller(...
                error_signal, PID_gains_NS, previous_error_NS, integral_term_NS, time_step_size);
            % Çıkışı daha büyük bir aralığa yay
            pid_output_NS = pid_output_NS * 1.5;
            next_green_duration_NS = max(min_green_duration, min(max_green_duration, base_green_duration + pid_output_NS));
            previous_error_NS = error_signal;
            green_duration_NS = next_green_duration_NS;
            fprintf('  PID NS için yeni yeşil süre hesaplandı: %.2f s\n', next_green_duration_NS);
        elseif strcmp(current_light_state, 'EW_green')
            % Doğu-Batı yönü için PID kontrolü
            error_signal = density_EW - density_NS;
            % Hatayı büyüt
            error_signal = error_signal * 2.0;
            [pid_output_EW, integral_term_EW, derivative_EW] = pid_controller(...
                error_signal, PID_gains_EW, previous_error_EW, integral_term_EW, time_step_size);
            % Çıkışı daha büyük bir aralığa yay
            pid_output_EW = pid_output_EW * 1.5;
            next_green_duration_EW = max(min_green_duration, min(max_green_duration, base_green_duration + pid_output_EW));
            previous_error_EW = error_signal;
            green_duration_EW = next_green_duration_EW;
            fprintf('  PID EW için yeni yeşil süre hesaplandı: %.2f s\n', next_green_duration_EW);
        end
    end

    % 5. Araçları Hareket Ettir
    [vehicle_queues, vehicles_passed_this_step] = move_vehicles(vehicle_queues, current_light_state, vehicles_per_second_green, time_step_size);
    total_vehicles_passed = total_vehicles_passed + vehicles_passed_this_step;
    fprintf('  Araçlar hareket ettirildi, kuyruklar güncellendi. Bu adımda geçen: %d\n', vehicles_passed_this_step);

    % 6. Metrikleri Kaydet
    [average_wait_times, queue_lengths, light_durations] = record_metrics(...
        t, vehicle_queues, current_light_state, next_green_duration_NS, next_green_duration_EW, yellow_light_duration);
    
    % Metrikleri grafik için sakla
    average_wait_times_over_time(t / time_step_size,:) = [average_wait_times.north, average_wait_times.south, ...
                                                        average_wait_times.east, average_wait_times.west];
    queue_lengths_over_time(t / time_step_size,:) = [queue_lengths.north, queue_lengths.south, ...
                                                   queue_lengths.east, queue_lengths.west];
    light_durations_over_time(t / time_step_size,:) = [light_durations.NS_green, light_durations.EW_green, ...
                                                     light_durations.yellow];
    fprintf('  Metrikler kaydedildi.\n');

    % Görselleştirme için kısa bekleme
    pause(0.01);

    % Her adımda görselleştirme yap
    
    % Kavşak durumunu görselleştir
    figure(h_fig_intersection); % Kavşak figürünü aktif et
    visualize_intersection(vehicle_queues, current_light_state);
    
    % Metrikleri görselleştir
    figure(h_fig_metrics); % Metrik figürünü aktif et
    plot_metrics(queue_lengths_over_time(1:t / time_step_size,:), ...
                average_wait_times_over_time(1:t / time_step_size,:), ...
                light_durations_over_time(1:t / time_step_size,:), ...
                time_step_size, t / time_step_size, current_light_state);
    
    % Simülasyon durumunu göster
    fprintf('Adım: %d/%d, Geçen Araç: %d\n', t / time_step_size, total_simulation_duration / time_step_size, vehicles_passed_this_step);
    fprintf('Kuyruk Uzunlukları - Kuzey: %d, Güney: %d, Doğu: %d, Batı: %d\n', ...
        queue_lengths.north, queue_lengths.south, queue_lengths.east, queue_lengths.west);
    fprintf('Ortalama Bekleme Süreleri - Kuzey: %.1f, Güney: %.1f, Doğu: %.1f, Batı: %.1f\n', ...
        average_wait_times.north, average_wait_times.south, ...
        average_wait_times.east, average_wait_times.west);
    fprintf('Işık Durumu: %s\n', current_light_state);
    fprintf('----------------------------------------\n');
end

fprintf('Simülasyon tamamlandı.\n');

% 7. Performans Metriklerini Göster
fprintf('\nPerformans Metrikleri:\n');
fprintf('Toplam geçen araç: %d\n', total_vehicles_passed);
fprintf('Ortalama bekleme süreleri (K,G,D,B): %.2f, %.2f, %.2f, %.2f saniye\n', ...
    mean(average_wait_times_over_time));
fprintf('Maksimum kuyruk uzunlukları (K,G,D,B): %d, %d, %d, %d araç\n', ...
    max(queue_lengths_over_time));

% 8. Sonuçları Görselleştir - Son görüntü
figure(h_fig_metrics); % Metrik figürünü aktif et
plot_metrics(queue_lengths_over_time, average_wait_times_over_time, light_durations_over_time, ...
            time_step_size, total_simulation_duration / time_step_size, current_light_state);
            
% API verilerini de görselleştir
figure('Name', 'API Trafik Yoğunlukları', 'NumberTitle', 'off', 'Position', [100, 100, 600, 400]);
plot(1:time_step_size:total_simulation_duration, log_api_densities(:,1), 'b-', 'LineWidth', 2);
hold on;
plot(1:time_step_size:total_simulation_duration, log_api_densities(:,2), 'r-', 'LineWidth', 2);
title('API''den Alınan Trafik Yoğunlukları');
xlabel('Zaman (saniye)');
ylabel('Trafik Yoğunluğu');
legend('Kuzey-Güney', 'Doğu-Batı');
grid on;
             
fprintf('Sonuçlar grafiklendi.\n');
fprintf('Simülasyon Sonlandı.\n');