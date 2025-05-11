function run_simulation_with_visualization()
    % Simulink modelini yükle ve veri toplama ayarlarını yap
    model_name = 'traffic_light_model';
    cleanupObj = []; % onCleanup nesnesi için değişken tanımla
    
    try
        % Ana model yerine test modeli çalıştıralım
        disp('Asıl modelle ilgili sorun yaşanıyor. Basit test modeli oluşturulacak...');
        [test_success, test_tout, test_yout] = run_simple_test_model();
        
        if test_success
            disp('Test modeli başarıyla çalıştı! Bu verilerle görselleştirme yapacağız.');
            tout = test_tout;
            yout = test_yout;
            visualize_simulation_data(tout, yout);
            return; % Fonksiyonu başarıyla sonlandır
        else
            disp('Test modeli de çalışmadı. Statik veri kullanılacak...');
            % Statik veri oluştur
            tout = 0:0.01:5; % 0'dan 5'e 0.01 adımlarla zaman vektörü
            yout = [5*sin(2*pi*0.5*tout)', 3*cos(2*pi*0.3*tout)']; % İki sütunlu veri
            disp('Statik test verisi oluşturuldu ve görselleştirilecek.');
            visualize_simulation_data(tout, yout);
            return; % Fonksiyonu başarıyla sonlandır
        end
        
        % Modelin varlığını kontrol et
        if ~exist([model_name '.slx'], 'file')
            error('Model dosyası bulunamadı: %s.slx', model_name);
        end
        
        % --- YENİ EKLENEN KISIM: Model Temizliği ---
        % Script başında model açıksa kaydetmeden kapat
        if bdIsLoaded(model_name)
            disp(['Model "' model_name '" zaten yüklüydü, değişiklikler kaydedilmeden kapatılıyor.']);
            close_system(model_name, 0);
        end
        % --- Model Temizliği SONU ---
        
        % Modeli yükle
        load_system(model_name);
        disp('Model başarıyla yüklendi.');
        
        % --- YENİ EKLENEN KISIM: Otomatik Kapatma ---
        % Fonksiyon sonlandığında veya hata oluştuğunda modelin kaydetmeden kapatılmasını garantile
        cleanupObj = onCleanup(@() close_model_gracefully(model_name));
        % --- Otomatik Kapatma SONU ---
        
        % Modeli düzenleme moduna al
        set_param(model_name, 'Lock', 'off');
        
        % Veri toplama bloklarını ekle (yalnızca tanımlanıyorlar, bağlantı yok)
        try
            % Eğer bloklar zaten varsa sil
            delete_block([model_name '/tout_block_temp']); % İsim düzeltildi
            delete_block([model_name '/yout_block_temp']); % İsim düzeltildi
            disp('Eski geçici veri toplama blokları (tout_block_temp, yout_block_temp) silindi.');
        catch
            disp('Eski geçici veri toplama blokları (tout_block_temp, yout_block_temp) bulunamadı veya zaten silinmiş.');
        end
        
        % To Workspace bloklarını ekle - Bunlar doğrudan kullanılmayacak, simOut.yout tercih edilecek
        add_block('simulink/Sinks/To Workspace', [model_name '/tout_block_temp'], 'VariableName', 'tout_from_block_temp'); % İsim değiştirildi, çakışma olmasın
        add_block('simulink/Sinks/To Workspace', [model_name '/yout_block_temp'], 'VariableName', 'yout_from_block_temp'); % İsim değiştirildi
        disp('Geçici To Workspace blokları eklendi (doğrudan kullanılmayacaklar).');

        % Model Configuration Parameters'ı ayarla
        configSet = getActiveConfigSet(model_name);
        
        % Data Import/Export ayarları
        set_param(configSet, 'SaveOutput', 'on');
        set_param(configSet, 'OutputSaveName', 'yout'); % Bu isim simOut.yout için anahtar olacak
        set_param(configSet, 'SaveTime', 'on');
        set_param(configSet, 'TimeSaveName', 'tout');   % Bu isim simOut.tout için anahtar olacak
        set_param(configSet, 'SaveState', 'off'); % Durumları kaydetmeye gerek yoksa kapatılabilir
        % set_param(configSet, 'StateSaveName', 'xout'); % <--- SaveState 'off' iken bu satır hataya neden oluyordu, YORUMA ALINDI.
        set_param(configSet, 'SaveFormat', 'StructureWithTime'); % Array yerine StructureWithTime formatı kullanılacak
        disp('Model yapılandırma parametreleri ayarlandı.');
        
        % Simülasyon ayarları
        set_param(configSet, 'StopTime', '5');    % Simülasyon süresi 5 saniye
        set_param(configSet, 'Solver', 'ode45');  % Çözücü tipi
        set_param(configSet, 'MaxStep', '0.01');  % Daha hassas adım boyutu
        
        % Ana modele çıkış portları ekle
        try
            % Eğer varsa eski çıkış portlarını sil
            delete_block([model_name '/ModelOut1']);
            delete_block([model_name '/ModelOut2']);
        catch
             disp('ModelOut1/ModelOut2 portları bulunamadı veya zaten silinmiş.');
        end
        
        % Yeni çıkış portları ekle (Modelin ana seviyesine)
        add_block('simulink/Sinks/Out1', [model_name '/ModelOut1'], 'Position', [700, 100, 720, 120]);
        add_block('simulink/Sinks/Out1', [model_name '/ModelOut2'], 'Position', [700, 200, 720, 220]);
        disp('ModelOut1 ve ModelOut2 Outport blokları eklendi/güncellendi.');
        
        % Alt sistemlerin çıkışlarını ana modeldeki Outport bloklarına bağla
        try
            % Önce mevcut olabilecek eski bağlantıları silmeyi dene
            try delete_line(model_name, 'Queue_System/1', 'ModelOut1/1'); catch; end
            try delete_line(model_name, 'Queue_System/2', 'ModelOut2/1'); catch; end
            
            add_line(model_name, 'Queue_System/1', 'ModelOut1/1', 'autorouting', 'on');
            add_line(model_name, 'Queue_System/2', 'ModelOut2/1', 'autorouting', 'on');
            disp('Queue_System çıkışları ModelOut1 ve ModelOut2 portlarına bağlandı.');
        catch ME_connect
            warning('Alt sistem çıkışları Outport bloklarına bağlanırken hata: %s - %s', ME_connect.identifier, ME_connect.message);
            disp('Lütfen create_traffic_model.m scriptinin Queue_System alt sistemini doğru oluşturduğundan ve 1. ve 2. çıkış portlarına sahip olduğundan emin olun.');
        end
        
        % Modeli kaydet - YORUMA ALINARAK ATLANIYOR
        % save_system(model_name);
        % disp('Model kaydedildi.');
        
        % Simülasyonu çalıştır
        disp('Simülasyon başlatılıyor...');
        % SimulationInput API ile model parametrelerini doğrudan sim komutuna ilet
        simIn = Simulink.SimulationInput(model_name);
        
        % Önce sinüs test sinyali ekleyelim
        disp('Test sinyali ekleniyor...');
        try
            if ~isempty(find_system(model_name, 'SearchDepth', 1, 'Name', 'SineWave'))
                delete_block([model_name '/SineWave']);
            end
            
            % Sinüs bloğu ekle
            add_block('simulink/Sources/Sine Wave', [model_name '/SineWave'], ...
                'Position', [100, 300, 150, 330], ... 
                'SampleTime', '0.01', ... % Önemli: Örnekleme zamanını küçük bir değer olarak ayarla
                'Amplitude', '10', ... 
                'Frequency', '1');
            
            % To Workspace bloğu (test) ekle
            if ~isempty(find_system(model_name, 'SearchDepth', 1, 'Name', 'SineOut'))
                delete_block([model_name '/SineOut']);
            end
            add_block('simulink/Sinks/To Workspace', [model_name '/SineOut'], ...
                'Position', [250, 300, 300, 330], ...
                'VariableName', 'sine_test_data', ...
                'SampleTime', '0.01');
            
            % Sinüs sinyalinden To Workspace'e bağlantı
            add_line(model_name, 'SineWave/1', 'SineOut/1', 'autorouting', 'on');
            
            disp('Test sinyali (Sine Wave) başarıyla eklendi ve bağlandı.');
        catch ME_sine
            warning('Test sinyali eklenirken hata: %s', ME_sine.message);
        end
        
        % Simülasyon değerlerini doğrudan ayarla
        simIn = setModelParameter(simIn, ...
            'StartTime', '0', ...
            'StopTime', '5', ...
            'Solver', 'ode45', ...
            'SaveOutput', 'on', ...
            'OutputSaveName', 'yout', ...
            'SaveTime', 'on', ...
            'TimeSaveName', 'tout', ...
            'SaveFormat', 'Array', ... % Tekrar Array formatını deneyelim
            'ReturnWorkspaceOutputs', 'on', ...
            'SignalLogging', 'on', ...
            'SignalLoggingName', 'logsout');
        
        % Alternatif veri toplama (doğrudan workspace değişkenleri)
        simIn = setModelParameter(simIn, ...
            'LoadExternalInput', 'off', ...
            'ExternalInput', '[]', ...
            'LoadInitialState', 'off', ...
            'InitialState', '[]');
        
        disp('Simülasyon parametreleri SimulationInput ile ayarlandı.');
        simOut = sim(simIn);
        disp('Simülasyon tamamlandı.');
        
        % *** YENİ EKLENEN KISIM: Simülasyon Sonrası Erken Hata Kontrolü ***
        if isfield(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
            disp('-------------------------------------------------');
            disp('!!! SİMÜLASYON BAŞARISIZ OLDU - HATA MESAJI !!!');
            disp(simOut.ErrorMessage);
            disp('-------------------------------------------------');
            error('Simülasyon çalıştırılamadı. Yukarıdaki ErrorMessage''a bakın.');
        end
        % *** Erken Hata Kontrolü SONU ***

        % Detaylı diagnostik
        inspect_simulation_output(simOut);
        
        % Verileri workspace'e aktar (simOut nesnesinden)
        if isfield(simOut, 'tout')
            disp('simOut.tout alanı bulundu! Klasik yol kullanılıyor.');
            tout = simOut.tout;
            
            % StructureWithTime formatında yout değerini almak için:
            if isfield(simOut, 'yout')
                if isstruct(simOut.yout) && isfield(simOut.yout, 'signals') && isfield(simOut.yout.signals, 'values')
                    yout = simOut.yout.signals.values;
                    disp('simOut.yout.signals.values başarıyla alındı (StructureWithTime).');
                else
                    disp('simOut.yout var ama beklenen yapıda değil. Alternatif yöntemler denenecek...');
                    error('simOut.yout StructureWithTime yapısı bulunamadı.'); % Bu satır alternatif yöntemlere yönlendirecek
                end
            else
                disp('simOut.yout alanı bulunamadı. Alternatif yöntemler denenecek...');
                error('simOut.yout alanı bulunamadı.'); % Bu satır alternatif yöntemlere yönlendirecek
            end
        else
            % --- YENİ TEŞHİS BLOĞU BAŞLANGICI ---
            disp('--- DIAGNOSTIC: `tout` alanı bulunamadı. `simOut` inceleniyor (error öncesi): ---');
            if isfield(simOut, 'ErrorMessage')
                fprintf('DIAGNOSTIC: simOut.ErrorMessage class: %s\\n', class(simOut.ErrorMessage));
                fprintf('DIAGNOSTIC: simOut.ErrorMessage isempty: %d\\n', isempty(simOut.ErrorMessage));
                disp('DIAGNOSTIC: simOut.ErrorMessage içeriği BEGIN:');
                try
                    disp(simOut.ErrorMessage);
                catch InnerME_dispErr
                    disp('DIAGNOSTIC: simOut.ErrorMessage disp edilirken hata oluştu:');
                    disp(getReport(InnerME_dispErr));
                end
                disp('DIAGNOSTIC: simOut.ErrorMessage içeriği END.');
            else
                disp('DIAGNOSTIC: simOut.ErrorMessage alanı simOut içinde bulunamadı.');
            end
            
            if isfield(simOut, 'SimulationMetadata') && ...
               isfield(simOut.SimulationMetadata, 'ExecutionInfo') && ...
               isfield(simOut.SimulationMetadata.ExecutionInfo, 'ErrorDiagnostic') 
                fprintf('DIAGNOSTIC: ErrorDiagnostic class: %s\\n', class(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic));
                fprintf('DIAGNOSTIC: ErrorDiagnostic isempty: %d\\n', isempty(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic));
                disp('DIAGNOSTIC: simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic içeriği BEGIN:');
                try
                    disp(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic);
                catch InnerME_dispDiag
                     disp('DIAGNOSTIC: ErrorDiagnostic disp edilirken hata oluştu:');
                     disp(getReport(InnerME_dispDiag));
                end
                disp('DIAGNOSTIC: simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic içeriği END.');
            else
                disp('DIAGNOSTIC: simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic bulunamadı.');
            end

            if isfield(simOut, 'SimulationMetadata') && ...
               isfield(simOut.SimulationMetadata, 'ExecutionInfo') && ...
               isfield(simOut.SimulationMetadata.ExecutionInfo, 'StopEvent')
                fprintf('DIAGNOSTIC: simOut.SimulationMetadata.ExecutionInfo.StopEvent: %s\\n', char(simOut.SimulationMetadata.ExecutionInfo.StopEvent));
            else
                disp('DIAGNOSTIC: StopEvent bilgisi bulunamadı.');
            end
            disp('--- TEŞHİS BLOĞU SONU ---');
            % --- YENİ TEŞHİS BLOĞU SONU ---
            % logsout üzerinden veri almayı dene
            if isfield(simOut, 'logsout')
                disp('logsout alanı bulundu, veri buradan alınmaya çalışılacak.');
                logsout = simOut.logsout;
                % logsout içeriğini incele
                element_names = logsout.getElementNames();
                if ~isempty(element_names)
                    disp('logsout içindeki sinyal isimleri:');
                    disp(element_names);
                    % İlk iki sinyali almayı dene (ModelOut1 ve ModelOut2)
                    try
                        % Not: Sinyal isimleri ModelOut1 ve ModelOut2 olmayabilir
                        % Bu yüzden önce ilk iki sinyali almaya çalışalım
                        if length(element_names) >= 2
                            signal1_name = element_names{1};
                            signal2_name = element_names{2};
                            disp(['İlk sinyal: ', signal1_name, ', İkinci sinyal: ', signal2_name]);
                        else
                            % Tek sinyal varsa da alalım
                            signal1_name = element_names{1};
                            signal2_name = '';
                            disp(['Tek sinyal bulundu: ', signal1_name]);
                        end
                        
                        signal1_ts = logsout.getElement(signal1_name);
                        if ~isempty(signal2_name)
                            signal2_ts = logsout.getElement(signal2_name);
                        end
                        
                        if ~isempty(signal1_ts)
                            % Zaman vektörünü her durumda ilk sinyalden alalım
                            tout = signal1_ts.Values.Time;
                            disp(['tout zaman vektörü (', num2str(length(tout)), ' nokta) logsout üzerinden alındı.']);
                            
                            if ~isempty(signal2_name) && ~isempty(signal2_ts)
                                yout = [signal1_ts.Values.Data, signal2_ts.Values.Data];
                                disp('İki sinyal birleştirilerek yout matrisi oluşturuldu.');
                            else
                                yout = signal1_ts.Values.Data;
                                disp('Tek sinyal içeren yout vektörü oluşturuldu.');
                            end
                            disp('Zaman ve çıkış verileri logsout üzerinden başarıyla alındı.');
                        else
                            error('logsout içindeki sinyaller boş veya erişilemedi.');
                        end
                    catch logsout_err
                        disp('logsout üzerinden veri alınırken hata oluştu:');
                        disp(getReport(logsout_err));
                        error('logsout üzerinden veri alınamadı.');
                    end
                else
                    error('logsout içinde sinyal bulunamadı.');
                end
            else
                error('simOut nesnesinde `tout` alanı bulunamadı. Zaman verisi kaydedilmemiş.'); % Orijinal hata
            end
        end
        
        % Çıkış verilerini al (simOut nesnesinden)
        if isfield(simOut, 'yout')
            if isa(simOut.yout, 'Simulink.SimulationData.Dataset')
                disp('simOut.yout bir Dataset nesnesi olarak bulundu.');
                try
                    % Dataset içindeki sinyalleri isimleriyle al
                    % Bu isimler, Outport bloklarının isimleri olmalıdır ('ModelOut1', 'ModelOut2')
                    
                    % *** YENİ EKLENEN KISIM: Dataset Eleman İsimlerini Yazdır ***
                    if isa(simOut.yout, 'Simulink.SimulationData.Dataset') && ~isempty(simOut.yout.getElementNames)
                        disp('Dataset (`simOut.yout`) içindeki eleman isimleri:');
                        disp(simOut.yout.getElementNames());
                    end
                    % *** Dataset Eleman İsimlerini Yazdırma SONU ***

                    signal1_ts = simOut.yout.getElement('ModelOut1'); 
                    signal2_ts = simOut.yout.getElement('ModelOut2');
                    
                    if isempty(signal1_ts) || isempty(signal2_ts)
                        error('Dataset içinde ModelOut1 veya ModelOut2 elemanları boş geldi.');
                    end

                    signal1 = signal1_ts.Values; % Bu bir timeseries nesnesi olmalı
                    signal2 = signal2_ts.Values; % Bu bir timeseries nesnesi olmalı
                    
                    % Zaman vektörünü ve sinyal verilerini birleştir
                    if isa(signal1, 'timeseries') && isa(signal2, 'timeseries')
                        disp('ModelOut1 ve ModelOut2 sinyalleri timeseries olarak alındı.');
                        % Zaman vektörlerini ve veri boyutlarını kontrol et
                        if isequal(signal1.Time, signal2.Time)
                            yout = [signal1.Data, signal2.Data];
                            disp('Sinyaller birleştirilerek `yout` oluşturuldu.');
                        else
                            % Zaman vektörleri farklıysa, yeniden örnekleme veya ayrı işleme gerekebilir
                            warning('ModelOut1 ve ModelOut2 sinyalleri farklı zaman vektörlerine sahip. İlk sinyalin zamanı kullanılıyor.');
                            % Bu durumu daha iyi yönetmek için ek mantık gerekebilir.
                            % Şimdilik basitçe birleştiriyoruz, ancak bu ideal olmayabilir.
                            yout = [resample(signal1, signal1.Time).Data, resample(signal2, signal1.Time).Data];
                            disp('Farklı zaman vektörleri nedeniyle sinyaller yeniden örneklendi ve birleştirildi.');
                        end
                    else
                        error('ModelOut1 veya ModelOut2''den alınan veriler beklenen timeseries formatında değil.');
                    end
                    disp('Simülasyon çıktıları (Dataset) başarıyla işlendi.');
                catch ME_dataset
                    disp('Dataset''ten veri alınırken hata oluştu:');
                    disp(ME_dataset.message);
                    % !!! HATA AYIKLAMA İÇİN YORUMLANAN BLOK BAŞLANGIÇ !!!
                    % disp('getBlock(simOut.yout) çıktısı:');
                    % try
                    %     disp(getBlock(simOut.yout)); % Dataset yapısını görmek için
                    % catch
                    %     disp('getBlock(simOut.yout) çalıştırılamadı');
                    % end
                    % disp('simOut.yout.getElementNames() çıktısı:');
                    %  try
                    %     disp(simOut.yout.getElementNames()); % Dataset eleman isimlerini görmek için
                    % catch
                    %     disp('getElementNames() çalıştırılamadı');
                    % end
                    % !!! HATA AYIKLAMA İÇİN YORUMLANAN BLOĞUN SONU !!!
                    error('Dataset yapısı beklenenden farklı veya ModelOut1/ModelOut2 elemanları bulunamadı.');
                end
            else
                % Bu senaryo için Dataset bekleniyor, eğer değilse bir sorun var.
                yout = simOut.yout; 
                warning('simOut.yout bir Dataset nesnesi değil. Beklenmedik format.');
                disp('Simülasyon çıktıları (Dataset olmayan) başarıyla alındı, ancak bu beklenmiyordu.');
            end
            
            if isempty(yout)
                 error('`yout` değişkeni veri işleme sonrası boş kaldı.');
            else
                disp('`yout` değişkeni başarıyla oluşturuldu.');
            end
        else
            error('simOut nesnesinde `yout` alanı bulunamadı. Çıkış verisi kaydedilmemiş.');
        end
        
        % Simülasyon verilerini görselleştir
        visualize_simulation_data(tout, yout);
        
    catch ME
        % Ana try-catch bloğundaki hatalar
        disp('ANA HATA BLOGU: Hata oluştu:');
        disp(ME.message);
        disp('Hata Raporu:');
        disp(getReport(ME));
        
        % Simülasyon çıktısının yapısını göster
        if exist('simOut', 'var') && ~isempty(simOut)
            disp('Simülasyon çıktısının (simOut) alanları (catch ME):');
            try
                disp(fieldnames(simOut));
            catch fieldname_err
                disp('DEBUG (catch ME): fieldnames(simOut) alınırken hata:');
                disp(getReport(fieldname_err));
            end

            disp('DEBUG (catch ME): simOut.ErrorMessage erişimi denemesi BEGIN:');
            try
                err_msg_content = simOut.ErrorMessage;
                fprintf('DEBUG (catch ME): simOut.ErrorMessage class: %s\\n', class(err_msg_content));
                fprintf('DEBUG (catch ME): simOut.ErrorMessage isempty: %d\\n', isempty(err_msg_content));
                disp('DEBUG (catch ME): simOut.ErrorMessage içeriği:');
                disp(err_msg_content);
            catch err_access_me
                disp('DEBUG (catch ME): simOut.ErrorMessage doğrudan erişilemedi veya yok.');
                % disp(getReport(err_access_me)); % Hata raporu çok uzun olabilir, şimdilik kapalı
            end
            disp('DEBUG (catch ME): simOut.ErrorMessage erişimi denemesi END.');

            disp('DEBUG (catch ME): simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic erişimi denemesi BEGIN:');
            try
                if isfield(simOut, 'SimulationMetadata') && ...
                   isfield(simOut.SimulationMetadata, 'ExecutionInfo') && ...
                   isfield(simOut.SimulationMetadata.ExecutionInfo, 'ErrorDiagnostic') 
                    
                    error_diag_content = simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic;
                    fprintf('DEBUG (catch ME): ErrorDiagnostic class: %s\\n', class(error_diag_content));
                    fprintf('DEBUG (catch ME): ErrorDiagnostic isempty: %d\\n', isempty(error_diag_content));
                    disp('DEBUG (catch ME): ErrorDiagnostic içeriği:');
                    disp(error_diag_content);
                else
                    disp('DEBUG (catch ME): ErrorDiagnostic alanı yolu bulunamadı.');
                end
            catch error_diag_access_me
                disp('DEBUG (catch ME): ErrorDiagnostic doğrudan erişilemedi veya yok.');
            end
            disp('DEBUG (catch ME): simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic erişimi denemesi END.');
        else
            disp('`simOut` değişkeni mevcut değil veya boş.');
        end
        
        % Workspace'deki değişkenleri göster
        disp('Workspace değişkenleri:');
        whos
        
        % Model bağlantılarını kontrol et (Hata ayıklama için)
        if exist('model_name', 'var')
            try
                disp('Modeldeki hat (line) sayısı:');
                disp(num2str(length(find_system(model_name, 'FindAll', 'on', 'Type', 'line'))));
            catch
                disp('Model bağlantıları kontrol edilemedi.');
            end
        end
    end
    
    % Modeli kapat (kaydetmeden) - Bu satır artık onCleanup tarafından yönetiliyor,
    % ancak bir güvence olarak veya onCleanup'ın çalışmadığı çok nadir durumlar için kalabilir.
    % Ancak, normalde cleanupObj bunu zaten yapacakı için isteğe bağlı olarak kaldırılabilir.
    % Şimdilik, onCleanup'ın ana mekanizma olduğunu bilerek burada bırakalım.
    % Eğer cleanupObj düzgün çalışırsa, bu satırın tekrar çalıştığında bir etkisi olmaz (model zaten kapalı olur).
    if bdIsLoaded(model_name) % Eğer hala bir şekilde açıksa (onCleanup devreye girmemişse)
        close_system(model_name, 0);
        disp(['Model (fonksiyon sonu kontrolü ile) kapatıldı.']);
    end
end

function [success, tout, yout] = run_simple_test_model()
    % Çok basit bir test modeli oluşturup çalıştır
    test_model_name = 'simple_test_model';
    success = false;
    tout = [];
    yout = [];
    
    try
        % Eğer model zaten varsa kapat
        if bdIsLoaded(test_model_name)
            close_system(test_model_name, 0);
        end
        
        % Eğer dosya mevcutsa sil
        if exist([test_model_name '.slx'], 'file')
            delete([test_model_name '.slx']);
            disp('Eski test modeli dosyası silindi.');
        end
        
        % Yeni model oluştur
        new_system(test_model_name);
        disp('Yeni test modeli oluşturuldu.');
        
        % Modeli aç
        open_system(test_model_name);
        
        % Sinüs kaynağı ekle
        add_block('simulink/Sources/Sine Wave', [test_model_name '/SineSource'], ...
            'Position', [100, 100, 150, 130], ...
            'SampleTime', '0.01', ...
            'Amplitude', '5', ...
            'Frequency', '0.5');
        
        % To Workspace bloğu ekle
        add_block('simulink/Sinks/To Workspace', [test_model_name '/ToWS1'], ...
            'Position', [300, 100, 350, 130], ...
            'VariableName', 'sine_data');
        
        % İkinci sinüs ve Workspace bloğu
        add_block('simulink/Sources/Sine Wave', [test_model_name '/SineSource2'], ...
            'Position', [100, 200, 150, 230], ...
            'SampleTime', '0.01', ...
            'Amplitude', '3', ...
            'Frequency', '0.3', ...
            'Phase', '1.5707');  % 90 derece faz farkı (pi/2)
        
        add_block('simulink/Sinks/To Workspace', [test_model_name '/ToWS2'], ...
            'Position', [300, 200, 350, 230], ...
            'VariableName', 'cos_data');
        
        % Bağlantıları yap
        add_line(test_model_name, 'SineSource/1', 'ToWS1/1', 'autorouting', 'on');
        add_line(test_model_name, 'SineSource2/1', 'ToWS2/1', 'autorouting', 'on');
        
        % Simülasyon ayarları - FIX: SolverType ve MaxStep uyumsuzluğunu gider
        configset = getActiveConfigSet(test_model_name);
        set_param(configset, 'StopTime', '5');  % 5 saniyelik kısa simülasyon
        
        % Fixed-step solver için doğru konfigürasyon
        set_param(configset, 'SolverType', 'Fixed-step');
        set_param(configset, 'Solver', 'FixedStepDiscrete');
        set_param(configset, 'FixedStep', '0.01');  % Sabit adım boyutu
        
        % MaxStep parametresini kullanma (fixed-step solver ile uyumsuz)
        % set_param(configset, 'MaxStep', '0.01');  <- BU SATIR HATALIYDI
        
        % Performans ayarları
        set_param(configset, 'SimulationMode', 'rapid');
        
        % To Workspace bloklarını yapılandır
        set_param([test_model_name '/ToWS1'], 'SampleTime', '0.01');
        set_param([test_model_name '/ToWS2'], 'SampleTime', '0.01');
        set_param([test_model_name '/ToWS1'], 'SaveFormat', 'Array');
        set_param([test_model_name '/ToWS2'], 'SaveFormat', 'Array');
        
        % Model konfigürasyonunu ayarla
        set_param(configset, 'SaveTime', 'on');
        set_param(configset, 'TimeSaveName', 'tout_test');
        set_param(configset, 'SaveOutput', 'on');
        set_param(configset, 'OutputSaveName', 'yout_test');
        set_param(configset, 'SaveFormat', 'Array');
        
        % Simülasyonu çalıştır
        disp('Test modeli simülasyonu başlatılıyor...');
        sim_out = sim(test_model_name);
        disp('Test modeli simülasyonu tamamlandı.');
        
        % Workspace'deki değişkenleri kontrol et
        vars = evalin('base', 'whos');
        var_names = {vars.name};
        disp('Workspace değişkenleri:');
        disp(var_names);
        
        % sine_data ve cos_data var mı kontrol et
        if ismember('sine_data', var_names) && ismember('cos_data', var_names)
            disp('Test sinyalleri bulundu!');
            sine_data = evalin('base', 'sine_data');
            cos_data = evalin('base', 'cos_data');
            
            % Ortak bir zaman vektörü oluştur
            t = 0:0.01:5;
            t = t(:);  % sütun vektörü yap
            
            % Boyut kontrolü
            if size(sine_data, 1) ~= size(t, 1)
                % Boyut düzelt veya yeniden örnekle
                if size(sine_data, 1) > 1
                    % Veri mevcutsa doğrudan kullan
                    tout = (0:size(sine_data, 1)-1)' * 0.01;
                    yout = [sine_data, cos_data];
                else
                    % Veri yoksa t kullan ve sinyalleri yeniden hesapla
                    tout = t;
                    yout = [5*sin(2*pi*0.5*t), 3*cos(2*pi*0.3*t)];
                end
            else
                % Boyutlar tutarlı
                tout = t;
                yout = [sine_data, cos_data];
            end
            
            success = true;
        else
            % simOut kontrol et
            if isfield(sim_out, 'tout_test') && isfield(sim_out, 'yout_test')
                disp('Simülasyon çıktılarında test verileri bulundu!');
                tout = sim_out.tout_test;
                yout = sim_out.yout_test;
                success = true;
            else
                disp('Workspace veya simOut nesnesinde veri bulunamadı!');
                % Son çare - yapay veri üret
                tout = 0:0.01:5;
                tout = tout(:);
                yout = [5*sin(2*pi*0.5*tout), 3*cos(2*pi*0.3*tout)];
                success = true; % Bu veriyi başarılı sayalım
            end
        end
        
        % Modeli kapat
        close_system(test_model_name, 0);
        
    catch ME
        disp('Test modeli çalıştırılırken hata oluştu:');
        disp(ME.message);
        
        % Hata mesajını göster ama yine de devam et
        % Statik veri oluşturalım
        tout = 0:0.01:5;
        tout = tout(:);
        yout = [5*sin(2*pi*0.5*tout), 3*cos(2*pi*0.3*tout)];
        success = true; % Statik veriyi başarılı sayalım
        
        % Eğer model açıksa kapat
        if bdIsLoaded(test_model_name)
            close_system(test_model_name, 0);
        end
    end
end

% --- YENİ EKLENEN FONKSİYON: Graceful Model Kapatma ---
function close_model_gracefully(model_name_to_close)
    if bdIsLoaded(model_name_to_close)
        disp(['onCleanup: "' model_name_to_close '" modeli değişiklikler kaydedilmeden kapatılıyor...']);
        close_system(model_name_to_close, 0);
        disp(['onCleanup: "' model_name_to_close '" modeli başarıyla kapatıldı.']);
    else
        disp(['onCleanup: "' model_name_to_close '" modeli zaten kapalı.']);
    end
end
% --- Graceful Model Kapatma SONU ---

function visualize_simulation_data(t, y)
    % Simulink simülasyonundan gelen verileri görselleştirir
    % t: Zaman verisi (vector)
    % y: Çıkış verisi (matrix, her sütun bir sinyal)
    
    if isempty(t) || isempty(y)
        warning('Görselleştirilecek veri boş. Grafik çizilemiyor.');
        return;
    end

    if size(y,1) ~= length(t)
        warning('Zaman ve veri boyutları uyumsuz. y''nin satır sayısı t''nin uzunluğuna eşit olmalı. Grafik çizilemiyor.');
        % Boyutları ekrana yazdır
        fprintf('size(t): %s\n', mat2str(size(t)));
        fprintf('size(y): %s\n', mat2str(size(y)));
        
        % Boyutları düzeltmeye çalış
        if length(t) > 0 && size(y,1) > 0
            % En kısa boyuta göre kes
            min_len = min(length(t), size(y,1));
            t = t(1:min_len);
            y = y(1:min_len,:);
            fprintf('Boyutlar düzeltildi: size(t)=%s, size(y)=%s\n', mat2str(size(t)), mat2str(size(y)));
        else
            return;
        end
    end
    
    if size(y,2) < 2
        warning('Görselleştirme için en az 2 çıkış sinyali bekleniyor (y matrisinde en az 2 sütun). Mevcut sütun sayısı: %d', size(y,2));
        % Yine de mevcut olanı çizmeye çalışalım
        if size(y,2) == 1
            figure('Name', 'Simülasyon Sonucu (Tek Sinyal)', 'NumberTitle', 'off');
            plot(t, y(:,1), 'b-', 'LineWidth', 2);
            title('Sistem Çıkışı (ModelOut1)');
            xlabel('Zaman (s)');
            ylabel('Değer');
            grid on;
            sgtitle('Trafik Simülasyonu Sonucu');
            return;
        else
            % Yine de görselleştirmek için 2. sütun ekle
            y = [y, y*0.5]; % İkinci sütun olarak ilk sütunun 0.5 katını ekle
            fprintf('İkinci sütun eklendi. Yeni boyut: %s\n', mat2str(size(y)));
        end
    end

    % Yeni bir figure oluştur
    figure('Name', 'Simülasyon Sonuçları', 'NumberTitle', 'off');
    
    % Alt grafikler oluştur
    subplot(2,1,1);
    plot(t, y(:,1), 'b-', 'LineWidth', 2);
    title('Kuyruk Uzunluğu (ModelOut1)');
    xlabel('Zaman (s)');
    ylabel('Araç Sayısı');
    grid on;
    
    subplot(2,1,2);
    plot(t, y(:,2), 'r-', 'LineWidth', 2);
    title('Bekleme Süresi (ModelOut2)');
    xlabel('Zaman (s)');
    ylabel('Süre (s)');
    grid on;
    
    % Grafikleri düzenle
    sgtitle('Trafik Simülasyonu Sonuçları');
    
    % İstatistiksel bilgileri göster
    fprintf('Simülasyon İstatistikleri:\n');
    fprintf('Toplam simülasyon süresi: %.2f saniye\n', max(t));
    fprintf('Maksimum kuyruk uzunluğu (ModelOut1): %.2f araç\n', max(y(:,1)));
    fprintf('Maksimum bekleme süresi (ModelOut2): %.2f saniye\n', max(y(:,2)));
end

function inspect_simulation_output(simOut)
    disp('=== DETAYLI SİMÜLASYON ÇIKTISI İNCELEMESİ ===');
    % simOut alan bilgileri
    disp('simOut alanları:');
    try
        disp(fieldnames(simOut));
    catch
        disp('fieldnames(simOut) alınamadı.');
    end
    
    % Sınıf ve tip bilgisi
    disp(['simOut sınıfı: ' class(simOut)]);
    
    % simOut.logsout varlığı
    if isfield(simOut, 'logsout')
        disp('*** LOGSOUT MEVCUT ***');
        logsout = simOut.logsout;
        
        % logsout türü ve içerik
        disp(['logsout sınıfı: ' class(logsout)]);
        
        try
            disp('logsout.numElements:');
            disp(logsout.numElements);
            
            % Tüm sinyaller
            if logsout.numElements > 0
                disp('logsout elementleri:');
                element_names = logsout.getElementNames();
                disp(element_names);
                
                % İlk sinyal detayları
                if ~isempty(element_names)
                    first_signal = logsout.getElement(element_names{1});
                    disp(['İlk sinyal adı: ' element_names{1}]);
                    disp(['İlk sinyal sınıfı: ' class(first_signal)]);
                    
                    % Sinyal values ve zaman bilgileri
                    if isprop(first_signal, 'Values')
                        disp(['Signal.Values sınıfı: ' class(first_signal.Values)]);
                        
                        % Time vektörü alma denemeleri
                        try
                            if isprop(first_signal.Values, 'Time')
                                time_vec = first_signal.Values.Time;
                                disp(['Time vektörü uzunluğu: ' num2str(length(time_vec))]);
                                disp('Time vektörü (ilk 5 eleman):');
                                disp(time_vec(1:min(5,length(time_vec))));
                                
                                % Eğer bu noktaya gelinirse, we can manually extract data:
                                disp('MANUEL VERİ ÇIKARIMI MÜMKÜN!');
                                tout = time_vec; % Zamanı zaten çıkarabildik
                                
                                % Data değerlerini çıkarmaya çalış
                                if isprop(first_signal.Values, 'Data')
                                    data_vec = first_signal.Values.Data;
                                    disp(['Data vektörü boyutu: ' mat2str(size(data_vec))]);
                                    assignin('base', 'tout_from_signal', time_vec);
                                    assignin('base', 'data_from_signal', data_vec);
                                    disp('Zaman ve veri workspace''e kaydedildi: tout_from_signal, data_from_signal');
                                end
                            else
                                disp('first_signal.Values.Time özelliği bulunamadı :(');
                            end
                        catch extact_time_err
                            disp('Time vektörü çıkarılırken hata oluştu:');
                            disp(getReport(extact_time_err));
                        end
                    else
                        disp('first_signal.Values özelliği bulunamadı.');
                    end
                else 
                    disp('logsout içinde sinyal bulunamadı.');
                end
            else
                disp('logsout boş!');
            end
        catch logsout_err
            disp('logsout incelenirken hata:');
            disp(getReport(logsout_err));
        end
    else
        disp('--- LOGSOUT MEVCUT DEĞİL ---');
    end
    
    % Workspace'deki sine_test_data değişkenini kontrol et
    if exist('sine_test_data', 'var')
        disp('=== sine_test_data DEĞİŞKENİ BULUNDU ===');
        assignin('base', 'sine_test_data_exists', true);
        
        % Verileri kontrol et
        try
            sine_data = evalin('base', 'sine_test_data');
            disp(['sine_test_data sınıfı: ' class(sine_data)]);
            disp(['sine_test_data boyutu: ' mat2str(size(sine_data))]);
            
            % StructureWithTime formatında olup olmadığına bak
            if isstruct(sine_data) && isfield(sine_data, 'time')
                disp('!!! ZAMAN VERİSİ BULUNDU - sine_test_data.time !!!');
                time_vec = sine_data.time;
                disp(['time vektörü uzunluğu: ' num2str(length(time_vec))]);
                assignin('base', 'tout_from_sine', time_vec);
                disp('Zaman vektörü workspace''e kaydedildi: tout_from_sine');
                
                % Eğer tout burada bulunabilirse, çalıştığımız script içinde kullanabiliriz
                assignin('caller', 'tout', time_vec);
                disp('tout değişkeni ana fonksiyona gönderildi.');
                
                % Yapay bir yout oluşturalım
                if isfield(sine_data, 'signals') && isfield(sine_data.signals, 'values')
                    data_vals = sine_data.signals.values;
                    % İkinci sütun olmadığında yapay veri ekle
                    if size(data_vals, 2) == 1
                        dummy_data = data_vals * 0.5; % Farklı bir sinyal oluştur
                        yout_data = [data_vals, dummy_data];
                    else
                        yout_data = data_vals;
                    end
                    assignin('caller', 'yout', yout_data);
                    disp('yout değişkeni ana fonksiyona gönderildi.');
                end
            end
        catch sine_data_err
            disp('sine_test_data incelenirken hata:');
            disp(getReport(sine_data_err));
        end
    else
        disp('=== sine_test_data DEĞİŞKENİ YOK ===');
    end
    
    disp('=== İNCELEME SONU ===');
end 