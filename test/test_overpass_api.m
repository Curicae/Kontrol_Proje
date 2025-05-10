% test_overpass_api.m - Overpass API bağlantısını test etmek için script
% Bu script trafiği simüle etmek için gerçek trafik verisi almayı dener

fprintf('=== Overpass API Testi ===\n\n');

% Config dosyasını yükle
try
    config_data = load('../config.mat');
    configuration = config_data.configuration;
    
    fprintf('Mevcut yapılandırma:\n');
    fprintf('Lokasyon: Enlem=%.4f, Boylam=%.4f\n', ...
            configuration.intersection_location.lat, ...
            configuration.intersection_location.long);
    fprintf('Arama yarıçapı: %d metre\n\n', configuration.overpass_radius);
catch
    fprintf('Config dosyası bulunamadı. Varsayılan değerler kullanılacak.\n');
    configuration = struct();
    configuration.intersection_location = struct('lat', 41.0370, 'long', 28.9850);
    configuration.overpass_radius = 500;
end

% API URL tanımı
url = 'https://overpass-api.de/api/interpreter';
fprintf('API URL: %s\n\n', url);

% Overpass QL sorgusu
query = sprintf('[out:json];way["highway"](around:%d,%.6f,%.6f);out body;>;out skel;', ...
    configuration.overpass_radius, ...
    configuration.intersection_location.lat, ...
    configuration.intersection_location.long);

fprintf('Sorgu gönderiliyor...\n');
fprintf('Sorgu içeriği:\n%s\n\n', query);

% HTTP isteği yapma
try
    options = weboptions('MediaType', 'application/x-www-form-urlencoded', 'Timeout', 30);
    tic;
    fprintf('API isteği yapılıyor...\n');
    response = webwrite(url, 'data', query, options);
    fetch_time = toc;
    fprintf('API yanıtı %.2f saniyede alındı.\n\n', fetch_time);
    
    % Yanıt kontrolü
    if isstruct(response) && isfield(response, 'elements')
        elements = response.elements;
        fprintf('Yanıt alındı: %d eleman içeriyor\n', length(elements));
        
        % Eleman türlerini say
        node_count = 0;
        way_count = 0;
        relation_count = 0;
        
        for i = 1:length(elements)
            if strcmp(elements(i).type, 'node')
                node_count = node_count + 1;
            elseif strcmp(elements(i).type, 'way')
                way_count = way_count + 1;
            elseif strcmp(elements(i).type, 'relation')
                relation_count = relation_count + 1;
            end
        end
        
        fprintf('Bulunan node sayısı: %d\n', node_count);
        fprintf('Bulunan way sayısı: %d\n', way_count);
        fprintf('Bulunan relation sayısı: %d\n\n', relation_count);
        
        % Yol türlerini analiz et
        if way_count > 0
            highway_types = struct();
            for i = 1:length(elements)
                if strcmp(elements(i).type, 'way') && isfield(elements(i), 'tags') && isfield(elements(i).tags, 'highway')
                    highway_type = elements(i).tags.highway;
                    if isfield(highway_types, highway_type)
                        highway_types.(highway_type) = highway_types.(highway_type) + 1;
                    else
                        highway_types.(highway_type) = 1;
                    end
                end
            end
            
            % Yol tiplerini yazdır
            fprintf('Yol tipleri dağılımı:\n');
            highway_fields = fieldnames(highway_types);
            for i = 1:length(highway_fields)
                fprintf('  %s: %d\n', highway_fields{i}, highway_types.(highway_fields{i}));
            end
        end
        
        % Trafik yoğunluğunu hesapla
        fprintf('\nTrafik yoğunluğu hesaplanıyor...\n');
        % Ana işleme fonksiyonunu doğrudan çağırıyoruz
        addpath('..');  % Ana dizine path ekle
        [full_path, ~, ~] = fileparts(mfilename('fullpath'));
        old_dir = pwd;
        cd('..');  % Ana dizine geç
        
        try
            traffic_data_output = traffic_data();
            cd(old_dir);  % Eski dizine geri dön
            
            fprintf('\nHesaplanan trafik yoğunlukları:\n');
            fprintf('Kuzey: %.2f\n', traffic_data_output.north_density);
            fprintf('Güney: %.2f\n', traffic_data_output.south_density);
            fprintf('Doğu: %.2f\n', traffic_data_output.east_density);
            fprintf('Batı: %.2f\n', traffic_data_output.west_density);
            fprintf('Hesaplama zamanı: %s\n', traffic_data_output.timestamp);
            
            % Başarılı test mesajı
            fprintf('\n=== Overpass API testi BAŞARILI ===\n');
            fprintf('Trafik verilerine erişim sağlandı ve yoğunluk hesaplandı.\n');
        catch e
            cd(old_dir);  % Hata durumunda da eski dizine dönmeyi unutma
            fprintf('\nTraffic_data fonksiyonu hatası: %s\n', e.message);
        end
    else
        fprintf('API yanıtı beklenen formatta değil.\n');
    end
    
catch e
    fprintf('API isteği başarısız: %s\n', e.message);
end

fprintf('\nTesti sonlandırmak için herhangi bir tuşa basın...\n');
pause;