function [density_NS, density_EW] = calculate_density(vehicle_queues, approaching_window, current_light_state)
    % Trafik yoğunluğunu hesaplar
    % Girdiler:
    %   vehicle_queues: Her yön için kuyrukları içeren yapı
    %   approaching_window: Yaklaşan araçlar için zaman penceresi
    %   current_light_state: Mevcut trafik ışığı durumu
    % Çıktılar:
    %   density_NS: Kuzey-Güney yönü trafik yoğunluğu
    %   density_EW: Doğu-Batı yönü trafik yoğunluğu

    % Kuyruk uzunluklarını hesapla
    queue_length_NS = length(vehicle_queues.north) + length(vehicle_queues.south);
    queue_length_EW = length(vehicle_queues.east) + length(vehicle_queues.west);

    % Yaklaşan araçları hesapla (zaman penceresi içinde gelen araçlar)
    current_time = max([vehicle_queues.north; vehicle_queues.south; ...
                       vehicle_queues.east; vehicle_queues.west]);
    
    if isempty(current_time)
        current_time = 0;
    end
    
    % Zaman penceresi içinde gelen araçları say
    approaching_NS = sum(vehicle_queues.north >= (current_time - approaching_window)) + ...
                    sum(vehicle_queues.south >= (current_time - approaching_window));
    approaching_EW = sum(vehicle_queues.east >= (current_time - approaching_window)) + ...
                    sum(vehicle_queues.west >= (current_time - approaching_window));

    % Toplam yoğunluğu hesapla (kuyruk + yaklaşan)
    density_NS = queue_length_NS + approaching_NS;
    density_EW = queue_length_EW + approaching_EW;

    % Işık durumuna göre yoğunluğu ayarla (kırmızı ışık yönü için daha yüksek ağırlık)
    if strcmp(current_light_state, 'EW_green')
        density_NS = density_NS * 1.5; % Kırmızı ışık yönü için daha yüksek ağırlık
    elseif strcmp(current_light_state, 'NS_green')
        density_EW = density_EW * 1.5;
    end
end 