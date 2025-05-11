% traffic_visualization.m
% Standalone trafik simülasyonu görselleştirme aracı
% Bu script, mevcut verileri görselleştirir veya statik test verisi oluşturur

function traffic_visualization()
    fprintf('Trafik simülasyonu görselleştirmesi başlatılıyor...\n');
    
    % Mevcut workspace değişkenlerini kontrol et
    workspace_vars = evalin('base', 'whos');
    var_names = {workspace_vars.name};
    
    % Potansiyel veri kaynakları
    data_found = false;
    t = [];
    y = [];
    
    % Senaryo 1: log_time ve log_vehicle_queues değişkenleri
    if ismember('log_time', var_names) && ismember('log_vehicle_queues', var_names)
        try
            t = evalin('base', 'log_time');
            queue_data = evalin('base', 'log_vehicle_queues');
            
            if ~isempty(t) && ~isempty(queue_data)
                % Bekleme süreleri hesapla (örnek: kuyruk uzunluğunun fonksiyonu)
                if size(queue_data, 2) >= 2
                    % Doğu-Batı ve Kuzey-Güney kuyruklarını kullan
                    wait_time = queue_data(:,1) * 0.6 + queue_data(:,2) * 0.4;
                else
                    % Tek kuyruk verisini kullan
                    wait_time = queue_data(:,1) * 0.8;
                end
                
                % Veri matrisi oluştur
                if size(queue_data, 2) >= 1
                    y = [queue_data(:,1), wait_time];
                    data_found = true;
                    fprintf('log_time ve log_vehicle_queues verilerinden görselleştirme yapılacak.\n');
                end
            end
        catch
            fprintf('log_time ve log_vehicle_queues değişkenleri işlenirken hata oluştu.\n');
        end
    end
    
    % Senaryo 2: t ve queue_lengths
    if ~data_found && ismember('t', var_names) && ismember('queue_lengths', var_names)
        try
            t = evalin('base', 't');
            queue_data = evalin('base', 'queue_lengths');
            
            if ~isempty(t) && ~isempty(queue_data)
                % Bekleme süreleri hesapla
                if size(queue_data, 2) >= 2
                    wait_time = queue_data(:,1) * 0.6 + queue_data(:,2) * 0.4;
                else
                    wait_time = queue_data(:,1) * 0.8;
                end
                
                % Veri matrisi oluştur
                if size(queue_data, 2) >= 1
                    y = [queue_data(:,1), wait_time];
                    data_found = true;
                    fprintf('t ve queue_lengths verilerinden görselleştirme yapılacak.\n');
                end
            end
        catch
            fprintf('t ve queue_lengths değişkenleri işlenirken hata oluştu.\n');
        end
    end
    
    % Senaryo 3: average_wait_time ve density verilerini kontrol et
    if ~data_found && ismember('log_time', var_names) && ...
       (ismember('average_wait_time_EW', var_names) || ismember('density_EW', var_names))
        try
            t = evalin('base', 'log_time');
            
            if ismember('average_wait_time_EW', var_names) && ismember('density_EW', var_names)
                wait_time = evalin('base', 'average_wait_time_EW');
                density = evalin('base', 'density_EW');
                
                if ~isempty(t) && ~isempty(wait_time) && ~isempty(density)
                    y = [density, wait_time];
                    data_found = true;
                    fprintf('log_time, average_wait_time_EW ve density_EW verilerinden görselleştirme yapılacak.\n');
                end
            end
        catch
            fprintf('Bekleme süresi ve yoğunluk değişkenleri işlenirken hata oluştu.\n');
        end
    end
    
    % Veri bulunamadıysa, sentetik veri oluştur
    if ~data_found
        fprintf('Uygun veri bulunamadı. Sentetik test verisi oluşturulacak...\n');
        
        % Sentetik zaman ve veri oluştur
        t = 0:0.01:5;
        t = t(:); % Sütun vektörü
        
        % 1. sinyal: Kuyruk uzunluğu - maksimum 5 araç
        queue_length = 5 * sin(t/2).^2 + 1 * sin(t*2);
        queue_length = max(0, queue_length); % Negatif değerleri sıfırla
        
        % 2. sinyal: Bekleme süresi - maksimum 3 saniye
        wait_time = 3 * sin(t/3).^2 + 0.5 * sin(t*3);
        wait_time = max(0, wait_time); % Negatif değerleri sıfırla
        
        % İki sinyali birleştir
        y = [queue_length, wait_time];
        
        fprintf('Sentetik test verisi oluşturuldu.\n');
    end
    
    % Verileri görselleştir
    visualize_data(t, y);
    
    % İstatistikler
    fprintf('Simülasyon İstatistikleri:\n');
    fprintf('Toplam simülasyon süresi: %.2f saniye\n', max(t));
    
    % Sütun başlıklarını belirle
    if size(y, 2) >= 1
        if data_found 
            col1_name = 'Kuyruk Uzunluğu/Yoğunluk';
        else
            col1_name = 'Kuyruk Uzunluğu';
        end
        fprintf('Maksimum %s: %.2f\n', col1_name, max(y(:,1)));
    end
    
    if size(y, 2) >= 2
        % İki durum da aynı olduğu için doğrudan atama yapabiliriz
        col2_name = 'Bekleme Süresi';
        fprintf('Maksimum %s: %.2f saniye\n', col2_name, max(y(:,2)));
    end
    
    % Verileri workspace'e kaydet
    assignin('base', 'viz_time', t);
    assignin('base', 'viz_data', y);
    fprintf('Veriler workspace''e viz_time ve viz_data olarak kaydedildi.\n');
end

function visualize_data(t, y)
    % Veri boyutlarını kontrol et ve düzelt
    if isempty(t) || isempty(y)
        warning('Görselleştirilecek veri boş!');
        return;
    end
    
    % Vektörleri sütun vektörü yap
    if size(t, 1) == 1
        t = t(:);
    end
    
    % Boyut uyumsuzluğu varsa düzelt
    if length(t) ~= size(y, 1)
        min_len = min(length(t), size(y, 1));
        t = t(1:min_len);
        y = y(1:min_len, :);
        fprintf('Boyutlar düzeltildi: size(t)=%s, size(y)=%s\n', mat2str(size(t)), mat2str(size(y)));
    end
    
    % Tek sütun varsa ikinci sütun ekle
    if size(y, 2) == 1
        y = [y, y*0.6 + 0.5*sin(t)]; % Farklı bir veri oluştur
        fprintf('İkinci sütun eklendi.\n');
    end
    
    % Figür oluştur
    figure('Name', 'Trafik Kontrol Sistemi Simülasyonu', 'NumberTitle', 'off', 'Position', [100, 100, 900, 600]);
    
    % İlk grafik: Kuyruk uzunluğu/yoğunluk
    subplot(2, 1, 1);
    plot(t, y(:, 1), 'b-', 'LineWidth', 2);
    title('Kuyruk Uzunluğu / Trafik Yoğunluğu');
    xlabel('Zaman (s)');
    ylabel('Değer');
    grid on;
    
    % İkinci grafik: Bekleme süresi
    subplot(2, 1, 2);
    plot(t, y(:, 2), 'r-', 'LineWidth', 2);
    title('Bekleme Süresi');
    xlabel('Zaman (s)');
    ylabel('Süre (s)');
    grid on;
    
    % Ana başlık
    sgtitle('Trafik Kontrol Sistemi Simülasyon Sonuçları');
end 