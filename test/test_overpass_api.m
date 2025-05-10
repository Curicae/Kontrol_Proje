% test_overpass_api.m - Overpass API entegrasyonunu test etmek için script
% Bu script, Overpass API'den veri alıp işlemeyi test eder

clc;
clear;
close all;

fprintf('Overpass API test başlatılıyor...\n');

% Klasör yapısını kontrol et ve gerekirse ekle
addpath('../src/api');
fprintf('API modülleri eklendi\n');

% Config dosyasını oluştur
configuration = struct();
configuration.intersection_location = struct(...
    'lat', 41.0370, ...  % Taksim Meydanı
    'long', 28.9850 ...
);
configuration.api_update_interval = 300;
configuration.use_osm = false;
configuration.use_tomtom = false;
configuration.use_overpass = true;
configuration.overpass_radius = 500; % metre cinsinden yarıçap

% Config'i değişkene kaydet
config = configuration;

% Test config'i dosyaya kaydet
save('config_temp.mat', 'config');

% Orijinal config dosyasını yedekle
if exist('../config.mat', 'file')
    copyfile('../config.mat', '../config_backup.mat');
    fprintf('Orijinal config yedeklendi\n');
end

% Test config'i kopyala
copyfile('config_temp.mat', '../config.mat');
fprintf('Test config dosyası oluşturuldu\n');

try
    % traffic_data modülünü test et
    fprintf('\n1. Overpass API çağrısı yapılıyor...\n');
    traffic_data = get_traffic_data();
    
    % Sonuçları görüntüle
    fprintf('\nAPI Sonuçları:\n');
    fprintf('- Kuzey Trafik Yoğunluğu: %.2f\n', traffic_data.north_density);
    fprintf('- Güney Trafik Yoğunluğu: %.2f\n', traffic_data.south_density);
    fprintf('- Doğu Trafik Yoğunluğu: %.2f\n', traffic_data.east_density);
    fprintf('- Batı Trafik Yoğunluğu: %.2f\n', traffic_data.west_density);
    fprintf('- Zaman Damgası: %s\n', char(traffic_data.timestamp));
    
    % Farklı bir kavşak konumu test et
    fprintf('\n2. Farklı bir kavşak için test ediliyor...\n');
    configuration.intersection_location = struct(...
        'lat', 41.0082, ...  % Sultanahmet Meydanı
        'long', 28.9784 ...
    );
    configuration.overpass_radius = 300; % Daha küçük yarıçap
    config = configuration;
    save('../config.mat', 'config'); % Güncelle
    
    traffic_data2 = get_traffic_data();
    
    % 2. sonuçları görüntüle
    fprintf('\nİkinci Konum API Sonuçları:\n');
    fprintf('- Kuzey Trafik Yoğunluğu: %.2f\n', traffic_data2.north_density);
    fprintf('- Güney Trafik Yoğunluğu: %.2f\n', traffic_data2.south_density);
    fprintf('- Doğu Trafik Yoğunluğu: %.2f\n', traffic_data2.east_density);
    fprintf('- Batı Trafik Yoğunluğu: %.2f\n', traffic_data2.west_density);
    fprintf('- Zaman Damgası: %s\n', char(traffic_data2.timestamp));
    
    fprintf('\n3. Başka bir API seçeneğini test ediliyor (OSM)...\n');
    configuration.use_overpass = false;
    configuration.use_osm = true;
    config = configuration;
    save('../config.mat', 'config'); % Güncelle
    
    traffic_data3 = get_traffic_data();
    
    % 3. sonuçları görüntüle
    fprintf('\nOSM API Sonuçları (varsayılan değerler bekleniyor):\n');
    fprintf('- Kuzey Trafik Yoğunluğu: %.2f\n', traffic_data3.north_density);
    fprintf('- Güney Trafik Yoğunluğu: %.2f\n', traffic_data3.south_density);
    fprintf('- Doğu Trafik Yoğunluğu: %.2f\n', traffic_data3.east_density);
    fprintf('- Batı Trafik Yoğunluğu: %.2f\n', traffic_data3.west_density);
    
    % Overpass API'nin performansını test et
    fprintf('\n4. API yanıt süresi testi yapılıyor...\n');
    configuration.use_overpass = true;
    configuration.use_osm = false;
    config = configuration;
    save('../config.mat', 'config'); % Güncelle
    
    tic;
    get_traffic_data();
    elapsed_time = toc;
    fprintf('Overpass API yanıt süresi: %.2f saniye\n', elapsed_time);
    
    % Config'i geri yükle
    if exist('../config_backup.mat', 'file')
        copyfile('../config_backup.mat', '../config.mat');
        fprintf('\nOrijinal config geri yüklendi\n');
    end
    
    % Grafik oluştur
    figure('Name', 'Overpass API Trafik Yoğunluğu Karşılaştırması', 'Position', [100, 100, 800, 400]);
    
    % Taksim Meydanı ve Sultanahmet için trafik yoğunlukları
    locations = {'Taksim Meydanı', 'Sultanahmet Meydanı'};
    
    % Kuzey trafik yoğunlukları
    north_data = [traffic_data.north_density, traffic_data2.north_density];
    south_data = [traffic_data.south_density, traffic_data2.south_density];
    east_data = [traffic_data.east_density, traffic_data2.east_density];
    west_data = [traffic_data.west_density, traffic_data2.west_density];
    
    % Çubuk grafik
    subplot(1, 2, 1);
    bar([north_data; south_data; east_data; west_data]');
    title('Trafik Yoğunluğu Karşılaştırması');
    xlabel('Konum');
    ylabel('Trafik Yoğunluğu');
    set(gca, 'XTickLabel', locations);
    legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
    
    % Pasta grafik (Taksim)
    subplot(1, 2, 2);
    pie([traffic_data.north_density, traffic_data.south_density, traffic_data.east_density, traffic_data.west_density]);
    title('Taksim Meydanı Trafik Dağılımı');
    legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
    
    % Grafiği kaydet
    saveas(gcf, 'overpass_api_test_results.png');
    fprintf('Test sonuç grafiği kaydedildi: overpass_api_test_results.png\n');
    
    fprintf('\nOverpass API testi başarıyla tamamlandı!\n');
    
catch e
    % Hata durumunda config'i geri yükle ve hatayı göster
    if exist('../config_backup.mat', 'file')
        copyfile('../config_backup.mat', '../config.mat');
    end
    fprintf('\nTest sırasında hata oluştu: %s\n', e.message);
    rethrow(e);
end

% Geçici dosyaları temizle
if exist('../config_backup.mat', 'file')
    delete('../config_backup.mat');
end
if exist('config_temp.mat', 'file')
    delete('config_temp.mat');
end
fprintf('Geçici dosyalar temizlendi\n');