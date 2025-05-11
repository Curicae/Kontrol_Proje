% run_traffic_simulation.m
% Ana program - trafik simülasyonu ve görselleştirme
% Bu script, trafik simülasyonunu çalıştırır ve sonuçları görselleştirir

fprintf('Trafik Kontrol Sistemi Simülasyonu ve Görselleştirme\n');
fprintf('====================================================\n\n');

% 1. Yeni bir simülasyon çalıştır veya mevcut verileri kullan
try_simulation = true;
simulation_success = false;
use_simple_test_model = true;
use_advanced_viz = true;

% Ana trafik modelini çalıştırmayı dene
if try_simulation
    fprintf('Ana simülasyon deneniyor...\n');
    try
        % İki seçenek:
        % - run_simulation.m dosyası varsa onu çalıştır
        % - Veya run_simulation_with_visualization fonksiyonunu çağır
        
        if exist('run_simulation.m', 'file')
            run('run_simulation.m');
            simulation_success = true;
            fprintf('Ana simülasyon başarıyla çalıştırıldı.\n');
        elseif exist('run_simulation_with_visualization.m', 'file')
            run_simulation_with_visualization();
            simulation_success = true;
            fprintf('Ana simülasyon görselleştirme ile birlikte başarıyla çalıştırıldı.\n');
        else
            fprintf('Simülasyon scriptleri bulunamadı.\n');
        end
    catch ME_main
        fprintf('Ana simülasyon çalıştırılırken hata oluştu: %s\n', ME_main.message);
    end
end

% 2. Eğer ana simülasyon başarısız olduysa, basit test modelini dene
if ~simulation_success && use_simple_test_model
    fprintf('Basit test modeli deneniyor...\n');
    try
        % Gerekli tüm fonksiyonlar yüklenmiş mi kontrol et
        if exist('run_simple_test_model', 'function')
            [test_success, test_tout, test_yout] = run_simple_test_model();
            if test_success
                fprintf('Basit test modeli başarıyla çalıştırıldı.\n');
                simulation_success = true;
                % Değişkenleri genel workspace'e aktar
                assignin('base', 't', test_tout);
                assignin('base', 'queue_lengths', test_yout);
                % Uyumluluk için ekstra değişkenler ekle
                assignin('base', 'log_time', test_tout);
                assignin('base', 'log_vehicle_queues', test_yout);
            else
                fprintf('Basit test modeli başarısız oldu.\n');
            end
        else
            fprintf('run_simple_test_model fonksiyonu bulunamadı.\n');
        end
    catch ME_test
        fprintf('Basit test modeli çalıştırılırken hata oluştu: %s\n', ME_test.message);
    end
end

% 3. Eğer simülasyon çalışmadıysa, sentetik test verisi oluştur
if ~simulation_success
    fprintf('Simülasyon çalıştırılamadı. Sentetik test verisi oluşturuluyor...\n');
    try
        run('test_visualization.m');
        fprintf('Sentetik test verisi başarıyla oluşturuldu ve görselleştirildi.\n');
    catch ME_synth
        fprintf('Sentetik veri oluşturulurken hata: %s\n', ME_synth.message);
        
        % En basit veri oluştur
        t = 0:0.01:5;
        t = t(:);
        queue_data = [5*sin(t/2).^2, 4*sin((t+1)/2).^2];
        queue_data = max(0, queue_data);
        
        % Workspace'e aktar
        assignin('base', 't', t);
        assignin('base', 'queue_lengths', queue_data);
        assignin('base', 'log_time', t);
        assignin('base', 'log_vehicle_queues', queue_data);
        
        fprintf('Temel sentetik veri oluşturuldu.\n');
    end
end

% 4. Görselleştirme işlemlerini gerçekleştir
fprintf('\nGörselleştirme başlatılıyor...\n');

try
    % Temel görselleştirme
    if exist('traffic_visualization.m', 'file') || exist('traffic_visualization', 'function')
        traffic_visualization();
        fprintf('Temel görselleştirme başarıyla gerçekleştirildi.\n');
    else
        fprintf('traffic_visualization fonksiyonu bulunamadı.\n');
    end
    
    % Gelişmiş görselleştirme
    if use_advanced_viz && (exist('advanced_traffic_viz.m', 'file') || exist('advanced_traffic_viz', 'function'))
        fprintf('\nGelişmiş görselleştirme başlatılıyor...\n');
        advanced_traffic_viz();
        fprintf('Gelişmiş görselleştirme başarıyla gerçekleştirildi.\n');
    end
catch ME_viz
    fprintf('Görselleştirme işlemi sırasında hata oluştu: %s\n', ME_viz.message);
end

fprintf('\nTrafik Kontrol Sistemi Simülasyonu ve Görselleştirme işlemi tamamlandı.\n'); 