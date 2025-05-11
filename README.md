# PID Kontrollü Trafik Işığı Simülasyonu

## Proje Hakkında
Bu proje, gerçek zamanlı trafik verilerini kullanarak PID kontrolcü ile yönetilen bir trafik ışığı simülasyonu gerçekleştirmektedir. Proje, OpenStreetMap verilerini kullanarak gerçek dünya trafik koşullarını simüle eder ve PID kontrolcü ile trafik akışını optimize eder.


## Proje Amacı
Bu projenin temel amacı:
1. Gerçek zamanlı trafik verilerini kullanarak trafik simülasyonu yapmak
2. PID kontrolcü ile trafik ışığı sürelerini optimize etmek
3. Trafik yoğunluğuna göre dinamik olarak ışık sürelerini ayarlamak
4. Simülasyon sonuçlarını görselleştirmek ve analiz etmek

## Kullanılan Teknolojiler
- MATLAB R2024b
- Simulink
- Overpass API (OpenStreetMap veri erişimi)
- PID Kontrol Teorisi

## Proje Yapısı
```
Kontrol_Proje/
├── Modeller/
│   ├── traffic_light_model.slx    # Ana Simulink modeli
│   └── traffic_light_model_1.slx  # Alternatif Simulink modeli
├── Simülasyon Araçları/
│   ├── create_traffic_model.m     # Model oluşturma scripti
│   ├── main_simulation.m          # Ana simülasyon scripti
│   ├── run_simulation.m           # Basit simülasyon çalıştırıcı
│   ├── run_simulation_with_visualization.m # Gelişmiş simülasyon+görselleştirme
│   └── initialize_parameters.m    # Parametre başlatma scripti
├── Görselleştirme Araçları/
│   ├── traffic_visualization.m    # Temel görselleştirme fonksiyonu
│   ├── advanced_traffic_viz.m     # Gelişmiş görselleştirme araçları
│   └── test_visualization.m       # Test verisi oluşturma ve görselleştirme
├── Yardımcı Araçlar/
│   ├── run_traffic_simulation.m   # Ana koordinasyon scripti
│   ├── test_traffic_model.m       # Trafik modeli test scripti
│   ├── traffic_data.m             # Trafik verisi oluşturma
│   ├── run_config.m               # Konfigürasyon ayarları scripti 
│   └── config.m                   # Temel konfigürasyon dosyası
├── Veri/
│   ├── traffic_config.mat         # Trafik konfigürasyon verisi
│   └── config.mat                 # Genel konfigürasyon verisi
├── src/                           # Kaynak kodları
├── utils/                         # Yardımcı fonksiyonlar
├── test/                          # Test dosyaları 
└── docs/                          # Proje dokümantasyonu
```


### Çalıştırma Seçenekleri
- **Tam Simülasyon ve Görselleştirme** (önerilen):
  ```matlab
  run('run_traffic_simulation.m')
  ```
  Bu komut, ana modeli veya test modelini çalıştırmayı dener, başarısız olursa sentetik veri oluşturur ve tüm görselleştirmeleri yapar.

- **Sadece Görselleştirme**:
  ```matlab
  traffic_visualization()  % Temel görselleştirme
  advanced_traffic_viz()   % Gelişmiş görselleştirme
  ```

- **Test Verisi Oluşturma**:
  ```matlab
  run('test_visualization.m')
  ```

- **Manuel Simülasyon**:
  ```matlab
  run_simulation_with_visualization()
  ```

## Ayrıntılı Script Açıklamaları

### Ana Koordinasyon ve Çalıştırma Scriptleri
1. **run_traffic_simulation.m**
   - **İşlev**: Tüm simülasyon sürecini koordine eden merkezi script. 
   - **Ayrıntı**: Önce ana simülasyonu, sonra test modelini çalıştırmayı dener, ikisi de başarısız olursa sentetik veri oluşturur ve görselleştirme yapar. Tüm hata durumlarını ele alır.
   - **Bağımlılıklar**: traffic_visualization.m, advanced_traffic_viz.m, test_visualization.m, run_simulation_with_visualization.m

2. **run_simulation.m** 
   - **İşlev**: Trafik simülasyonunu basit şekilde çalıştıran script.
   - **Ayrıntı**: Sadece simülasyonu çalıştırır, görselleştirme yapmaz.
   - **Bağımlılıklar**: traffic_light_model.slx, config.m

3. **run_simulation_with_visualization.m**
   - **İşlev**: Simülasyonu çalıştıran ve sonuçları görselleştiren kapsamlı fonksiyon.
   - **Ayrıntı**: İçerisinde basit bir test modeli çalıştırma fonksiyonu (run_simple_test_model) ve görselleştirme fonksiyonu (visualize_simulation_data) barındırır. Verileri model çalıştıktan sonra otomatik görselleştirir.
   - **Bağımlılıklar**: traffic_light_model.slx, (içerisindeki) run_simple_test_model fonksiyonu

### Simulink Modeli Oluşturma ve Yapılandırma
4. **create_traffic_model.m**
   - **İşlev**: Trafik ışığı Simulink modelini programatik olarak oluşturur.
   - **Ayrıntı**: Tüm model bileşenlerini (blokları, alt sistemleri, bağlantıları) oluşturur ve yapılandırır.
   - **Bağımlılıklar**: initialize_parameters.m

