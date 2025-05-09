function [average_wait_times, queue_lengths, light_durations] = record_metrics(time_step, vehicle_queues, current_light_state, next_green_duration_NS, next_green_duration_EW, yellow_duration)
    % Her zaman adımında simülasyon metriklerini kaydeder
    % Girdiler:
    %   time_step: Mevcut simülasyon zaman adımı
    %   vehicle_queues: Her yön için kuyrukları içeren yapı
    %   current_light_state: Mevcut trafik ışığı durumu
    %   next_green_duration_NS: Kuzey-Güney için sonraki yeşil süre
    %   next_green_duration_EW: Doğu-Batı için sonraki yeşil süre
    %   yellow_duration: Sarı ışık süresi
    % Çıktılar:
    %   average_wait_times: Her yön için ortalama bekleme süreleri
    %   queue_lengths: Her yön için kuyruk uzunlukları
    %   light_durations: Mevcut ışık süreleri

    % Kuyruk uzunluklarını hesapla
    queue_lengths = struct(...
        'north', length(vehicle_queues.north), ...
        'south', length(vehicle_queues.south), ...
        'east', length(vehicle_queues.east), ...
        'west', length(vehicle_queues.west) ...
    );

    % Ortalama bekleme sürelerini hesapla
    directions = {'north', 'south', 'east', 'west'};
    average_wait_times = struct();
    
    for i = 1:length(directions)
        dir = directions{i};
        if ~isempty(vehicle_queues.(dir))
            % Varış zamanından bu yana geçen süreyi hesapla
            wait_times = time_step - vehicle_queues.(dir);
            average_wait_times.(dir) = mean(wait_times);
        else
            average_wait_times.(dir) = 0;
        end
    end

    % Işık sürelerini kaydet
    light_durations = struct(...
        'NS_green', next_green_duration_NS, ...
        'EW_green', next_green_duration_EW, ...
        'yellow', yellow_duration ...
    );
end 