function [traffic_data] = get_traffic_data()
    % Gerçek zamanlı trafik verisi alır
    % Çıktılar:
    %   traffic_data: Trafik yoğunluğu ve araç sayıları
    
    % Config dosyasını yükle
    load('config.mat');
    
    % API'den veri al
    if config.use_overpass
        % Overpass API kullan (API anahtarı gerektirmez)
        url = 'https://overpass-api.de/api/interpreter';
        
        % Overpass QL sorgusu: Belirtilen kavşak çevresindeki yolları sorgula
        query = sprintf('[out:json];way["highway"](around:%d,%.6f,%.6f);out body;>;out skel;', ...
            config.overpass_radius, ...
            config.intersection_location.lat, ...
            config.intersection_location.long);
        
        % HTTP isteği yap (webwrite kullanarak POST)
        try
            options = weboptions('MediaType', 'application/x-www-form-urlencoded');
            response = webwrite(url, 'data', query, options);
            
            % Veriyi işle
            traffic_data = process_overpass_data(response, config.intersection_location);
            fprintf('Overpass API başarıyla çağrıldı.\n');
        catch e
            warning('Overpass API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data = get_default_traffic_data();
        end
    elseif config.use_osm
        % OpenStreetMap API kullan
        url = sprintf('https://api.openstreetmap.org/api/0.6/map?bbox=%.6f,%.6f,%.6f,%.6f', ...
            config.intersection_location.long-0.001, ...
            config.intersection_location.lat-0.001, ...
            config.intersection_location.long+0.001, ...
            config.intersection_location.lat+0.001);
        
        try
            response = webread(url);
            % Veriyi işle
            traffic_data = process_osm_data(response);
        catch e
            warning('OSM API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data = get_default_traffic_data();
        end
    elseif config.use_tomtom
        % TomTom API kullan
        url = sprintf('https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json?key=%s&point=%.6f,%.6f', ...
            config.tomtom_api_key, ...
            config.intersection_location.lat, ...
            config.intersection_location.long);
        
        try
            response = webread(url);
            % Veriyi işle
            traffic_data = process_tomtom_data(response);
        catch e
            warning('TomTom API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data = get_default_traffic_data();
        end
    else
        % API kullanılmıyor, varsayılan değerleri kullan
        warning('API seçeneği etkinleştirilmedi, varsayılan değerler kullanılıyor');
        traffic_data = get_default_traffic_data();
    end
end

function traffic_data = process_overpass_data(response, intersection_location)
    % Overpass API verisini işle ve trafik yoğunluklarını hesapla
    traffic_data = struct();
    
    % Varsayılan değerler (API hatasında kullanmak için)
    traffic_data.north_density = 0.5;
    traffic_data.south_density = 0.5; 
    traffic_data.east_density = 0.5;
    traffic_data.west_density = 0.5;
    traffic_data.timestamp = datetime('now');
    
    try
        % Yanıttaki yol sayısını ve türünü analiz et
        elements = response.elements;
        
        % Yol segmentlerini ayır
        ways = elements(strcmp({elements.type}, 'way'));
        
        if isempty(ways)
            warning('Belirtilen bölgede yol bulunamadı.');
            return;
        end
        
        % Yolları cardinal yönlere göre kategorize et (kuzey-güney-doğu-batı)
        north_ways = 0;
        south_ways = 0;
        east_ways = 0;
        west_ways = 0;
        
        % Eğer nodes bilgisi varsa, işle
        % Yanıtta node koordinatlarını içeren elemanları bul
        nodes = elements(strcmp({elements.type}, 'node'));
        node_map = containers.Map('KeyType', 'double', 'ValueType', 'any');
        
        % Her node'un koordinatlarını ID'ye göre eşleştir
        for i = 1:length(nodes)
            node = nodes(i);
            node_map(node.id) = [node.lat, node.lon];
        end
        
        % Her yol için yönünü belirle
        for i = 1:length(ways)
            % Yol özelliklerini analiz et
            way = ways(i);
            
            % Yönü hesapla (yol node'larının konumlarına göre)
            if isfield(way, 'nodes') && length(way.nodes) >= 2
                % Yolun başlangıç ve bitiş node'larını bul
                first_node_id = way.nodes(1);
                last_node_id = way.nodes(end);
                
                % Node ID'leri node_map'te var mı kontrol et
                if node_map.isKey(first_node_id) && node_map.isKey(last_node_id)
                    first_node_coord = node_map(first_node_id);
                    last_node_coord = node_map(last_node_id);
                    
                    % Koordinat farkına göre yönü hesapla
                    lat_diff = last_node_coord(1) - first_node_coord(1);
                    lon_diff = last_node_coord(2) - first_node_coord(2);
                    
                    % Yolun genel yönünü belirle
                    if abs(lat_diff) > abs(lon_diff)
                        % Kuzey-Güney yönü baskın
                        if lat_diff > 0
                            north_ways = north_ways + 1;
                        else
                            south_ways = south_ways + 1;
                        end
                    else
                        % Doğu-Batı yönü baskın
                        if lon_diff > 0
                            east_ways = east_ways + 1;
                        else
                            west_ways = west_ways + 1;
                        end
                    end
                end
            end
            
            % Yol türüne göre ağırlık faktörü (highways daha fazla trafik)
            if isfield(way, 'tags') && isfield(way.tags, 'highway')
                highway_type = way.tags.highway;
                % Ana yollar daha yüksek ağırlıklı
                if strcmp(highway_type, 'motorway') || strcmp(highway_type, 'trunk') || ...
                   strcmp(highway_type, 'primary') || strcmp(highway_type, 'secondary')
                    % Önemli yollar için sayıları arttır
                    if abs(lat_diff) > abs(lon_diff)
                        if lat_diff > 0
                            north_ways = north_ways + 2;
                        else
                            south_ways = south_ways + 2;
                        end
                    else
                        if lon_diff > 0
                            east_ways = east_ways + 2;
                        else
                            west_ways = west_ways + 2;
                        end
                    end
                end
            end
        end
        
        % Yol sayılarını göreli trafik yoğunluğuna dönüştür (0.1 ile 1.0 arası)
        total_ways = north_ways + south_ways + east_ways + west_ways;
        if total_ways > 0
            traffic_data.north_density = min(1.0, max(0.1, north_ways / total_ways * 2));
            traffic_data.south_density = min(1.0, max(0.1, south_ways / total_ways * 2));
            traffic_data.east_density = min(1.0, max(0.1, east_ways / total_ways * 2));
            traffic_data.west_density = min(1.0, max(0.1, west_ways / total_ways * 2));
        end
        
        traffic_data.timestamp = datetime('now');
        
        fprintf('Overpass verileri işlendi. Yol sayıları - Kuzey: %d, Güney: %d, Doğu: %d, Batı: %d\n', ...
            north_ways, south_ways, east_ways, west_ways);
    catch e
        warning('Overpass veri işleme hatası: %s', e.message);
    end
end

function traffic_data = process_osm_data(response)
    % OSM verisini işle
    traffic_data = struct();
    % OSM veri işleme mantığı (Overpass'a benzer olabilir)
    traffic_data = get_default_traffic_data();
end

function traffic_data = process_tomtom_data(response)
    % TomTom verisini işle
    traffic_data = struct();
    % TomTom veri işleme mantığı
    traffic_data = get_default_traffic_data();
end

function traffic_data = get_default_traffic_data()
    % Varsayılan trafik verisi
    traffic_data = struct(...
        'north_density', 0.5, ...
        'south_density', 0.5, ...
        'east_density', 0.5, ...
        'west_density', 0.5, ...
        'timestamp', datetime('now') ...
    );
end