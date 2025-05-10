function visualize_intersection(vehicle_queues, current_light_state)
    % Kavşak durumunu görselleştirir
    % Girdiler:
    %   vehicle_queues: Her yön için kuyrukları içeren yapı
    %   current_light_state: Mevcut trafik ışığı durumu
    disp('visualize_intersection çağrıldı'); % DEBUG

    % Mevcut subplot'u temizle
    cla; 
    
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
            elseif strcmp(current_light_state, 'NS_yellow')
                color = 'y';
            else
                color = 'r';
            end
        else % Doğu-Batı
            if strcmp(current_light_state, 'EW_green')
                color = 'g';
            elseif strcmp(current_light_state, 'EW_yellow')
                color = 'y';
            else
                color = 'r';
            end
        end
        plot(pos(1), pos(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
    end
    
    % Yön etiketleri
    text(-1.5, 0.7, 'Kuzey', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(1.5, -0.7, 'Güney', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(0.7, 1.5, 'Doğu', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(-0.7, -1.5, 'Batı', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Araçları çiz
    vehicle_positions = {
        [-1.8, 0.2],  % Kuzey
        [1.8, -0.2],  % Güney
        [0.2, 1.8],   % Doğu
        [-0.2, -1.8]  % Batı
    };
    
    % Her yön için araçları çiz
    directions = {'north', 'south', 'east', 'west'};
    colors = {'b', 'b', 'b', 'b'}; % Yeni renkler: Tüm araçlar mavi
    
    for i = 1:4
        pos = vehicle_positions{i};
        queue = vehicle_queues.(directions{i});
        for j = 1:min(length(queue), 5) % En fazla 5 araç göster
            offset = (j-1) * 0.2;
            if i <= 2 % Kuzey-Güney
                plot(pos(1), pos(2) + offset, 's', 'MarkerSize', 8, 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', 'k');
            else % Doğu-Batı
                plot(pos(1) + offset, pos(2), 's', 'MarkerSize', 8, 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', 'k');
            end
        end
        
        % Her yön için kuyruk uzunluğunu göster
        if i <= 2 % Kuzey-Güney
            text(pos(1), pos(2) - 0.2, sprintf('Kuyruk: %d', length(queue)), 'FontSize', 8, 'Color', 'k');
        else % Doğu-Batı
            text(pos(1) - 0.2, pos(2), sprintf('Kuyruk: %d', length(queue)), 'FontSize', 8, 'Color', 'k', 'Rotation', 90);
        end
    end
    
    % Eksenleri ayarla
    axis([-2 2 -2 2]);
    axis equal;
    grid on;
    title(sprintf('Trafik Işığı Kavşağı - %s', current_light_state), 'FontWeight', 'bold');
    
    % Notlar
    % if strcmp(current_light_state, 'NS_green') || strcmp(current_light_state, 'NS_yellow')
    %     text(0, -1.8, 'Kuzey-Güney aktif', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'BackgroundColor', [1 1 0.8]);
    % else
    %     text(0, -1.8, 'Doğu-Batı aktif', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'BackgroundColor', [1 1 0.8]);
    % end
    drawnow; % Çizimlerin hemen güncellenmesini sağla
    disp('visualize_intersection tamamlandı'); % DEBUG
end