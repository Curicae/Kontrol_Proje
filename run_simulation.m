% run_simulation.m - Ana simülasyon başlatma scripti
% Bu script, trafik ışığı simülasyonunu adım adım başlatır
% ve olası hataları düzeltmeye çalışır

clc; clear; close all;
fprintf('=== Trafik Işığı Simülasyonu Başlatılıyor ===\n\n');

% 1. Proje yollarını düzenle
fprintf('1. MATLAB yolları düzenleniyor...\n');
try
    % Proje dizininde olduğumuzdan emin olalım
    current_dir = pwd;
    [~, current_folder] = fileparts(current_dir);
    if ~strcmp(current_folder, 'Kontrol_Proje')
        if exist('Kontrol_Proje', 'dir')
            cd('Kontrol_Proje');
            fprintf('  Ana proje dizinine geçildi.\n');
        else
            error('Lütfen scripti Kontrol_Proje dizininde veya üst dizininde çalıştırın.');
        end
    end
    
    % Yolları temizle ve yeniden ekle
    addpath(genpath('src'));
    addpath('utils');
    
    % API dosyasını ana dizine kopyala (get_traffic_data erişimi için)
    if exist(fullfile('src', 'api', 'traffic_data.m'), 'file')
        copyfile(fullfile('src', 'api', 'traffic_data.m'), 'traffic_data.m', 'f');
    end
    
    fprintf('  MATLAB yolları düzenlendi.\n');
catch err
    fprintf('  [!] Yol düzenlemesi sırasında hata: %s\n', err.message);
    fprintf('      fix_matlab_path.m dosyasını çalıştırın ve tekrar deneyin.\n');
    return;
end

% 2. Yapılandırma dosyasını oluştur
fprintf('\n2. Yapılandırma ayarları oluşturuluyor...\n');
try
    % Yapılandırma oluşturma (config dosyası çakışmasını önleyerek)
    configuration = struct();
    configuration.intersection_location = struct('lat', 41.0370, 'long', 28.9850);
    configuration.api_update_interval = 300;
    configuration.use_osm = false;
    configuration.use_tomtom = false;
    configuration.use_overpass = true;
    configuration.overpass_radius = 500;
    
    % traffic_config ismiyle kaydet (çakışmayı önlemek için)
    traffic_config = configuration; 
    save('traffic_config.mat', 'traffic_config');
    fprintf('  Yapılandırma dosyası oluşturuldu: traffic_config.mat\n');
catch err
    fprintf('  [!] Yapılandırma oluşturulurken hata: %s\n', err.message);
    return;
end

% 3. Parametreleri yükle
fprintf('\n3. Simülasyon parametreleri yükleniyor...\n');
try
    run('initialize_parameters.m');
    fprintf('  Parametreler başarıyla yüklendi.\n');
catch err
    fprintf('  [!] Parametre yüklemesinde hata: %s\n', err.message);
    return;
end

% 4. API testi yap
fprintf('\n4. API erişimi test ediliyor...\n');
try
    if exist('get_traffic_data', 'file') ~= 2
        warning('get_traffic_data fonksiyonu bulunamadı. API devre dışı kalacak.');
    else
        api_test_result = get_traffic_data();
        fprintf('  API testi başarılı! Örnek yoğunluk değerleri:\n');
        fprintf('  - Kuzey: %.2f, Güney: %.2f, Doğu: %.2f, Batı: %.2f\n', ...
            api_test_result.north_density, api_test_result.south_density, ...
            api_test_result.east_density, api_test_result.west_density);
    end
catch err
    fprintf('  [!] API testinde hata: %s\n', err.message);
    fprintf('      API kullanılmadan devam edilecek.\n');
end

% 5. Ana simülasyonu başlat
fprintf('\n5. Ana simülasyon başlatılıyor...\n');
try
    % Ana simülasyon dosyasını çalıştır
    run('main_simulation.m');
    fprintf('  Simülasyon başarıyla tamamlandı!\n');
catch err
    fprintf('  [!] Simülasyon sırasında hata: %s\n', err.message);
    fprintf('  Hata konumu: %s (%d. satır)\n', err.stack(1).name, err.stack(1).line);
    return;
end

fprintf('\n=== Simülasyon Tamamlandı ===\n');
fprintf('Sonuçlar grafiklerle gösteriliyor. Grafik pencerelerini kapatmak için herhangi bir tuşa basın.\n');
pause;
close all;
fprintf('Grafik pencereleri kapatıldı.\n');