5. **main_simulation.m**
   - **İşlev**: Ana simülasyon süreci ve algoritmasını içerir.
   - **Ayrıntı**: Simülasyon adımlarını, lojiğini ve veri toplama süreçlerini yönetir.
   - **Bağımlılıklar**: traffic_data.m, config.m

6. **initialize_parameters.m**
   - **İşlev**: Simülasyon parametrelerini başlatır.
   - **Ayrıntı**: Tüm PID kontrolcü parametreleri, trafik akış parametreleri, simülasyon süresi gibi değerleri ayarlar.
   - **Bağımlılıklar**: config.m

### Görselleştirme Araçları
7. **traffic_visualization.m**
   - **İşlev**: Trafik simülasyon sonuçlarını görselleştiren bağımsız fonksiyon.
   - **Ayrıntı**: Workspace'deki değişkenleri akıllıca bulur ve kuyruk uzunluğu/bekleme süresi grafiklerini çizer.
   - **Bağımlılıklar**: (Bağımsız çalışır, workspace'deki değişkenleri kullanır)

8. **advanced_traffic_viz.m**
   - **İşlev**: Gelişmiş görselleştirme araçları sunan kapsamlı fonksiyon.
   - **Ayrıntı**: Çoklu grafikler, 3B görselleştirme, ve kavşak görünümü animasyonu oluşturur.
   - **Bağımlılıklar**: (Bağımsız çalışır, workspace'deki değişkenleri kullanır)

9. **test_visualization.m**
   - **İşlev**: Sentetik test verisi oluşturur ve görselleştirir.
   - **Ayrıntı**: Trafik kuyrukları, yoğunluklar, ve bekleme süreleri için sentetik veriler üretir.
   - **Bağımlılıklar**: traffic_visualization.m

### Test ve Yardımcı Scriptler
10. **test_traffic_model.m**
    - **İşlev**: Trafik modeli doğrulama testi yapar.
    - **Ayrıntı**: Model oluşturma sürecini test eder, hataları yakalar ve raporlar.
    - **Bağımlılıklar**: create_traffic_model.m

11. **traffic_data.m**
    - **İşlev**: Trafik verisi üretme ve işleme algoritmaları.
    - **Ayrıntı**: OpenStreetMap verilerini işleyerek trafik simülasyonu için gerekli verileri üretir.
    - **Bağımlılıklar**: (Bağımsız çalışabilir veya harici veri kaynaklarına bağlı olabilir)

12. **config.m**
    - **İşlev**: Temel konfigürasyon değerlerini tanımlar.
    - **Ayrıntı**: Tüm simülasyon ayarlarını ve varsayılan parametreleri içerir.
    - **Bağımlılıklar**: (Bağımsız çalışır)

13. **run_config.m**
    - **İşlev**: Konfigürasyon parametrelerini yapılandırır ve uygular.
    - **Ayrıntı**: Kullanıcı arayüzü olmaksızın konfigürasyon değişikliklerini yapmayı sağlar.
    - **Bağımlılıklar**: config.m, config.mat

## Gereksiz Olabilecek Scriptler ve Öneriler
- **run_simulation.m** ve **run_simulation_with_visualization.m** benzer işlevlere sahiptir. run_simulation.m, run_simulation_with_visualization.m içindeki işlevselliğin bir alt kümesini sağlar.
- **config.m** ve **run_config.m** işlevselliği birleştirilebilir.
- Eğer **traffic_light_model_1.slx** eski bir sürüm ise ve kullanılmıyorsa kaldırılabilir.

## Simülasyon Parametreleri
- Simülasyon süresi: 1 saat (tam modelde), 5 saniye (test modelinde)
- Zaman adımı: 1 saniye (tam modelde), 0.01 saniye (test modelinde)
- Minimum yeşil süre: 15 saniye
- Maksimum yeşil süre: 90 saniye
- Sarı ışık süresi: 3 saniye

## PID Kontrolcü Parametreleri
- Kuzey-Güney yönü:
  - Kp: 0.5
  - Ki: 0.1
  - Kd: 0.05
- Doğu-Batı yönü:
  - Kp: 0.5
  - Ki: 0.1
  - Kd: 0.05

## Test Senaryoları
1. Normal trafik yoğunluğu
2. Yoğun trafik durumu
3. Dengesiz trafik dağılımı
4. Acil durum senaryoları

## Sorun Giderme
- **Simulink Modeli Çalışmıyor**: `run_traffic_simulation.m` otomatik olarak test modeli veya sentetik veri kullanır.
- **Fixed-Step Solver Hatası**: SolverType ve MaxStep çakışması düzeltildi. Fixed-step solver kullanırken MaxStep parametresini kullanmayın.
- **Veri Görselleştirilemiyor**: Workspace'de şu değişkenlerin olup olmadığını kontrol edin: 'log_time', 't', 'log_vehicle_queues', 'queue_lengths', 'average_wait_time_EW', 'density_EW'.
- **Hata Mesajları**: Detailed model validation error veya Block not found gibi hata mesajları için create_traffic_model.m scriptinin düzgün çalıştığından emin olun.

## Sonuçlar ve Analiz
Proje, aşağıdaki metrikleri ölçer ve analiz eder:
- Ortalama bekleme süreleri
- Kuyruk uzunlukları
- Trafik yoğunluğu dağılımı
- PID kontrolcü performansı
