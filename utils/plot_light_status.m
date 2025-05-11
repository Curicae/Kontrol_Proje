function plot_light_status(time_vector, light_durations_over_time, current_light_state, total_steps)
    % plot_light_status - Her bir yöndeki trafik ışığı durumlarını görselleştirir
    % Girdiler:
    %   time_vector: Zaman vektörü
    %   light_durations_over_time: Zaman içinde ışık süreleri matrisi
    %   current_light_state: Mevcut ışık durumu (string)
    %   total_steps: Toplam zaman adımı sayısı
    
    % Yeni grafik penceresi aç
    figure(3);
    clf;
    set(gcf, 'Position', [100, 100, 1200, 400], 'Name', 'Trafik Işığı Durumları', 'NumberTitle', 'off');
    
    % Light state history oluştur
    light_state_history = zeros(total_steps, 4); % [NS_Yeşil, NS_Sarı, EW_Yeşil, EW_Sarı]
    
    % Geçmiş durumları simüle et
    current_time = 0;
    state_index = 1;  % Başlangıç durumu: NS_Yeşil
    state_time = 0;   % Mevcut durumda geçen süre
    
    for t = 1:total_steps
        % Mevcut ışık durumuna göre gerekli süreyi belirle
        switch state_index
            case 1  % NS_Yeşil
                duration = light_durations_over_time(t, 1);
                light_state_history(t, 1) = 1;  % NS Yeşil aktif
            case 2  % NS_Sarı
                duration = light_durations_over_time(t, 3);
                light_state_history(t, 2) = 1;  % NS Sarı aktif
            case 3  % EW_Yeşil
                duration = light_durations_over_time(t, 2);
                light_state_history(t, 3) = 1;  % EW Yeşil aktif
            case 4  % EW_Sarı
                duration = light_durations_over_time(t, 3);
                light_state_history(t, 4) = 1;  % EW Sarı aktif
        end
        
        % Durum değişimi kontrolü
        state_time = state_time + 1;
        if state_time >= duration
            state_index = mod(state_index, 4) + 1;  % Sonraki duruma geç
            state_time = 0;
        end
    end
    
    % Renkli ışık durum çubuğu oluştur
    subplot(2, 1, 1);
    colormap_ns = [0 0.7 0;    % Yeşil (NS)
                  1 0.8 0;     % Sarı (NS)
                  0.8 0 0];    % Kırmızı (NS)
    
    % NS durumu için
    ns_status = zeros(total_steps, 1);
    for i = 1:total_steps
        if light_state_history(i, 1) == 1
            ns_status(i) = 1;      % Yeşil
        elseif light_state_history(i, 2) == 1
            ns_status(i) = 2;      % Sarı
        else
            ns_status(i) = 3;      % Kırmızı
        end
    end
    
    % Renkli çubuk grafiği çiz
    ax1 = gca;
    imagesc(time_vector, [0.75 1.25], ns_status');
    colormap(ax1, colormap_ns);
    axis tight;
    title('Kuzey-Güney Trafik Işığı Durumu', 'FontSize', 12);
    xlabel('Zaman (saniye)', 'FontSize', 10);
    ylabel('NS', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Y eksenindeki sayıları kaldır
    set(ax1, 'YTick', []);
    set(ax1, 'YTickLabel', []);
    
    % Durum değişim noktalarını belirle
    state_changes = find(diff(ns_status) ~= 0);
    hold on;
    for i = 1:length(state_changes)
        x_pos = time_vector(state_changes(i)+1);
        plot([x_pos x_pos], [0.5 1.5], 'k-', 'LineWidth', 1);
    end
    hold off;
    
    % Doğu-Batı ışık durumu
    subplot(2, 1, 2);
    colormap_ew = [0 0.5 0.8;   % Yeşil (EW)
                  1 0.8 0;       % Sarı (EW)
                  0.8 0 0];      % Kırmızı (EW)
    
    % EW durumu için
    ew_status = zeros(total_steps, 1);
    for i = 1:total_steps
        if light_state_history(i, 3) == 1
            ew_status(i) = 1;      % Yeşil
        elseif light_state_history(i, 4) == 1
            ew_status(i) = 2;      % Sarı
        else
            ew_status(i) = 3;      % Kırmızı
        end
    end
    
    % Renkli çubuk grafiği çiz
    ax2 = gca;
    imagesc(time_vector, [0.75 1.25], ew_status');
    colormap(ax2, colormap_ew);
    axis tight;
    title('Doğu-Batı Trafik Işığı Durumu', 'FontSize', 12);
    xlabel('Zaman (saniye)', 'FontSize', 10);
    ylabel('EW', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Y eksenindeki sayıları kaldır
    set(ax2, 'YTick', []);
    set(ax2, 'YTickLabel', []);
    
    % Durum değişim noktalarını belirle
    state_changes = find(diff(ew_status) ~= 0);
    hold on;
    for i = 1:length(state_changes)
        x_pos = time_vector(state_changes(i)+1);
        plot([x_pos x_pos], [0.5 1.5], 'k-', 'LineWidth', 1);
    end
    hold off;
    
    % Grafikleri özelleştir
    colorbar_ns = colorbar(ax1, 'Position', [0.92 0.58 0.02 0.33]);
    colorbar_ns.Ticks = [1.33, 2, 2.67];
    colorbar_ns.TickLabels = {'Yeşil', 'Sarı', 'Kırmızı'};
    
    colorbar_ew = colorbar(ax2, 'Position', [0.92 0.15 0.02 0.33]);
    colorbar_ew.Ticks = [1.33, 2, 2.67];
    colorbar_ew.TickLabels = {'Yeşil', 'Sarı', 'Kırmızı'};
    
    % Grafikleri güncelle
    drawnow;
end