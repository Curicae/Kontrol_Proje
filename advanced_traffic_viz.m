% advanced_traffic_viz.m
% Gelişmiş trafik simülasyonu görselleştirme

function advanced_traffic_viz()
    fprintf('Gelişmiş trafik görselleştirmesi başlatılıyor...\n');
    
    % Workspace'den verileri al
    workspace_vars = evalin('base', 'whos');
    var_names = {workspace_vars.name};
    
    % Zaman verisi
    if ismember('log_time', var_names)
        t = evalin('base', 'log_time');
    elseif ismember('t', var_names)
        t = evalin('base', 't');
    elseif ismember('viz_time', var_names)
        t = evalin('base', 'viz_time');
    else
        % Varsayılan zaman verisi
        t = 0:0.01:5;
        t = t(:);
    end
    
    % Kuyruk verileri
    queue_data = [];
    if ismember('log_vehicle_queues', var_names)
        queue_data = evalin('base', 'log_vehicle_queues');
    elseif ismember('queue_lengths', var_names)
        queue_data = evalin('base', 'queue_lengths');
    elseif ismember('viz_data', var_names)
        queue_data = evalin('base', 'viz_data');
    end
    
    % Trafik yoğunlukları
    density_data = [];
    if ismember('density_EW', var_names) && ismember('density_NS', var_names)
        density_EW = evalin('base', 'density_EW');
        density_NS = evalin('base', 'density_NS');
        density_data = [density_EW, density_NS];
    end
    
    % Bekleme süreleri
    wait_time_data = [];
    if ismember('average_wait_time_EW', var_names) && ismember('average_wait_time_NS', var_names)
        wait_EW = evalin('base', 'average_wait_time_EW');
        wait_NS = evalin('base', 'average_wait_time_NS');
        wait_time_data = [wait_EW, wait_NS];
    end
    
    % Işık süreleri
    light_data = [];
    if ismember('green_duration_EW', var_names) && ismember('green_duration_NS', var_names)
        green_EW = evalin('base', 'green_duration_EW');
        green_NS = evalin('base', 'green_duration_NS');
        light_data = [green_EW, green_NS];
    end
    
    % Veri yoksa, test verisi oluştur
    if isempty(queue_data) && isempty(density_data) && isempty(wait_time_data)
        fprintf('Görselleştirilecek veri bulunamadı. Test verisi oluşturuluyor...\n');
        
        % Kuyruk uzunlukları (Doğu-Batı ve Kuzey-Güney)
        queue_data = zeros(length(t), 2);
        queue_data(:,1) = 5 * (sin(t/2).^2 + 0.2*sin(t*3));
        queue_data(:,1) = max(0, queue_data(:,1));
        queue_data(:,2) = 4 * (sin((t+1)/2).^2 + 0.3*sin(t*2));
        queue_data(:,2) = max(0, queue_data(:,2));
        
        % Yoğunluklar
        density_data = zeros(length(t), 2);
        density_data(:,1) = queue_data(:,1) / 5;  % 0-1 arası normalize
        density_data(:,2) = queue_data(:,2) / 4;  % 0-1 arası normalize
        
        % Bekleme süreleri
        wait_time_data = zeros(length(t), 2);
        wait_time_data(:,1) = 3 * density_data(:,1).^2 + 0.5*sin(t);
        wait_time_data(:,2) = 2.5 * density_data(:,2).^2 + 0.4*cos(t);
        
        % Işık süreleri
        light_data = zeros(length(t), 2);
        light_data(:,1) = 30 + 20*sin(t/5);
        light_data(:,2) = 25 + 15*cos(t/5);
    end
    
    % Gelişmiş görselleştirmeyi başlat
    create_advanced_visualizations(t, queue_data, density_data, wait_time_data, light_data);
end

