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
   - **Neden Kullanmalısınız?**: Tek bir komutla tüm simülasyon ve görselleştirme sürecini yönetir. Bu script en kolay ve en güvenilir simülasyon çalıştırma yöntemidir.
   - **Çalışma Mantığı**: 
     1. Önce ana simülasyonu çalıştırmayı dener (run_simulation.m veya run_simulation_with_visualization.m)
     2. Başarısız olursa basit test modelini çalıştırır
     3. O da başarısız olursa sentetik test verisi oluşturur
     4. Son olarak hem temel hem de gelişmiş görselleştirmeleri gerçekleştirir
   - **Çıktılar**: Trafik kuyruk uzunlukları, bekleme süreleri, trafik yoğunlukları ve PID kontrolcü performansına dair grafikler
   - **Bağımlılıklar**: traffic_visualization.m, advanced_traffic_viz.m, test_visualization.m, run_simulation_with_visualization.m

2. **run_simulation.m** 
   - **İşlev**: Trafik simülasyonunu basit şekilde çalıştıran script.
   - **Neden Kullanmalısınız?**: Görselleştirme olmadan sadece simülasyonu çalıştırmak istediğinizde kullanılır. Simülasyon sonuçlarını workspace'e kaydeder.
   - **Çalışma Mantığı**: Simulink modelini açar, parametreleri ayarlar ve simülasyonu çalıştırır.
   - **Çıktılar**: Workspace'e simülasyon sonuçlarını kaydeder: t (zaman vektörü), queue_lengths (kuyruk uzunlukları), average_wait_time_EW/NS (yönlere göre bekleme süreleri), density_EW/NS (yönlere göre trafik yoğunlukları)
   - **Bağımlılıklar**: traffic_light_model.slx, config.m

3. **run_simulation_with_visualization.m**
   - **İşlev**: Simülasyonu çalıştıran ve sonuçları görselleştiren kapsamlı fonksiyon.
   - **Neden Kullanmalısınız?**: Simülasyonu çalıştırıp sonuçları otomatik olarak görselleştirmek istediğinizde kullanılır. Ayrıca ana model çalışmazsa otomatik olarak test modeli oluşturur ve çalıştırır.
   - **Çalışma Mantığı**: 
     1. Ana modeli çalıştırmayı dener
     2. Çalışmazsa içindeki run_simple_test_model() fonksiyonuyla basit bir test modeli oluşturur
     3. Elde edilen verileri visualize_simulation_data() fonksiyonuyla görselleştirir
   - **Çıktılar**: 
     * İki panelli grafik (üstte kuyruk uzunluğu, altta bekleme süresi)
     * Konsola simülasyon istatistikleri (maksimum kuyruk uzunluğu, maksimum bekleme süresi)
   - **Bağımlılıklar**: traffic_light_model.slx, (içerisindeki) run_simple_test_model fonksiyonu

### Simulink Modeli Oluşturma ve Yapılandırma
4. **create_traffic_model.m**
   - **İşlev**: Trafik ışığı Simulink modelini programatik olarak oluşturur.
   - **Neden Kullanmalısınız?**: Manuel olarak model oluşturmak yerine, tutarlı ve hatasız bir model yapısı oluşturmak için. Özellikle model yapısında değişiklikler yapmanız gerekiyorsa bu script kullanışlıdır.
   - **Çalışma Mantığı**: Model bileşenlerini (bloklar, alt sistemler, bağlantılar) MATLAB komutlarıyla tanımlar ve bağlantılarını yapar.
   - **Çıktılar**: traffic_light_model.slx dosyasını oluşturur/günceller ve yapılandırır.
   - **Bağımlılıklar**: initialize_parameters.m

5. **main_simulation.m**
   - **İşlev**: Ana simülasyon süreci ve algoritmasını içerir.
   - **Neden Kullanmalısınız?**: Simulink modeli yerine MATLAB kodu üzerinden simülasyon çalıştırmak istediğinizde kullanılır. Daha fazla esneklik sağlar ve MATLAB betikleme özellikleriyle simülasyonu kontrol etmenize olanak tanır.
   - **Çalışma Mantığı**: Trafik akışını, ışık durumlarını ve PID kontrolcü davranışını adım adım hesaplar.
   - **Çıktılar**: Simulink modeline benzer çıktılar üretir: kuyruk uzunlukları, bekleme süreleri, trafik yoğunlukları.
   - **Bağımlılıklar**: traffic_data.m, config.m

6. **initialize_parameters.m**
   - **İşlev**: Simülasyon parametrelerini başlatır.
   - **Neden Kullanmalısınız?**: Simülasyon parametrelerini merkezi bir yerden yönetmek ve tutarlı parametre ayarlarını kullanmak için.
   - **Çalışma Mantığı**: PID kontrolcü parametreleri, trafik akış parametreleri, simülasyon süresi gibi değişkenleri tanımlar ve workspace'e aktarır.
   - **Çıktılar**: Doğrudan görsel çıktı olmamakla birlikte, workspace'e tüm simülasyon parametrelerini aktarır.
   - **Bağımlılıklar**: config.m

