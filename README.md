# Trafik Işığı Simülasyonu ve PID Kontrolcüsü

Bu proje, PID kontrol algoritması ile çalışan akıllı bir trafik ışığı simülasyon sistemi içermektedir. Sistem, MATLAB ve Simulink kullanarak trafik akışını modellemekte ve optimize etmektedir.

## Proje Hakkında

Bu sistem şunları içerir:
- Adaptif trafik ışığı kontrolcüsü
- PID tabanlı zamanlama algoritması
- Trafik yoğunluğu simülasyonu
- Gerçek zamanlı trafik verileri için API entegrasyonu
- Performans metrikleri ve görselleştirme araçları

## Dosya Yapısı

```
Kontrol_Proje/
├── config.m                    # Yapılandırma ayarları
├── run_config.m                # Kolay yapılandırma arayüzü 
├── create_simulink_model.m     # Simulink modeli oluşturma
├── create_stateflow_chart.m    # Stateflow diyagramı oluşturma
├── create_traffic_controller.m # Trafik kontrolcüsü oluşturma
├── create_traffic_model.m      # Trafik modeli oluşturma
├── initialize_parameters.m     # Simülasyon parametreleri
├── main_simulation.m           # Ana simülasyon dosyası
├── src/                        # Kaynak kod klasörü
│   ├── api/                    # API entegrasyonları
│   │   └── traffic_data.m      # Trafik veri kaynakları
│   ├── control/                # Kontrol algoritmaları
│   │   ├── pid_controller.m    # PID kontrolcüsü
│   │   └── update_light_state.m # Işık durumu güncelleme
│   ├── metrics/                # Metrik hesaplamaları
│   │   └── record_metrics.m    # Metrikleri kaydetme
│   └── traffic/                # Trafik modelleme
│       ├── calculate_density.m # Trafik yoğunluğu hesaplama
│       ├── generate_vehicles.m # Araç oluşturma
│       └── move_vehicles.m     # Araç hareketlerini simüle etme
├── test/                       # Test scriptleri
│   └── test_overpass_api.m     # API entegrasyonunu test et
└── utils/                      # Yardımcı fonksiyonlar
    ├── plot_metrics.m          # Metrikleri görselleştirme
    └── visualize_intersection.m # Kavşağı görselleştirme
```

## Başlangıç

1. Kolay başlangıç için `run_config.m` dosyasını çalıştırın:
   ```matlab
   run('run_config.m')
   ```
   Bu komut interaktif bir yapılandırma arayüzü açacaktır.

2. Veya manuel olarak `config.m` dosyasını düzenleyin ve çalıştırın:
   ```matlab
   run('config.m')
   ```

3. `main_simulation.m` dosyasını çalıştırarak simülasyonu başlatın:
   ```matlab
   run('main_simulation.m')
   ```

## API Entegrasyonu

Sistem, trafik verilerini gerçek zamanlı olarak almak için çeşitli API'leri desteklemektedir:

1. **Overpass API** (Ücretsiz, API anahtarı gerektirmez)
   - OpenStreetMap verilerine erişim sağlar
   - Hiçbir ücret ödemeden kullanılabilir
   - Yol verilerinden trafik yoğunluğu hesaplanır

2. **OpenStreetMap API**
   - Temel harita verileri için kullanılabilir
   - Ücretsizdir ancak kullanım sınırlamaları vardır

3. **TomTom API** (API anahtarı gerektirir)
   - Daha detaylı trafik verileri sunar
   - Ücretli bir hizmettir ve API anahtarı gerektirir

### Overpass API Kullanımı

Overpass API kullanmak için (`run_config.m` ile ya da doğrudan `config.m` dosyasında):

```matlab
configuration.use_overpass = true;
configuration.overpass_radius = 500; % Kavşak çevresindeki yarıçap (metre)
config = configuration;
save('config.mat', 'config');
```

API entegrasyonunu test etmek için:

```matlab
cd test
run('test_overpass_api.m')
```

## Simülasyon Parametreleri

Simülasyon parametrelerini `initialize_parameters.m` dosyasında ayarlayabilirsiniz:

- Işık süreleri
- Trafik oluşturma oranları
- PID parametreleri
- Simülasyon süresi

## Görselleştirme

Simülasyon iki görselleştirme penceresi gösterir:
1. Trafik ışığı kavşağı animasyonu
2. Kuyruk uzunlukları ve ortalama bekleme süresi grafikleri

## Geliştirme

Yeni özellikler eklemek için, ilgili modülleri genişletebilirsiniz:
- Yeni trafik senaryoları için `src/traffic/` klasörü
- Yeni kontrol algoritmaları için `src/control/` klasörü
- Yeni API entegrasyonları için `src/api/` klasörü

## Sorun Giderme

- **config.m hataları**: İsim çakışmasını önlemek için daima `configuration` yapısını kullanın ve en son `config = configuration` ile kaydedin.
- **API hataları**: İnternet bağlantınızı kontrol edin ve `test/test_overpass_api.m` ile API'yi test edin.
- **Simulink hataları**: MATLAB sürümünüz ile uyumu kontrol edin.

---

## Katkıda Bulunanlar
- [İsminizi buraya ekleyin]

## Lisans
Tüm hakları saklıdır © 2023