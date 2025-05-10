% test_overpass_api.m - Overpass API test dosyası
clear;
clc;

fprintf('=== Overpass API Testi ===\n\n');

% Yapılandırma bilgilerini göster
fprintf('Mevcut yapılandırma:\n');
fprintf('Lokasyon: Enlem=41.0370, Boylam=28.9850\n');
fprintf('Arama yarıçapı: 500 metre\n\n');

% API URL'si
api_url = 'https://overpass-api.de/api/interpreter';

% Overpass QL sorgusu oluştur
query = '[out:json];way["highway"](around:500,41.037000,28.985000);out body;>;out skel;';

fprintf('API URL: %s\n\n', api_url);
fprintf('Sorgu gönderiliyor...\n');
fprintf('Sorgu içeriği:\n%s\n\n', query);

% Web options yapılandırması
options = weboptions('ContentType', 'json', 'Timeout', 30);

try
    % API isteği gönder
    tic;
    response = webread(api_url, 'data', query, options);
    fetch_time = toc;
    fprintf('API yanıtı %.2f saniyede alındı.\n\n', fetch_time);
    
    % Yanıt kontrolü
    if isstruct(response) && isfield(response, 'elements')
        elements = response.elements;  % Bu bir cell array
        fprintf('Yanıt alındı: %d eleman içeriyor\n', length(elements));
        
        % Debug için ilk birkaç elemanı detaylı göster
        fprintf('\nİlk 3 elemanın detaylı yapısı:\n');
        for i = 1:min(3, length(elements))
            fprintf('\nEleman %d:\n', i);
            element = elements{i};  % Cell array'den struct'ı al
            if isstruct(element)
                fields = fieldnames(element);
                for j = 1:length(fields)
                    field = fields{j};
                    value = element.(field);
                    if isstruct(value)
                        fprintf('  %s: [struct]\n', field);
                        if strcmp(field, 'tags') && isfield(value, 'highway')
                            fprintf('    highway: %s\n', value.highway);
                        end
                    else
                        fprintf('  %s: %s\n', field, mat2str(value));
                    end
                end
            end
        end
        
        % Eleman türlerini say
        node_count = 0;
        way_count = 0;
        relation_count = 0;
        
        for i = 1:length(elements)
            element = elements{i};  % Cell array'den struct'ı al
            if isstruct(element) && isfield(element, 'type')
                switch element.type
                    case 'node'
                        node_count = node_count + 1;
                    case 'way'
                        way_count = way_count + 1;
                    case 'relation'
                        relation_count = relation_count + 1;
                end
            end
        end
        
        fprintf('\nBulunan elemanlar:\n');
        fprintf('Node sayısı: %d\n', node_count);
        fprintf('Way sayısı: %d\n', way_count);
        fprintf('Relation sayısı: %d\n\n', relation_count);
        
        % Yol türlerini analiz et
        if way_count > 0
            highway_types = struct();
            for i = 1:length(elements)
                element = elements{i};  % Cell array'den struct'ı al
                if isstruct(element) && strcmp(element.type, 'way') && ...
                   isfield(element, 'tags') && isfield(element.tags, 'highway')
                    highway_type = element.tags.highway;
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
        
        fprintf('\n=== Overpass API testi BAŞARILI ===\n');
    else
        fprintf('API yanıtı beklenen formatta değil.\n');
        % Debug için yanıt yapısını göster
        fprintf('\nYanıt yapısı:\n');
        disp(response);
    end
    
catch e
    fprintf('API isteği başarısız: %s\n', e.message);
end

fprintf('\nTesti sonlandırmak için herhangi bir tuşa basın...\n');
pause;