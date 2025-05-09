function plot_metrics(queue_lengths_over_time, average_wait_times_over_time, light_durations_over_time, time_step_size, total_steps)
    % Simülasyon metriklerini görselleştirir
    % Girdiler:
    %   queue_lengths_over_time: Zaman içinde kuyruk uzunlukları
    %   average_wait_times_over_time: Zaman içinde ortalama bekleme süreleri
    %   light_durations_over_time: Zaman içinde ışık süreleri
    %   time_step_size: Simülasyon zaman adımı
    %   total_steps: Toplam zaman adımı sayısı

    % Mevcut figure'ı kullan
    clf; % Mevcut figure'ı temizle

    % Zaman vektörü oluştur
    time_vector = (1:total_steps) * time_step_size;

    % 1. Kuyruk Uzunlukları Grafiği
    subplot(3,1,1);
    plot(time_vector, queue_lengths_over_time(:,1), 'r-', 'LineWidth', 2); hold on;
    plot(time_vector, queue_lengths_over_time(:,2), 'g-', 'LineWidth', 2);
    plot(time_vector, queue_lengths_over_time(:,3), 'b-', 'LineWidth', 2);
    plot(time_vector, queue_lengths_over_time(:,4), 'm-', 'LineWidth', 2);
    grid on;
    title('Kuyruk Uzunlukları');
    xlabel('Zaman (saniye)');
    ylabel('Araç Sayısı');
    legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
    
    % Kuyruk uzunlukları için y limiti
    try
        max_queue = max(max(queue_lengths_over_time));
        if ~isempty(max_queue) && ~isnan(max_queue) && max_queue > 0
            ylim([0 max_queue * 1.1]);
        else
            ylim([0 10]);
        end
    catch
        ylim([0 10]);
    end

    % 2. Ortalama Bekleme Süreleri Grafiği
    subplot(3,1,2);
    plot(time_vector, average_wait_times_over_time(:,1), 'r-', 'LineWidth', 2); hold on;
    plot(time_vector, average_wait_times_over_time(:,2), 'g-', 'LineWidth', 2);
    plot(time_vector, average_wait_times_over_time(:,3), 'b-', 'LineWidth', 2);
    plot(time_vector, average_wait_times_over_time(:,4), 'm-', 'LineWidth', 2);
    grid on;
    title('Ortalama Bekleme Süreleri');
    xlabel('Zaman (saniye)');
    ylabel('Süre (saniye)');
    legend('Kuzey', 'Güney', 'Doğu', 'Batı', 'Location', 'best');
    
    % Bekleme süreleri için y limiti
    try
        max_wait = max(max(average_wait_times_over_time));
        if ~isempty(max_wait) && ~isnan(max_wait) && max_wait > 0
            ylim([0 max_wait * 1.1]);
        else
            ylim([0 10]);
        end
    catch
        ylim([0 10]);
    end

    % 3. Işık Süreleri Grafiği
    subplot(3,1,3);
    plot(time_vector, light_durations_over_time(:,1), 'g-', 'LineWidth', 2); hold on;
    plot(time_vector, light_durations_over_time(:,2), 'b-', 'LineWidth', 2);
    plot(time_vector, light_durations_over_time(:,3), 'y-', 'LineWidth', 2);
    grid on;
    title('Işık Süreleri');
    xlabel('Zaman (saniye)');
    ylabel('Süre (saniye)');
    legend('NS Yeşil', 'EW Yeşil', 'Sarı', 'Location', 'best');
    
    % Işık süreleri için y limiti
    try
        max_duration = max(max(light_durations_over_time));
        if ~isempty(max_duration) && ~isnan(max_duration) && max_duration > 0
            ylim([0 max_duration * 1.1]);
        else
            ylim([0 10]);
        end
    catch
        ylim([0 10]);
    end

    % Grafikleri güncelle
    drawnow;
end 