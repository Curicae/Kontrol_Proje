% test_traffic_model.m
% Trafik modeli oluşturmanın başarılı olup olmadığını test eden betik

fprintf('Trafik modeli oluşturma testi başlıyor...\n');

% MATLAB sürüm bilgisini kontrol et
matlab_version = ver('matlab');
matlab_release = matlab_version.Release;
fprintf('MATLAB sürümü: %s (%s)\n', matlab_version.Version, matlab_release);

% R2024b uyumluluk kontrolü
is_r2024b_or_newer = false;
if contains(matlab_release, 'R2024')
    release_year = str2double(regexp(matlab_release, 'R(\d+)', 'tokens', 'once'));
    release_version = regexp(matlab_release, 'R\d+([a-z])', 'tokens', 'once');
    if ~isempty(release_version)
        release_version = release_version{1};
    else
        release_version = '';
    end
    
    if release_year >= 2024
        if isempty(release_version) || release_version >= 'b'
            is_r2024b_or_newer = true;
            fprintf('R2024b veya daha yeni bir sürüm tespit edildi. Uyumluluk düzenlemeleri aktif.\n');
        end
    end
end

try
    % Başlangıç zamanını kaydet
    tic;
    
    % Model oluşturma fonksiyonunu çalıştır
    fprintf('Model oluşturuluyor...\n');
    create_traffic_model();
    
    % Bitiş zamanını kaydet
    execution_time = toc;
    
    fprintf('BAŞARILI: Trafik modeli %.2f saniyede başarıyla oluşturuldu!\n', execution_time);
    
    % Model dosyasının doğru kaydedilip kaydedilmediğini kontrol et
    if exist('traffic_light_model.slx', 'file')
        model_info = dir('traffic_light_model.slx');
        fprintf('Model dosya detayları:\n');
        fprintf('  İsim: %s\n', model_info.name);
        fprintf('  Boyut: %.2f KB\n', model_info.bytes/1024);
        fprintf('  Son Değişiklik: %s\n', datestr(model_info.datenum));
        
        % Modeli açıp daha ayrıntılı doğrulama kontrolleri yap
        fprintf('Modelin içeriği doğrulanıyor...\n');
        open_system('traffic_light_model');
        
        % Alt sistemlerin varlığını kontrol et
        expected_subsystems = {'API_Data_Interface', 'Vehicle_Generator', 'Queue_System', ...
                               'Traffic_Light_Controller', 'PID_Controller', 'Visualization'};
        missing_subsystems = [];
        
        for i = 1:length(expected_subsystems)
            subsys_path = ['traffic_light_model/' expected_subsystems{i}];
            if ~exist_system(subsys_path)
                missing_subsystems{end+1} = expected_subsystems{i};
            end
        end
        
        if isempty(missing_subsystems)
            fprintf('  Tüm beklenen alt sistemler mevcut.\n');
        else
            fprintf('  UYARI: Bazı alt sistemler eksik: %s\n', strjoin(missing_subsystems, ', '));
        end
        
        % Blok bağlantılarını kontrol et
        try
            % Birkaç kritik bağlantıyı kontrol et (örnek)
            if exist_system('traffic_light_model/API_Data_Interface') && exist_system('traffic_light_model/PID_Controller')
                handle = get_param('traffic_light_model/API_Data_Interface/north_density', 'Line');
                if ~isempty(handle)
                    fprintf('  Bağlantı kontrolleri: Başarılı\n');
                else
                    fprintf('  UYARI: Bazı bağlantı sorunları tespit edildi\n');
                end
            end
        catch connection_error
            fprintf('  UYARI: Bağlantı kontrolleri sırasında hata: %s\n', connection_error.message);
        end
        
    else
        fprintf('Model dosyası diske kaydedilmedi, ancak bellekte oluşturuldu.\n');
    end
    
    % Test sonrası modeli kapat
    if bdIsLoaded('traffic_light_model')
        close_system('traffic_light_model', 0);
        fprintf('Model başarıyla kapatıldı.\n');
    end
    
catch ME
    % Hata bilgilerini göster
    fprintf('\nTrafik modeli oluştururken HATA:\n');
    fprintf('  Mesaj: %s\n', ME.message);
    fprintf('  Fonksiyon: %s\n', ME.stack(1).name);
    fprintf('  Satır: %d\n', ME.stack(1).line);
    
    % Yaygın sorunlara göre çözüm önerileri sun
    if contains(lower(ME.message), 'script')
        fprintf('\nOlası çözüm: create_api_data_interface fonksiyonundaki MATLAB Function bloğu uygulamasını kontrol edin.\n');
        fprintf('Mevcut uygulama, sorunlara neden olabilecek Script parametresini kullanmaktan kaçınıyor.\n');
    elseif contains(lower(ME.message), 'parameter')
        fprintf('\nOlası çözüm: Yanlış veya eksik olabilecek blok parametrelerini kontrol edin.\n');
        if is_r2024b_or_newer && (contains(lower(ME.message), 'random') || contains(lower(ME.message), 'switch') || contains(lower(ME.message), 'criteria'))
            fprintf('R2024b sürümünde bazı blokların parametre isimlerinde değişiklikler vardır:\n');
            fprintf('- Random Number bloğu artık Minimum/Maximum yerine başka parametreler kullanır\n');
            fprintf('- Switch bloğunun Criteria parametresi artık "u2>Threshold" formatını desteklemiyor\n');
            fprintf('Bu değişiklikleri Kontrol_Proje/create_traffic_model.m dosyasında düzeltmelisiniz.\n');
        end
    elseif contains(lower(ME.message), 'line')
        fprintf('\nOlası çözüm: Blokları bağlamada bir sorun olabilir. Kaynak ve hedef portların mevcut olduğundan emin olun.\n');
    end
end

fprintf('\nTest tamamlandı.\n');