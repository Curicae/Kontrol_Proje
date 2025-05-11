% run_config.m - Trafik Simülasyonu için yapılandırma ayarlarını yapar
% Bu script config.m dosyasını çalıştırır ve değişikliklerinizi kaydeder

% Genel yapılandırma seçenekleri
fprintf('=== Trafik Simülasyonu Yapılandırması ===\n\n');

% Değişkenlerin çakışmaması için configuration yapısı oluştur
configuration = struct();

% Kavşak koordinatlarını tanımla
fprintf('Kavşak koordinatlarını ayarlayın:\n');
default_lat = 41.0370; % Taksim Meydanı varsayılan
default_long = 28.9850;

input_lat = input(sprintf('Enlem [%.4f]: ', default_lat));
input_long = input(sprintf('Boylam [%.4f]: ', default_long));

% Boş giriş durumunda varsayılan değerleri kullan
if isempty(input_lat)
    input_lat = default_lat;
end
if isempty(input_long)
    input_long = default_long;
end

configuration.intersection_location = struct(...
    'lat', input_lat, ...
    'long', input_long ...
);

% API Seçimi
fprintf('\nHangi API kullanılsın?\n');
fprintf('1) Overpass API (ücretsiz, API anahtarı gerektirmez)\n');
fprintf('2) OpenStreetMap API\n');
fprintf('3) TomTom API (API anahtarı gerektirir)\n');
fprintf('4) API kullanma (varsayılan değerleri kullan)\n');

api_choice = input('Seçiminiz [1-4] (Varsayılan: 1): ');
if isempty(api_choice)
    api_choice = 1;
end

% API ayarlarını yapılandır
configuration.use_overpass = false;
configuration.use_osm = false;
configuration.use_tomtom = false;

switch api_choice
    case 1
        configuration.use_overpass = true;
        fprintf('Overpass API seçildi\n');
        configuration.overpass_radius = input('Arama yarıçapı (metre) [500]: ');
        if isempty(configuration.overpass_radius)
            configuration.overpass_radius = 500;
        end
    case 2
        configuration.use_osm = true;
        fprintf('OpenStreetMap API seçildi\n');
    case 3
        configuration.use_tomtom = true;
        fprintf('TomTom API seçildi\n');
        api_key = input('TomTom API Anahtarınızı girin: ', 's');
        if ~isempty(api_key)
            configuration.tomtom_api_key = api_key;
        else
            configuration.tomtom_api_key = 'YOUR_TOMTOM_API_KEY';
            fprintf('API anahtarı girilmedi, bir anahtar eklemeniz gerekecek\n');
        end
    case 4
        fprintf('API kullanılmayacak, varsayılan değerler kullanılacak\n');
    otherwise
        configuration.use_overpass = true;
        fprintf('Geçersiz seçim, varsayılan olarak Overpass API seçildi\n');
end

% API güncelleme aralığını ayarla
configuration.api_update_interval = input('\nAPI güncelleme aralığı (saniye) [300]: ');
if isempty(configuration.api_update_interval)
    configuration.api_update_interval = 300;
end

% Google Maps API anahtarı (kullanılmasa bile kaydedelim)
configuration.google_maps_api_key = 'YOUR_GOOGLE_MAPS_API_KEY';

% Değişiklikleri kaydet
save('config.mat', 'configuration');

% Yapılandırma özeti
fprintf('\n=== Yapılandırma Özeti ===\n');
fprintf('Kavşak Konumu: %.4f, %.4f\n', configuration.intersection_location.lat, configuration.intersection_location.long);

if configuration.use_overpass
    fprintf('API: Overpass API (Yarıçap: %d metre)\n', configuration.overpass_radius);
elseif configuration.use_osm
    fprintf('API: OpenStreetMap API\n');
elseif configuration.use_tomtom
    fprintf('API: TomTom API\n');
else
    fprintf('API: Kullanılmıyor\n');
end

fprintf('API Güncelleme Aralığı: %d saniye\n', configuration.api_update_interval);
fprintf('\nYapılandırma "config.mat" dosyasına kaydedildi.\n');
fprintf('Simülasyonu başlatmak için "main_simulation" komutunu çalıştırın.\n');
fprintf('===========================================\n');