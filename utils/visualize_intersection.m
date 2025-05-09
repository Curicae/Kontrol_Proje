function visualize_intersection(vehicle_queues, current_light_state)
    % Kavşak durumunu görselleştirir
    % Girdiler:
    %   vehicle_queues: Her yön için kuyrukları içeren yapı
    %   current_light_state: Mevcut trafik ışığı durumu

    % Mevcut figure'ı kullan
    clf; % Mevcut figure'ı temizle
    
    % Kavşak çizimi için koordinatlar
    x = [-1 1 1 -1 -1];
    y = [-1 -1 1 1 -1];
    
    % Kavşağı çiz
    fill(x, y, [0.8 0.8 0.8]); hold on;
    
    % Yolları çiz
    plot([-2 2], [0 0], 'k-', 'LineWidth', 2); % Yatay yol
    plot([0 0], [-2 2], 'k-', 'LineWidth', 2); % Dikey yol
    
    % Trafik ışıklarını çiz
    light_positions = {
        [-1.5, 0.5],  % Kuzey
        [1.5, -0.5],  % Güney
        [0.5, 1.5],   % Doğu
        [-0.5, -1.5]  % Batı
    };
    
    % Her yön için trafik ışığını çiz
    for i = 1:4
        pos = light_positions{i};
        if i <= 2 % Kuzey-Güney
            if strcmp(current_light_state, 'NS_green')
                color = 'g';
            else
                color = 'r';
            end
        else % Doğu-Batı
            if strcmp(current_light_state, 'EW_green')
                color = 'g';
            else
                color = 'r';
            end
        end
        plot(pos(1), pos(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
    end
    
    % Araçları çiz
    vehicle_positions = {
        [-1.8, 0.2],  % Kuzey
        [1.8, -0.2],  % Güney
        [0.2, 1.8],   % Doğu
        [-0.2, -1.8]  % Batı
    };
    
    % Her yön için araçları çiz
    directions = {'north', 'south', 'east', 'west'};
    for i = 1:4
        pos = vehicle_positions{i};
        queue = vehicle_queues.(directions{i});
        for j = 1:min(length(queue), 5) % En fazla 5 araç göster
            offset = (j-1) * 0.2;
            if i <= 2 % Kuzey-Güney
                plot(pos(1), pos(2) + offset, 's', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
            else % Doğu-Batı
                plot(pos(1) + offset, pos(2), 's', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
            end
        end
        if length(queue) > 5
            text(pos(1), pos(2) + 1.2, sprintf('+%d', length(queue)-5), 'FontSize', 10);
        end
    end
    
    % Eksenleri ayarla
    axis([-2 2 -2 2]);
    axis equal;
    grid on;
    title(sprintf('Trafik Işığı Kavşağı Simülasyonu - Durum: %s', current_light_state));
    
    % Grafikleri güncelle
    drawnow;
end 