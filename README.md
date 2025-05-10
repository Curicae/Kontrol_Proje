# MATLAB Trafik Simülasyon Projesi

Bu proje, kavşaklardaki trafik akışını simüle etmek ve trafik ışıklarının zamanlamalarını PID kontrolcü kullanarak optimize etmek için geliştirilmiş bir MATLAB uygulamasıdır. Projede hem MATLAB script tabanlı simülasyon motoru hem de otomatik oluşturulan bir Simulink modeli bulunmaktadır.

## Özellikler

* Farklı kavşak konumları için yapılandırılabilir trafik senaryoları
* Trafik yoğunluğu verisi için Overpass API entegrasyonu
* Trafik ışığı zamanlamalarını dinamik olarak ayarlayan PID kontrolcü
* Kavşak durumu ve performans metrikleri için gerçek zamanlı görselleştirme
* Programatik olarak oluşturulan Simulink modeli (`.slx`)
* MATLAB R2024b için özel olarak tasarlanmış yapı

## Proje Yapısı

Projenin dosya ve klasör yapısı:

* **Ana Dizin:**
  * `main_simulation.m`: Ana simülasyonu çalıştıran script
  * `run_config.m`: Yapılandırma ayarları için interaktif arayüz
  * `create_traffic_model.m`: Simulink modelini otomatik olarak oluşturur
  * `initialize_parameters.m`: Simülasyon parametrelerini tanımlar
  * `traffic_data.m`: API'den trafik verisi almak için fonksiyonlar
  * `test_traffic_model.m`: Simulink model oluşturma testleri
  * `config.m` ve `config.mat`: Yapılandırma verileri
  * `README.md`: Bu dokümantasyon dosyası

* **src/**: Kaynak kod klasörü
  * `control/`: Kontrol algoritmaları
  * `metrics/`: Ölçüm ve kayıt fonksiyonları
  * `traffic/`: Trafik modelleme fonksiyonları
  * `utils/`: Yardımcı fonksiyonlar ve görselleştirme araçları

* **test/**: Test scriptleri
  * `test_overpass_api.m`: API entegrasyon testi

## Kurulum ve Çalıştırma

### Gereksinimler

* MATLAB R2024b
* Simulink
* Control System Toolbox
* İnternet bağlantısı (API kullanımı için)

### MATLAB R2024b Özellikleri

> **ÖNEMLİ:** Bu proje, MATLAB R2024b'nin özelliklerini kullanmaktadır:
> 
> * `Uniform Random Number` bloğu kullanılmaktadır
> * `Switch` bloğunda `u2~=0` formatı kullanılmaktadır
> * `Relational Operator` bloğu kullanılarak sıfırla karşılaştırma yapılmaktadır
> * Modern Simulink blok parametreleri ve bağlantı API'leri kullanılmaktadır

### Çalıştırma Adımları

1. **Yapılandırma:**
   ```matlab
   run('run_config.m')
   ```
   Kavşak konumu ve API kullanımı gibi ayarları yapılandırır.

2. **Ana Simülasyon:**
   ```matlab
   run('main_simulation.m')
   ```
   Tam simülasyonu başlatır ve görsel çıktılar sağlar.

3. **Simulink Modeli Oluşturma:**
   ```matlab
   run('create_traffic_model.m')
   ```
   `traffic_light_model.slx` dosyasını oluşturur.

4. **API Testi (İsteğe Bağlı):**
   ```matlab
   cd test
   run('test_overpass_api.m')
   ```
   API bağlantısını ve veri işleme özelliklerini test eder.

## Mevcut Durum

* **API Entegrasyonu:** Overpass API entegrasyonu tamamlanmış, veri işleme sorunları çözülmüştür.
* **İki Modül:** Script-tabanlı (`main_simulation.m`) ve model-tabanlı (`traffic_light_model.slx`) simülasyonlar ayrı modüllerde çalışmaktadır.
* **MATLAB Uyumluluğu:** Bu proje özellikle MATLAB R2024b için optimize edilmiştir.

## Gelecek Geliştirmeler

* API veri işleme mekanizmasının daha da güçlendirilmesi
* Simulink modelinin ana simülasyonla tam entegrasyonu
* Q-learning ve Fuzzy Logic gibi alternatif kontrol stratejilerinin uygulanması
* Kullanıcı dostu bir grafik arayüzü geliştirilmesi (MATLAB App Designer)
* Çoklu kavşak koordinasyonu
* Gerçek dünyadaki sensörlerle entegrasyon

## Sorun Giderme

* **MATLAB Sürüm Uyumluluğu:** Bu proje sadece MATLAB R2024b ile çalışmak üzere tasarlanmıştır, diğer sürümlerde çalıştırmak için script'lerin güncellenmesi gerekebilir
* **API Bağlantı Hatası:** Internet bağlantınızı kontrol edin veya `config.m` dosyasından alternatif API URL'sini yapılandırın
* **Model Oluşturma Hataları:** `create_traffic_model.m` dosyasındaki modül parametrelerini ve bağlantıları kontrol edin

## Katkıda Bulunanlar

* MATLAB Trafik Simülasyon Ekibi

## Lisans

* Bu proje eğitim amaçlı olup, akademik kullanım için serbestçe dağıtılabilir.

---

Son Güncelleme: Mayıs 2024