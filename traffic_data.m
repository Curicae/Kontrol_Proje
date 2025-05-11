function [traffic_data_output] = traffic_data()
    % Gerçek zamanlı trafik verisi alır
    % Çıktılar:
    %   traffic_data_output: Trafik yoğunluğu ve araç sayıları
    
    % Config dosyasını yükle - değişken adı çakışmasını önlemek için
    config_data = load('config.mat');
    % config_settings = config_data.config; % BU SATIR DAHA ÖNCE DÜZELTİLMİŞTİ, DOĞRUSU:
    config_settings = config_data.configuration;
    
    % API'den veri al
    if config_settings.use_overpass
        % Overpass API kullan (API anahtarı gerektirmez)
        url = 'https://overpass-api.de/api/interpreter';
        
        % Overpass QL sorgusu: Belirtilen kavşak çevresindeki yolları sorgula
        query = sprintf('[out:json];way["highway"](around:%d,%.6f,%.6f);out body;>;out skel;', ...
            config_settings.overpass_radius, ...
            config_settings.intersection_location.lat, ...
            config_settings.intersection_location.long);
        
        % HTTP isteği yap (webwrite kullanarak POST)
        try
            options = weboptions('MediaType', 'application/x-www-form-urlencoded');
            response = webwrite(url, 'data', query, options);
            
            % Veriyi işle
            traffic_data_output = process_overpass_data(response, config_settings.intersection_location);
            fprintf('Overpass API başarıyla çağrıldı.\n');
        catch e
            warning('TRAFFICSIM:OverpassAPIError', 'Overpass API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data_output = get_default_traffic_data();
        end
    elseif config_settings.use_osm
        % OpenStreetMap API kullan
        url = sprintf('https://api.openstreetmap.org/api/0.6/map?bbox=%.6f,%.6f,%.6f,%.6f', ...
            config_settings.intersection_location.long-0.001, ...
            config_settings.intersection_location.lat-0.001, ...
            config_settings.intersection_location.long+0.001, ...
            config_settings.intersection_location.lat+0.001);
        
        try
            response = webread(url);
            % Veriyi işle
            traffic_data_output = process_osm_data(response);
        catch e
            warning('TRAFFICSIM:OSMAPIError', 'OSM API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data_output = get_default_traffic_data();
        end
    elseif config_settings.use_tomtom
        % TomTom API kullan
        url = sprintf('https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/10/json?key=%s&point=%.6f,%.6f', ...
            config_settings.tomtom_api_key, ...
            config_settings.intersection_location.lat, ...
            config_settings.intersection_location.long);
        
        try
            response = webread(url);
            % Veriyi işle
            traffic_data_output = process_tomtom_data(response);
        catch e
            warning('TRAFFICSIM:TomTomAPIError', 'TomTom API hatası: %s, varsayılan değerler kullanılıyor', e.message);
            traffic_data_output = get_default_traffic_data();
        end
    else
        % API kullanılmıyor, varsayılan değerleri kullan
        warning('TRAFFICSIM:APINotEnabled','API seçeneği etkinleştirilmedi, varsayılan değerler kullanılıyor');
        traffic_data_output = get_default_traffic_data();
    end
end

function traffic_data_output = process_overpass_data(response, intersection_location)
    % Overpass API verisini işle ve trafik yoğunluklarını hesapla
    traffic_data_output = struct();
    
    % Varsayılan değerler (API hatasında kullanmak için)
    traffic_data_output.north_density = 0.5;
    traffic_data_output.south_density = 0.5; 
    traffic_data_output.east_density = 0.5;
    traffic_data_output.west_density = 0.5;
    traffic_data_output.timestamp = datetime('now');
    
    % Yanıtın yapısını kontrol et
    if ~isstruct(response)
        warning('TRAFFICSIM:OverpassResponseNotStruct', 'Overpass API yanıtı bir struct değil. Yanıtın tipi: %s', class(response));
        return;
    end

    if ~isfield(response, 'elements')
        warning('TRAFFICSIM:OverpassResponseNoElements', 'Overpass API yanıtında "elements" alanı bulunmuyor.');
        return;
    end
    
    try
        elements = response.elements;
        
        if isempty(elements)
            warning('TRAFFICSIM:OverpassResponseElementsEmpty', 'Overpass API yanıtındaki "elements" alanı boş.');
            return; 
        end

        % DEBUG: process_overpass_data - class(elements) başlangıçta zaten hücre dizisi olmalı
        fprintf('DEBUG: process_overpass_data - class(elements) alınıyor: %s\n', class(elements));

        % 'elements' değişkeninin beklenen formatta olup olmadığını kontrol et
        % Overpass'tan genellikle heterojen olduğu için hücre dizisi (cell array of structs) beklenir.
        % Homojen ise struct dizisi (struct array) olabilir.
        is_valid_elements_format = false;
        if iscell(elements)
            % Hücre dizisi ise ve boş değilse, ilk elemanının struct olup olmadığını kontrol et (temel sağlık kontrolü)
            if ~isempty(elements) && isstruct(elements{1})
                is_valid_elements_format = true;
            else
                 warning('TRAFFICSIM:ElementsCellArrayEmptyOrNotStruct', '"elements" hücre dizisi boş veya struct içermiyor.');
            end
        elseif isstruct(elements) % Homojen durum (daha az olası ama mümkün)
            is_valid_elements_format = true;
        end

        if ~is_valid_elements_format
            warning('TRAFFICSIM:InvalidElementsFormat', 'Overpass API yanıtındaki "elements" alanı beklenen formatta (struct dizisi veya struct içeren hücre dizisi) değil. Alınan tip: %s', class(elements));
            return;
        end

        % Geçerli node ve way'leri toplamak için boş struct dizileri başlat
        valid_nodes_list = [];
        valid_ways_list = [];

        num_elements = length(elements);
        for k = 1:num_elements
            current_element = [];
            if iscell(elements)
                current_element = elements{k};
            else % isstruct(elements) olmalı (yukarıdaki kontrol sayesinde)
                current_element = elements(k);
            end
            
            % current_element'ın gerçekten bir struct olup olmadığını tekrar kontrol et (güvenlik için)
            if ~isstruct(current_element)
                warning('TRAFFICSIM:ElementNotStructInLoop', '%d. eleman bir struct değil, atlanıyor.', k);
                continue;
            end

            if isfield(current_element, 'type')
                if strcmp(current_element.type, 'node')
                    if isfield(current_element, 'id') && isfield(current_element, 'lat') && isfield(current_element, 'lon')
                        if isempty(valid_nodes_list)
                            valid_nodes_list = current_element;
                        else
                            valid_nodes_list(end+1) = current_element;
                        end
                    else
                        warning('TRAFFICSIM:SkippingNodeMissingFields', 'Overpass "node" elemanı eksik id, lat veya lon alanları nedeniyle atlanıyor.');
                    end
                elseif strcmp(current_element.type, 'way')
                    if isfield(current_element, 'id') && isfield(current_element, 'nodes')
                        if isempty(valid_ways_list)
                            valid_ways_list = current_element;
                        else
                            valid_ways_list(end+1) = current_element;
                        end
                    else
                        warning('TRAFFICSIM:SkippingWayMissingFields', 'Overpass "way" elemanı eksik id veya nodes alanları nedeniyle atlanıyor.');
                    end
                end
                % Diğer eleman tipleri (örn: relation) şimdilik işlenmiyor
            else
                warning('TRAFFICSIM:SkippingElementMissingType', 'Overpass elemanı eksik "type" alanı nedeniyle atlanıyor.');
            end
        end
        
        if isempty(valid_ways_list) % 'ways' yerine 'valid_ways_list' kullan
            warning('TRAFFICSIM:NoWaysFound', 'Belirtilen bölgede geçerli yol bulunamadı veya işlenemedi.');
            return;
        end
        
        north_ways = 0;
        south_ways = 0;
        east_ways = 0;
        west_ways = 0;
        
        node_map = containers.Map('KeyType', 'double', 'ValueType', 'any');
        if ~isempty(valid_nodes_list) % 'nodes' yerine 'valid_nodes_list' kullan
            for i = 1:length(valid_nodes_list)
                node_struct = valid_nodes_list(i);
                node_map(node_struct.id) = [node_struct.lat, node_struct.lon];
            end
        end
        
        if ~isempty(valid_ways_list) % 'ways' yerine 'valid_ways_list' kullan
            for i = 1:length(valid_ways_list)
                way_struct = valid_ways_list(i);
                
                lat_diff = 0; 
                lon_diff = 0; 

                % way_struct.nodes alanının varlığı zaten yukarıda kontrol edildi
                if length(way_struct.nodes) >= 2
                    first_node_id = way_struct.nodes(1);
                    last_node_id = way_struct.nodes(end);
                    
                    if node_map.isKey(first_node_id) && node_map.isKey(last_node_id)
                        first_node_coord = node_map(first_node_id);
                        last_node_coord = node_map(last_node_id);
                        
                        lat_diff = last_node_coord(1) - first_node_coord(1);
                        lon_diff = last_node_coord(2) - first_node_coord(2);
                        
                        if abs(lat_diff) > abs(lon_diff)
                            if lat_diff > 0
                                north_ways = north_ways + 1;
                            else
                                south_ways = south_ways + 1;
                            end
                        else
                            if lon_diff > 0
                                east_ways = east_ways + 1;
                            else
                                west_ways = west_ways + 1;
                            end
                        end
                    end
                end
                
                if isfield(way_struct, 'tags') && isstruct(way_struct.tags)
                    if isfield(way_struct.tags, 'highway')
                        highway_type = way_struct.tags.highway;
                        if strcmp(highway_type, 'motorway') || strcmp(highway_type, 'trunk') || ...
                           strcmp(highway_type, 'primary') || strcmp(highway_type, 'secondary')
                            if abs(lat_diff) > abs(lon_diff) 
                                if lat_diff > 0
                                    north_ways = north_ways + 2; % Daha önce 1 artırılmıştı, şimdi 2 daha
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
            end
        end
        
        total_ways = north_ways + south_ways + east_ways + west_ways;
        if total_ways > 0
            traffic_data_output.north_density = min(1.0, max(0.1, north_ways / total_ways * 2)); % Yoğunluk hesaplaması gözden geçirilebilir
            traffic_data_output.south_density = min(1.0, max(0.1, south_ways / total_ways * 2));
            traffic_data_output.east_density = min(1.0, max(0.1, east_ways / total_ways * 2));
            traffic_data_output.west_density = min(1.0, max(0.1, west_ways / total_ways * 2));
        else
            % Eğer hiç yol ağırlığı hesaplanamadıysa, varsayılan yoğunlukları koru (zaten ayarlı)
             warning('TRAFFICSIM:NoWayDataToCalculateDensity', 'Yoğunluk hesaplamak için yeterli yol verisi bulunamadı, varsayılanlar kullanılıyor.');
        end
        
        traffic_data_output.timestamp = datetime('now');
        
        fprintf('Overpass verileri işlendi. Yol sayıları - Kuzey: %d, Güney: %d, Doğu: %d, Batı: %d\n', ...
            north_ways, south_ways, east_ways, west_ways);
    catch e
        warning('TRAFFICSIM:OverpassProcessingError', 'Overpass veri işleme hatası: %s. Satır: %d, Fonksiyon: %s', e.message, e.stack(1).line, e.stack(1).name);
        % Hata durumunda, traffic_data_output zaten başlangıçta atanan varsayılan değerleri içerecektir.
    end
end

function traffic_data_output = process_osm_data(response)
    % OSM verisini işle
    traffic_data_output = struct();
    % OSM veri işleme mantığı (Overpass'a benzer olabilir)
    traffic_data_output = get_default_traffic_data();
end

function traffic_data_output = process_tomtom_data(response)
    % TomTom verisini işle
    traffic_data_output = struct();
    % TomTom veri işleme mantığı
    traffic_data_output = get_default_traffic_data();
end

function default_data = get_default_traffic_data()
    % Varsayılan trafik verilerini döndür
    default_data = struct();
    default_data.north_density = 0.5; % Varsayılan yoğunluk
    default_data.south_density = 0.5;
    default_data.east_density = 0.5;
    default_data.west_density = 0.5;
    default_data.timestamp = datetime('now');
    fprintf('Varsayılan trafik verileri kullanıldı.\n');
end 