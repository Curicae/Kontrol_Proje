% test_overpass_api.m - Overpass API entegrasyonunu test etmek için script
% Bu script, Overpass API'den veri alıp işlemeyi test eder

clc;
clear;
close all;

fprintf('Overpass API test başlatılıyor...\n');

% Klasör yapısını kontrol et ve gerekirse ekle
addpath('..'); % Proje kök dizinini ekle
% addpath('../src'); % Bu satır uyarı veriyordu, kök dizin yeterli olmalı
fprintf('Gerekli yollar eklendi\n');

% Temel test yapılandırmasını oluştur
base_configuration = struct();
base_configuration.intersection_location = struct(...
    'lat', 41.0370, ...  % Taksim Meydanı
    'long', 28.9850 ...
);
base_configuration.api_update_interval = 300;
base_configuration.use_osm = false;
base_configuration.use_tomtom = false;
base_configuration.use_overpass = true;
base_configuration.overpass_radius = 500; % metre cinsinden yarıçap
base_configuration.google_maps_api_key = 'YOUR_TEST_GOOGLE_KEY'; 
base_configuration.tomtom_api_key = 'YOUR_TEST_TOMTOM_KEY';

% Orijinal config dosyasını yedekle ve test config'i hazırla
original_config_exists = false;
if exist('../config.mat', 'file')
    original_config_exists = true;
    copyfile('../config.mat', '../config_backup.mat');
    fprintf('Orijinal config yedeklendi\n');
end

% Her test adımı için kullanılacak anlık yapılandırma
current_test_configuration = base_configuration;
save('../config.mat', 'current_test_configuration'); % Ana config.mat'e 'current_test_configuration' adıyla kaydet
                                                 % traffic_data.m bunu 'configuration' olarak bekliyor.
                                                 % Bu satırı düzeltmemiz LAZIM.
% DOĞRUSU: 
configuration_to_save = base_configuration; % Geçici bir adla değil, doğrudan 'configuration' adıyla kaydedelim
save('../config.mat', 'configuration_to_save'); 
% YADA DAHA İYİSİ, traffic_data.m'nin beklediği gibi 'configuration' adında bir değişkeni kaydetmek:
configuration = base_configuration; % 'configuration' adında bir struct oluştur
save('../config.mat', 'configuration'); % 'configuration' struct'ını 'configuration' adıyla kaydet
fprintf('Test için config.mat dosyası (Taksim) oluşturuldu/güncellendi\n');