function create_advanced_visualizations(t, queue_data, density_data, wait_time_data, light_data)
    % Ana figürü oluştur
    figure('Name', 'Gelişmiş Trafik Simülasyonu Görselleştirmesi', ...
           'NumberTitle', 'off', 'Position', [50, 50, 1200, 800]);
    
    % Boyut kontrolü yap
    if ~isempty(queue_data)
        % Vektörleri sütun vektörü yap
        if size(t, 1) == 1
            t = t(:);
        end
        
        % Boyut uyumsuzluğu varsa düzelt
        if length(t) ~= size(queue_data, 1)
            min_len = min(length(t), size(queue_data, 1));
            t = t(1:min_len);
            queue_data = queue_data(1:min_len, :);
            fprintf('Boyutlar düzeltildi: size(t)=%s, size(queue_data)=%s\n', mat2str(size(t)), mat2str(size(queue_data)));
        end
        
        % Tek sütun varsa ikinci sütun ekle
        if size(queue_data, 2) == 1
            queue_data = [queue_data, queue_data*0.8]; % İkinci yön için tahmin
            fprintf('İkinci sütun eklendi. Yeni boyut: %s\n', mat2str(size(queue_data)));
        end
    end
    
    % Diğer veriler için de benzer kontroller yap
    if ~isempty(density_data) && length(t) ~= size(density_data, 1)
        min_len = min(length(t), size(density_data, 1));
        t_temp = t(1:min_len);
        density_data = density_data(1:min_len, :);
        
        if size(density_data, 2) == 1
            density_data = [density_data, density_data*0.7];
        end
    end
    
    if ~isempty(wait_time_data) && length(t) ~= size(wait_time_data, 1)
        min_len = min(length(t), size(wait_time_data, 1));
        t_temp = t(1:min_len);
        wait_time_data = wait_time_data(1:min_len, :);
        
        if size(wait_time_data, 2) == 1
            wait_time_data = [wait_time_data, wait_time_data*0.9];
        end
    end
    
    if ~isempty(light_data) && length(t) ~= size(light_data, 1)
        min_len = min(length(t), size(light_data, 1));
        t_temp = t(1:min_len);
        light_data = light_data(1:min_len, :);
        
        if size(light_data, 2) == 1
            light_data = [light_data, light_data*0.9];
        end
    end
    
    % Subplot düzeni: 3x2
    
    % 1. Grafik: Kuyruk uzunlukları
    subplot(3, 2, 1);
    if ~isempty(queue_data)
        try
            plot(t, queue_data(:,1), 'b-', 'LineWidth', 2); hold on;
            if size(queue_data, 2) >= 2
                plot(t, queue_data(:,2), 'r--', 'LineWidth', 2);
            end
            title('Trafik Kuyruk Uzunlukları');
            xlabel('Zaman (s)');
            ylabel('Araç Sayısı');
            if size(queue_data, 2) >= 2
                legend('Doğu-Batı', 'Kuzey-Güney');
            else
                legend('Doğu-Batı');
            end
            grid on;
        catch plot_err
            warning('Kuyruk verisi çizilirken hata: %s', plot_err.message);
            text(0.5, 0.5, 'Kuyruk verisi çizilemedi', 'HorizontalAlignment', 'center');
            axis off;
        end
    else
        text(0.5, 0.5, 'Kuyruk verisi bulunamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
    
    % 2. Grafik: Yoğunluklar
    subplot(3, 2, 2);
    if ~isempty(density_data)
        try
            plot(t, density_data(:,1), 'b-', 'LineWidth', 2); hold on;
            if size(density_data, 2) >= 2
                plot(t, density_data(:,2), 'r--', 'LineWidth', 2);
            end
            title('Trafik Yoğunlukları');
            xlabel('Zaman (s)');
            ylabel('Yoğunluk (0-1)');
            if size(density_data, 2) >= 2
                legend('Doğu-Batı', 'Kuzey-Güney');
            else
                legend('Doğu-Batı');
            end
            grid on;
        catch plot_err
            warning('Yoğunluk verisi çizilirken hata: %s', plot_err.message);
            text(0.5, 0.5, 'Yoğunluk verisi çizilemedi', 'HorizontalAlignment', 'center');
            axis off;
        end
    else
        text(0.5, 0.5, 'Yoğunluk verisi bulunamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
    
    % 3. Grafik: Bekleme süreleri
    subplot(3, 2, 3);
    if ~isempty(wait_time_data)
        try
            plot(t, wait_time_data(:,1), 'b-', 'LineWidth', 2); hold on;
            if size(wait_time_data, 2) >= 2
                plot(t, wait_time_data(:,2), 'r--', 'LineWidth', 2);
            end
            title('Ortalama Bekleme Süreleri');
            xlabel('Zaman (s)');
            ylabel('Süre (s)');
            if size(wait_time_data, 2) >= 2
                legend('Doğu-Batı', 'Kuzey-Güney');
            else
                legend('Doğu-Batı');
            end
            grid on;
        catch plot_err
            warning('Bekleme süresi verisi çizilirken hata: %s', plot_err.message);
            text(0.5, 0.5, 'Bekleme süresi verisi çizilemedi', 'HorizontalAlignment', 'center');
            axis off;
        end
    else
        text(0.5, 0.5, 'Bekleme süresi verisi bulunamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
    
    % 4. Grafik: Trafık ışığı süreleri
    subplot(3, 2, 4);
    if ~isempty(light_data)
        try
            plot(t, light_data(:,1), 'b-', 'LineWidth', 2); hold on;
            if size(light_data, 2) >= 2
                plot(t, light_data(:,2), 'r--', 'LineWidth', 2);
            end
            title('Yeşil Işık Süreleri');
            xlabel('Zaman (s)');
            ylabel('Süre (s)');
            if size(light_data, 2) >= 2
                legend('Doğu-Batı', 'Kuzey-Güney');
            else
                legend('Doğu-Batı');
            end
            grid on;
        catch plot_err
            warning('Işık süresi verisi çizilirken hata: %s', plot_err.message);
            text(0.5, 0.5, 'Işık süresi verisi çizilemedi', 'HorizontalAlignment', 'center');
            axis off;
        end
    else
        text(0.5, 0.5, 'Işık süresi verisi bulunamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
    
    % 5. Grafik: 3B görselleştirme (Yoğunluk vs Bekleme Süresi vs Zaman)
    subplot(3, 2, 5:6);
    if ~isempty(density_data) && ~isempty(wait_time_data)
        try
            % 3B yüzey çizimi
            plot3(density_data(:,1), wait_time_data(:,1), t, 'b-', 'LineWidth', 2); hold on;
            if size(density_data, 2) >= 2 && size(wait_time_data, 2) >= 2
                plot3(density_data(:,2), wait_time_data(:,2), t, 'r-', 'LineWidth', 2);
            end
            title('Trafik Yoğunluğu vs Bekleme Süresi vs Zaman');
            xlabel('Yoğunluk');
            ylabel('Bekleme Süresi (s)');
            zlabel('Zaman (s)');
            if size(density_data, 2) >= 2 && size(wait_time_data, 2) >= 2
                legend('Doğu-Batı', 'Kuzey-Güney');
            else
                legend('Doğu-Batı');
            end
            grid on;
            view(30, 30); % 3D görüntüyü döndür
        catch plot_err
            warning('3B görselleştirme çizilirken hata: %s', plot_err.message);
            text(0.5, 0.5, '3B görselleştirme çizilemedi', 'HorizontalAlignment', 'center');
            axis off;
        end
    else
        text(0.5, 0.5, '3B görselleştirme için yeterli veri bulunamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
    
    % Ana başlık
    sgtitle('Trafik Kontrol Sistemi Simülasyon Sonuçları');
    
    % İkinci figür: Kavşak Durum Görselleştirmesi
    create_intersection_visualization(queue_data, light_data);
end

function create_intersection_visualization(queue_data, light_data)
    % Eğer veri yoksa, bu fonksiyonu atla
    if isempty(queue_data)
        return;
    end
    
    try
        % Kuyruk verisi boyut kontrolü
        if size(queue_data, 1) < 1
            disp('Kavşak görselleştirmesi için yeterli veri yok.');
            return;
        end
        
        % Son durumu al (simülasyonun son anındaki değerler)
        queue_EW = queue_data(end, 1);
        if size(queue_data, 2) >= 2
            queue_NS = queue_data(end, 2);
        else
            queue_NS = queue_EW * 0.8; % Tahmin
            disp('Kuzey-Güney kuyruk verisi bulunamadı, Doğu-Batı verisinden tahmin ediliyor.');
        end
        
        % Sayısal değer kontrolü
        if ~isnumeric(queue_EW) || ~isnumeric(queue_NS) || isnan(queue_EW) || isnan(queue_NS)
            disp('Kavşak görselleştirmesi için geçerli sayısal veri bulunamadı.');
            return;
        end
        
        % Işık durumu
        if ~isempty(light_data) && size(light_data, 1) > 0
            try
                light_EW = light_data(end, 1);
                if size(light_data, 2) >= 2
                    light_NS = light_data(end, 2);
                else
                    light_NS = light_EW * 0.9; % Tahmin
                end
                
                % Hangisi aktif?
                if light_EW > light_NS
                    light_state = 'EW'; % Doğu-Batı yeşil
                else
                    light_state = 'NS'; % Kuzey-Güney yeşil
                end
            catch
                % Rastgele ışık durumu
                if rand > 0.5
                    light_state = 'EW';
                else
                    light_state = 'NS';
                end
            end
        else
            % Rastgele ışık durumu
            if rand > 0.5
                light_state = 'EW';
            else
                light_state = 'NS';
            end
        end
        
        % Kavşak görselleştirme figürü
        figure('Name', 'Kavşak Durum Görselleştirmesi', ...
               'NumberTitle', 'off', 'Position', [400, 200, 600, 600]);
        
        % Arkaplan ve yolları oluştur
        axis([-10 10 -10 10]);
        hold on;
        
        % Yolları çiz
        rectangle('Position', [-10, -1, 20, 2], 'FaceColor', [0.7 0.7 0.7]); % Doğu-Batı yolu
        rectangle('Position', [-1, -10, 2, 20], 'FaceColor', [0.7 0.7 0.7]); % Kuzey-Güney yolu
        
        % Yol çizgilerini ekle
        plot([-10, 10], [0, 0], 'w--', 'LineWidth', 1);
        plot([0, 0], [-10, 10], 'w--', 'LineWidth', 1);
        
        % Trafik ışıklarını göster
        if strcmp(light_state, 'EW')
            % Doğu-Batı yeşil, Kuzey-Güney kırmızı
            plot([-1.5, -1.5], [1.5, 1.5], 'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
            plot([1.5, 1.5], [-1.5, -1.5], 'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
            plot([1.5, 1.5], [1.5, 1.5], 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
            plot([-1.5, -1.5], [-1.5, -1.5], 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
        else
            % Doğu-Batı kırmızı, Kuzey-Güney yeşil
            plot([-1.5, -1.5], [1.5, 1.5], 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
            plot([1.5, 1.5], [-1.5, -1.5], 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
            plot([1.5, 1.5], [1.5, 1.5], 'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
            plot([-1.5, -1.5], [-1.5, -1.5], 'go', 'MarkerSize', 15, 'MarkerFaceColor', 'g');
        end
        
        % Araç kuyruklarını göster
        % Doğu'dan gelen araçlar
        for i = 1:min(10, round(queue_EW))
            rectangle('Position', [-2-i, -0.8, 0.8, 0.6], 'FaceColor', 'b', 'Curvature', [0.2, 0.2]);
        end
        
        % Batı'dan gelen araçlar (daha az)
        for i = 1:min(6, round(queue_EW*0.6))
            rectangle('Position', [2+i-0.8, 0.2, 0.8, 0.6], 'FaceColor', 'b', 'Curvature', [0.2, 0.2]);
        end
        
        % Kuzey'den gelen araçlar
        for i = 1:min(8, round(queue_NS))
            rectangle('Position', [-0.8, -2-i, 0.6, 0.8], 'FaceColor', 'r', 'Curvature', [0.2, 0.2]);
        end
        
        % Güney'den gelen araçlar (daha az)
        for i = 1:min(5, round(queue_NS*0.5))
            rectangle('Position', [0.2, 2+i-0.8, 0.6, 0.8], 'FaceColor', 'r', 'Curvature', [0.2, 0.2]);
        end
        
        % Efsane ve görsel düzeltmeler
        title('Kavşak Durumu Anlık Görünüm');
        legend_text = {};
        if strcmp(light_state, 'EW')
            legend_text{end+1} = 'Doğu-Batı: YEŞİL';
            legend_text{end+1} = 'Kuzey-Güney: KIRMIZI';
        else
            legend_text{end+1} = 'Doğu-Batı: KIRMIZI';
            legend_text{end+1} = 'Kuzey-Güney: YEŞİL';
        end
        
        legend_text{end+1} = ['Doğu-Batı Kuyruk: ' num2str(round(queue_EW*10)/10) ' araç'];
        legend_text{end+1} = ['Kuzey-Güney Kuyruk: ' num2str(round(queue_NS*10)/10) ' araç'];
        
        % Efsaneyi ekle (sağ üst köşe)
        legend(legend_text, 'Location', 'northeast');
        
        % Eksen etiketlerini gizle
        axis equal;
        axis off;
    catch viz_err
        warning('Kavşak görselleştirmesi oluşturulurken hata: %s', viz_err.message);
        disp('Hata detayları:');
        disp(getReport(viz_err));
        figure('Name', 'Kavşak Görselleştirme Hatası', 'NumberTitle', 'off');
        text(0.5, 0.5, 'Kavşak görselleştirmesi oluşturulamadı', 'HorizontalAlignment', 'center');
        axis off;
    end
end 