### Görselleştirme Araçları
7. **traffic_visualization.m**
   - **İşlev**: Trafik simülasyon sonuçlarını görselleştiren bağımsız fonksiyon.
   - **Neden Kullanmalısınız?**: Simülasyon sonuçlarını görsel olarak incelemek ve temel metrikleri analiz etmek için. Basit, anlaşılır grafikler sunar.
   - **Çalışma Mantığı**: 
     1. Workspace'de bulunan değişkenleri (log_time, t, queue_lengths, vb.) akıllıca tespit eder
     2. Veri yoksa otomatik olarak sentetik veri oluşturur
     3. İki panelli bir grafik çizer ve konsola simülasyon istatistiklerini yazdırır
   - **Çıktılar**: 
     * İki panelli grafik: 
       - Üst panel: Kuyruk uzunluğu / trafik yoğunluğu grafiği
       - Alt panel: Bekleme süresi grafiği
     * Konsol çıktısı: Toplam simülasyon süresi, maksimum kuyruk uzunluğu, maksimum bekleme süresi
   - **Bağımlılıklar**: (Bağımsız çalışır, workspace'deki değişkenleri kullanır)

8. **advanced_traffic_viz.m**
   - **İşlev**: Gelişmiş görselleştirme araçları sunan kapsamlı fonksiyon.
   - **Neden Kullanmalısınız?**: Simülasyon sonuçlarını daha detaylı ve çeşitli açılardan incelemek istediğinizde. Temel görselleştirmeden çok daha kapsamlı analiz araçları sunar.
   - **Çalışma Mantığı**: 
     1. traffic_visualization.m'e benzer şekilde veri tespit eder veya oluşturur
     2. Çok panelli grafikler ve 3B görselleştirmeler oluşturur
     3. Ayrı bir pencerede kavşak görünümü animasyonu gösterir
   - **Çıktılar**: 
     * Çok panelli ana grafik penceresi:
       - Kuyruk uzunlukları (Doğu-Batı ve Kuzey-Güney)
       - Trafik yoğunlukları
       - Ortalama bekleme süreleri
       - Yeşil ışık süreleri
       - 3B görselleştirme (Yoğunluk vs Bekleme Süresi vs Zaman)
     * Kavşak Durum Görselleştirmesi penceresi:
       - Simülasyonun son anındaki kavşağın durumu
       - Trafik ışıklarının durumu ve araç kuyruklarının anında görsel temsili
       - Simülasyon sonucunu sezgisel olarak anlamanızı sağlar

9. **test_visualization.m**
   - **İşlev**: Sentetik test verisi oluşturur ve görselleştirir.
   - **Neden Kullanmalısınız?**: Simülasyon modelini çalıştıramadığınızda veya test amaçlı gerçekçi veri seti oluşturmak istediğinizde kullanılır.
   - **Çalışma Mantığı**: 
     1. Sinüs fonksiyonları kullanarak gerçekçi trafik dalgalanmaları içeren sentetik veri oluşturur
     2. Tüm gerekli değişkenleri (zaman, kuyruk uzunlukları, yoğunluklar, bekleme süreleri) hesaplar
     3. Bu verileri workspace'e aktarır ve traffic_visualization fonksiyonuyla görselleştirir
   - **Çıktılar**: 
     * traffic_visualization ile aynı görsel çıktılar
     * Workspace'e aktarılan çeşitli değişkenler: log_time, log_vehicle_queues, density_EW/NS, average_wait_time_EW/NS, vb.
   - **Bağımlılıklar**: traffic_visualization.m

### Test ve Yardımcı Scriptler
10. **test_traffic_model.m**
    - **İşlev**: Trafik modeli doğrulama testi yapar.
    - **Neden Kullanmalısınız?**: Model oluşturma sürecini test etmek, olası hataları tespit etmek ve modelin doğru çalıştığını doğrulamak istediğinizde.
    - **Çalışma Mantığı**: create_traffic_model.m fonksiyonunu çağırır, model bileşenlerini kontrol eder ve olası hataları yakalar ve raporlar.
    - **Çıktılar**: Konsola test sonuçlarını ve olası hataları raporlar. Grafik çıktısı yoktur.
    - **Bağımlılıklar**: create_traffic_model.m

11. **traffic_data.m**
    - **İşlev**: Trafik verisi üretme ve işleme algoritmaları.
    - **Neden Kullanmalısınız?**: Gerçekçi trafik verisi üretmek veya dış kaynaklardan (OpenStreetMap gibi) veri almak için.
    - **Çalışma Mantığı**: 
      1. Gerçek trafik verisine benzer trafik akış modelleri üretir
      2. Farklı trafik senaryolarını (normal, yoğun, acil durum) simüle eder
      3. İsteğe bağlı olarak dış API'lerden veri çekebilir
    - **Çıktılar**: Doğrudan görsel çıktısı yoktur, ancak simülasyon için gerekli trafik verilerini üretir.
    - **Bağımlılıklar**: (Bağımsız çalışabilir veya harici veri kaynaklarına bağlı olabilir)

12. **config.m**
    - **İşlev**: Temel konfigürasyon değerlerini tanımlar.
    - **Neden Kullanmalısınız?**: Proje genelinde kullanılan tüm parametreleri merkezi bir yerden tanımlamak ve yönetmek için.
    - **Çalışma Mantığı**: Simülasyon süresi, zaman adımı, PID parametreleri, ışık süreleri gibi temel konfigürasyon değerlerini bir struct içinde tanımlar ve workspace'e aktarır.
    - **Çıktılar**: Doğrudan görsel çıktısı yoktur, sadece konfigürasyon parametrelerini tanımlar.
    - **Bağımlılıklar**: (Bağımsız çalışır)

13. **run_config.m**
    - **İşlev**: Konfigürasyon parametrelerini yükleme, değiştirme ve kaydetme işlemlerini yapar.
    - **Neden Kullanmalısınız?**: Farklı simülasyon senaryoları için farklı konfigürasyon setleri oluşturmak ve yönetmek istediğinizde.
    - **Çalışma Mantığı**: 
      1. Mevcut konfigürasyon dosyasını yükler (config.mat)
      2. Kullanıcıya konfigürasyon değişikliği yapma imkanı sunar
      3. Yeni konfigürasyonu config.mat dosyasına kaydeder
    - **Çıktılar**: Doğrudan görsel çıktısı yoktur, ancak konfigürasyon değişikliklerini konsola raporlar.
    - **Bağımlılıklar**: config.m, config.mat

## Çıktılar ve Grafikler Açıklaması

### Temel Görselleştirme (traffic_visualization.m)
- **Kuyruk Uzunluğu / Trafik Yoğunluğu Grafiği**: 
  - **X-ekseni**: Zaman (saniye)
  - **Y-ekseni**: Araç sayısı veya normalize edilmiş yoğunluk (0-1)
  - **Amaç**: Simülasyon boyunca kavşaktaki araç sayısının nasıl değiştiğini gösterir
  - **Nasıl Yorumlanır**: Yüksek değerler trafik sıkışıklığını, düşük değerler akıcı trafiği gösterir

- **Bekleme Süresi Grafiği**:
  - **X-ekseni**: Zaman (saniye)
  - **Y-ekseni**: Bekleme süresi (saniye)
  - **Amaç**: Araçların ortalama bekleme süresinin zaman içindeki değişimini gösterir
  - **Nasıl Yorumlanır**: PID kontrolcünün performansını değerlendirmede önemlidir, düşük bekleme süreleri daha iyi trafik akışı sağlandığını gösterir

### Gelişmiş Görselleştirme (advanced_traffic_viz.m)
- **Trafik Kuyruk Uzunlukları**:
  - Doğu-Batı (mavi) ve Kuzey-Güney (kırmızı) yönlerindeki araç kuyruklarını ayrı ayrı gösterir
  - İki yönün karşılaştırmasını yapmanızı sağlar
  
- **Trafik Yoğunlukları**:
  - Kuyruk uzunluklarının normalize edilmiş hali (0-1 arası)
  - Farklı kapasiteli yolları karşılaştırmayı kolaylaştırır
  
- **Ortalama Bekleme Süreleri**:
  - Her iki yön için ayrı ayrı bekleme sürelerini gösterir
  - PID kontrolcünün her yöndeki etkinliğini değerlendirmenizi sağlar
  
- **Yeşil Işık Süreleri**:
  - PID kontrolcünün her yön için belirlediği yeşil ışık sürelerini gösterir
  - Kontrolcünün dinamik olarak nasıl tepki verdiğini anlamanızı sağlar
  
- **3B Görselleştirme (Yoğunluk vs Bekleme Süresi vs Zaman)**:
  - Yoğunluk ve bekleme süresinin zaman içindeki ilişkisini üç boyutlu gösterir
  - Sistemin dinamik davranışını anlamanızı sağlar
  
- **Kavşak Durum Görselleştirmesi**:
  - Simülasyonun son anındaki kavşak durumunu gösterir
  - Trafik ışıklarının durumu ve araç kuyruklarının anında görsel temsili
  - Simülasyon sonucunu sezgisel olarak anlamanızı sağlar

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