try
    % 1. Overpass API çağrısı (Taksim)
    fprintf('\n1. Overpass API çağrısı yapılıyor (Taksim)...\n');
    api_result1 = traffic_data();
    fprintf('API Sonuçları (Konum 1 - Taksim):\n');
    if isstruct(api_result1) && isfield(api_result1, 'north_density')
        fprintf('- Kuzey:%.2f, Güney:%.2f, Doğu:%.2f, Batı:%.2f @ %s\n', api_result1.north_density, api_result1.south_density, api_result1.east_density, api_result1.west_density, char(api_result1.timestamp));
    else
        fprintf('Hatalı veya eksik API sonucu (Taksim)\n');
    end

    % 2. Farklı bir kavşak (Sultanahmet)
    fprintf('\n2. Overpass API çağrısı yapılıyor (Sultanahmet)...\n');
    configuration_sultanahmet = base_configuration;
    configuration_sultanahmet.intersection_location.lat = 41.0082;
    configuration_sultanahmet.intersection_location.long = 28.9784;
    configuration_sultanahmet.overpass_radius = 300;
    save('../config.mat', 'configuration_sultanahmet'); % 'configuration_sultanahmet' adıyla kaydeder
    % DOĞRUSU:
    configuration = configuration_sultanahmet; % Ana 'configuration' struct'ını güncelle
    save('../config.mat', 'configuration');     % 'configuration' adıyla kaydet
    
    api_result2 = traffic_data();
    fprintf('API Sonuçları (Konum 2 - Sultanahmet):\n');
    if isstruct(api_result2) && isfield(api_result2, 'north_density')
        fprintf('- Kuzey:%.2f, Güney:%.2f, Doğu:%.2f, Batı:%.2f @ %s\n', api_result2.north_density, api_result2.south_density, api_result2.east_density, api_result2.west_density, char(api_result2.timestamp));
    else
        fprintf('Hatalı veya eksik API sonucu (Sultanahmet)\n');
    end

    % 3. OSM API testi
    fprintf('\n3. OSM API çağrısı yapılıyor (varsayılan dönmeli)...\n');
    configuration_osm = base_configuration;
    configuration_osm.use_overpass = false;
    configuration_osm.use_osm = true;
    save('../config.mat', 'configuration_osm'); % 'configuration_osm' adıyla kaydeder
    % DOĞRUSU:
    configuration = configuration_osm; % Ana 'configuration' struct'ını güncelle
    save('../config.mat', 'configuration'); % 'configuration' adıyla kaydet

    api_result3 = traffic_data();
    fprintf('OSM API Sonuçları (varsayılan değerler bekleniyor):\n');
    if isstruct(api_result3) && isfield(api_result3, 'north_density')
        fprintf('- Kuzey:%.2f, Güney:%.2f, Doğu:%.2f, Batı:%.2f @ %s\n', api_result3.north_density, api_result3.south_density, api_result3.east_density, api_result3.west_density, char(api_result3.timestamp));
    else
        fprintf('Hatalı veya eksik API sonucu (OSM)\n');
    end

    % 4. Overpass API performans testi
    fprintf('\n4. Overpass API yanıt süresi testi yapılıyor (Taksim)...\n');
    configuration_perf_test = base_configuration; % Taksim ayarlarını geri yükle
    save('../config.mat', 'configuration_perf_test'); % 'configuration_perf_test' adıyla kaydeder
    % DOĞRUSU:
    configuration = configuration_perf_test; % Ana 'configuration' struct'ını güncelle
    save('../config.mat', 'configuration');    % 'configuration' adıyla kaydet

    tic;
    traffic_data();
    elapsed_time = toc;
    fprintf('Overpass API yanıt süresi: %.2f saniye\n', elapsed_time);

    % Config'i geri yükle
    if original_config_exists
        copyfile('../config_backup.mat', '../config.mat');
        fprintf('\nOrijinal config geri yüklendi\n');
    elseif exist('../config.mat', 'file') % Eğer orijinal yoksa ve test bir config oluşturduysa sil
        delete('../config.mat');
        fprintf('\nTest için oluşturulan config.mat silindi.\n');
    end

    % Grafik oluştur (api_result1 ve api_result2'yi kullan)
    if exist('api_result1', 'var') && exist('api_result2', 'var') && isstruct(api_result1) && isstruct(api_result2) && isfield(api_result1, 'north_density') && isfield(api_result2, 'north_density')
        figure('Name', 'Overpass API Trafik Yoğunluğu Karşılaştırması', 'Position', [100, 100, 800, 400]);
        locations = {'Taksim Meydanı', 'Sultanahmet Meydanı'};
        north_data = [api_result1.north_density, api_result2.north_density];
        south_data = [api_result1.south_density, api_result2.south_density];
        east_data = [api_result1.east_density, api_result2.east_density];
        west_data = [api_result1.west_density, api_result2.west_density];
        subplot(1, 2, 1);
        bar([north_data; south_data; east_data; west_data]');
        title('Trafik Yoğunluğu Karşılaştırması'); xlabel('Konum'); ylabel('Trafik Yoğunluğu');
        set(gca, 'XTickLabel', locations);
        legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
        subplot(1, 2, 2);
        pie([api_result1.north_density, api_result1.south_density, api_result1.east_density, api_result1.west_density]);
        title('Taksim Meydanı Trafik Dağılımı');
        legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
        saveas(gcf, 'overpass_api_test_results.png');
        fprintf('Test sonuç grafiği kaydedildi: overpass_api_test_results.png\n');
    else
        fprintf('Grafik oluşturmak için yeterli veri yok veya API sonuçları hatalı.\n');
    end

    fprintf('\nOverpass API testi başarıyla tamamlandı!\n');

catch e
    if original_config_exists
        copyfile('../config_backup.mat', '../config.mat');
    end
    fprintf('\nTest sırasında hata oluştu: %s\n', e.message);
    fprintf('Hata kaynağı: %s, Satır: %d\n', e.stack(1).file, e.stack(1).line);
end

if original_config_exists && exist('../config_backup.mat', 'file')
    delete('../config_backup.mat');
end
% config_temp.mat silinmişti, tekrar silmeye gerek yok
% if exist('config_temp.mat', 'file') 
% delete('config_temp.mat');
% end
fprintf('Geçici dosyalar temizlendi\n');