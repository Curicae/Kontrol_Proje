function plot_metrics(queue_lengths_over_time, average_wait_times_over_time, light_durations_over_time, time_step_size, total_steps, current_light_state)
    % Simülasyon metriklerini görselleştirir
    % Girdiler:
    %   queue_lengths_over_time: Zaman içinde kuyruk uzunlukları
    %   average_wait_times_over_time: Zaman içinde ortalama bekleme süreleri
    %   light_durations_over_time: Zaman içinde ışık süreleri
    %   time_step_size: Simülasyon zaman adımı
    %   total_steps: Toplam zaman adımı sayısı
    %   current_light_state: Mevcut ışık durumu
    
    % Zaman vektörü oluştur
    time_vector = (1:total_steps) * time_step_size;
    
    % Grafik düzeni: 5 satır, tek sütun
    clf; % Mevcut grafikleri temizle
    
    % 1. Kuzey yönü kuyruk ve bekleme süresi grafiği
    subplot(5,1,1);
    yyaxis left
    plot(time_vector, queue_lengths_over_time(:,1), 'r-', 'LineWidth', 2);
    ylabel('Kuyruk (araç)');
    ylim([0 max(max(queue_lengths_over_time(:,1)))*1.2 + 1]);
    
    yyaxis right
    plot(time_vector, average_wait_times_over_time(:,1), 'r--', 'LineWidth', 1.5);
    ylabel('Bekleme (sn)');
    ylim([0 max(max(average_wait_times_over_time(:,1)))*1.2 + 1]);
    
    grid on;
    title('Kuzey Yönü Kuyruk ve Bekleme Süreleri', 'FontWeight', 'bold');
    legend('Kuyruk Uzunluğu', 'Bekleme Süresi', 'Location', 'northwest');
    
    % 2. Güney yönü kuyruk ve bekleme süresi grafiği
    subplot(5,1,2);
    yyaxis left
    plot(time_vector, queue_lengths_over_time(:,2), 'g-', 'LineWidth', 2);
    ylabel('Kuyruk (araç)');
    ylim([0 max(max(queue_lengths_over_time(:,2)))*1.2 + 1]);
    
    yyaxis right
    plot(time_vector, average_wait_times_over_time(:,2), 'g--', 'LineWidth', 1.5);
    ylabel('Bekleme (sn)');
    ylim([0 max(max(average_wait_times_over_time(:,2)))*1.2 + 1]);
    
    grid on;
    title('Güney Yönü Kuyruk ve Bekleme Süreleri', 'FontWeight', 'bold');
    legend('Kuyruk Uzunluğu', 'Bekleme Süresi', 'Location', 'northwest');
    
    % 3. Doğu yönü kuyruk ve bekleme süresi grafiği
    subplot(5,1,3);
    yyaxis left
    plot(time_vector, queue_lengths_over_time(:,3), 'b-', 'LineWidth', 2);
    ylabel('Kuyruk (araç)');
    ylim([0 max(max(queue_lengths_over_time(:,3)))*1.2 + 1]);
    
    yyaxis right
    plot(time_vector, average_wait_times_over_time(:,3), 'b--', 'LineWidth', 1.5);
    ylabel('Bekleme (sn)');
    ylim([0 max(max(average_wait_times_over_time(:,3)))*1.2 + 1]);
    
    grid on;
    title('Doğu Yönü Kuyruk ve Bekleme Süreleri', 'FontWeight', 'bold');
    legend('Kuyruk Uzunluğu', 'Bekleme Süresi', 'Location', 'northwest');
    
    % 4. Batı yönü kuyruk ve bekleme süresi grafiği
    subplot(5,1,4);
    yyaxis left
    plot(time_vector, queue_lengths_over_time(:,4), 'm-', 'LineWidth', 2);
    ylabel('Kuyruk (araç)');
    ylim([0 max(max(queue_lengths_over_time(:,4)))*1.2 + 1]);
    
    yyaxis right
    plot(time_vector, average_wait_times_over_time(:,4), 'm--', 'LineWidth', 1.5);
    ylabel('Bekleme (sn)');
    ylim([0 max(max(average_wait_times_over_time(:,4)))*1.2 + 1]);
    
    grid on;
    title('Batı Yönü Kuyruk ve Bekleme Süreleri', 'FontWeight', 'bold');
    legend('Kuyruk Uzunluğu', 'Bekleme Süresi', 'Location', 'northwest');
    
    % 5. Işık süreleri grafiği - Kuzey-Güney ve Doğu-Batı için
    subplot(5,1,5);
    plot(time_vector, light_durations_over_time(:,1), 'g-', 'LineWidth', 2); hold on;
    plot(time_vector, light_durations_over_time(:,2), 'b-', 'LineWidth', 2);
    plot(time_vector, light_durations_over_time(:,3), 'y-', 'LineWidth', 1.5);
    
    % Mevcut ışık durumunu göster (metin olarak)
    text_x = time_vector(end) * 0.95;
    text_y = max(max(light_durations_over_time)) * 0.9;
    text(text_x, text_y, ['Mevcut: ' current_light_state], 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    
    grid on;
    title('Trafik Işığı Süreleri', 'FontWeight', 'bold');
    xlabel('Zaman (saniye)');
    ylabel('Süre (saniye)');
    legend('KG Yeşil', 'DB Yeşil', 'Sarı', 'Location', 'northwest');
    
    % Grafik düzenini optimize et
    set(gcf, 'Units', 'Normalized');
    
    % Figürü güncelleyerek göster
    drawnow;
end