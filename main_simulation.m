% main_simulation.m - PID Kontrollü Trafik Işığı Simülasyonu
% Ana simülasyon dosyası

clear;
clc;
close all;

% MATLAB path ayarları
addpath('src/traffic');
addpath('src/control');
addpath('src/metrics');
addpath('utils');

fprintf('Trafik Işığı Simülasyonu Başlatılıyor...\n');

% 1. Parametreleri Yükle
run('initialize_parameters.m');
fprintf('Parametreler yüklendi.\n');

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
total_vehicles_passed = 0;

% Data logging for visualization
log_time = zeros(1, total_simulation_duration / time_step_size);
log_vehicle_queues_north = zeros(1, total_simulation_duration / time_step_size);

% Görselleştirme pencerelerini oluştur
figure('Name', 'Trafik Işığı Kavşağı', 'NumberTitle', 'off', 'Position', [100, 100, 800, 800]);
figure('Name', 'Trafik Işığı Simülasyonu', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);

fprintf('Simülasyon başlatılıyor...\n');
fprintf('İki görselleştirme penceresi açılacak:\n');
fprintf('1. Trafik Işığı Kavşağı\n');
fprintf('2. Metrik Grafikleri\n\n');

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

    % 3. Trafik Yoğunluğunu Hesapla
    [density_NS, density_EW] = calculate_density(vehicle_queues, approaching_vehicle_time_window, current_light_state);
    fprintf('  Trafik yoğunlukları hesaplandı. NS: %.2f, EW: %.2f\n', density_NS, density_EW);

    % 4. PID Kontrolcü ile Yeşil Işık Süresini Ayarla
    if phase_changed
        if strcmp(current_light_state, 'NS_green')
            % Kuzey-Güney yönü için PID kontrolü
            error_signal = density_NS - density_EW;
            [pid_output_NS, integral_term_NS, derivative_NS] = pid_controller(...
                error_signal, PID_gains_NS, previous_error_NS, integral_term_NS, time_step_size);
            next_green_duration_NS = max(min_green_duration, min(max_green_duration, base_green_duration + pid_output_NS));
            previous_error_NS = error_signal;
            green_duration_NS = next_green_duration_NS;
            fprintf('  PID NS için yeni yeşil süre hesaplandı: %.2f s\n', next_green_duration_NS);
        elseif strcmp(current_light_state, 'EW_green')
            % Doğu-Batı yönü için PID kontrolü
            error_signal = density_EW - density_NS;
            [pid_output_EW, integral_term_EW, derivative_EW] = pid_controller(...
                error_signal, PID_gains_EW, previous_error_EW, integral_term_EW, time_step_size);
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
    figure(1);
    clf; % Mevcut figure'ı temizle
    visualize_intersection(vehicle_queues, current_light_state);
    
    % Metrikleri görselleştir
    figure(2);
    clf; % Mevcut figure'ı temizle
    plot_metrics(queue_lengths_over_time(1:t / time_step_size,:), ...
        average_wait_times_over_time(1:t / time_step_size,:), ...
        light_durations_over_time(1:t / time_step_size,:), ...
        time_step_size, t / time_step_size);
    
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

% 8. Sonuçları Görselleştir
plot_metrics(queue_lengths_over_time, average_wait_times_over_time, light_durations_over_time, ...
            time_step_size, total_simulation_duration / time_step_size);
fprintf('Sonuçlar grafiklendi.\n');

fprintf('Simülasyon Sonlandı.\n');

% Placeholder for function calls - these will be separate .m files
% function [queues] = generate_vehicles(queues, time, rates, dt) disp('generate_vehicles called'); end
% function [lights, changed] = update_light_state(lights, time, phase_dur, yellow_dur, next_g_ns, next_g_ew) changed=false; disp('update_light_state called'); end
% function [density_ns, density_ew] = calculate_density(queues, approaching_params, lights) density_ns=0; density_ew=0; disp('calculate_density called'); end
% function [output] = pid_controller(error, gains, prev_error, integral, dt) output=0; disp('pid_controller called'); end
% function [queues, passed] = move_vehicles(queues, lights, vpsg) passed=0; disp('move_vehicles called'); end
% function record_metrics(idx, varargin) disp('record_metrics called'); end
% function metrics_summary = calculate_performance_metrics(varargin) metrics_summary=struct(); disp('calculate_performance_metrics called'); end
% function plot_metrics(varargin) disp('plot_metrics called'); end 