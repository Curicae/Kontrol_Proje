# PID Kontrollü Trafik Işığı Simülasyonu

## Proje Hakkında
Bu proje, gerçek zamanlı trafik verilerini kullanarak PID kontrolcü ile yönetilen bir trafik ışığı simülasyonu gerçekleştirmektedir. Proje, OpenStreetMap verilerini kullanarak gerçek dünya trafik koşullarını simüle eder ve PID kontrolcü ile trafik akışını optimize eder.

## Proje Ekibi
- [Öğrenci Adı Soyadı] - [Öğrenci Numarası]
- [Danışman Hocanın Adı Soyadı] - [Bölüm/Üniversite]

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
├── src/
│   ├── control/         # PID kontrolcü ve ilgili fonksiyonlar
│   ├── traffic/         # Trafik simülasyonu fonksiyonları
│   └── metrics/         # Performans ölçüm fonksiyonları
├── test/               # Test dosyaları
├── utils/             # Yardımcı fonksiyonlar
└── docs/              # Proje dokümantasyonu
```

## Kurulum ve Çalıştırma
1. MATLAB R2024b veya üzeri sürümü yükleyin
2. Projeyi klonlayın:
   ```bash
   git clone [proje-url]
   ```
3. MATLAB'da proje klasörüne gidin
4. `main_simulation.m` dosyasını çalıştırın

## Özellikler
- Gerçek zamanlı trafik verisi entegrasyonu
- PID kontrolcü ile dinamik trafik ışığı yönetimi
- Görsel simülasyon arayüzü
- Performans metrikleri ve analiz araçları
- Çoklu senaryo desteği

## Simülasyon Parametreleri
- Simülasyon süresi: 1 saat
- Zaman adımı: 1 saniye
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

## Sonuçlar ve Analiz
Proje, aşağıdaki metrikleri ölçer ve analiz eder:
- Ortalama bekleme süreleri
- Kuyruk uzunlukları
- Trafik yoğunluğu dağılımı
- PID kontrolcü performansı

## Gelecek Geliştirmeler
1. Makine öğrenmesi entegrasyonu
2. Çoklu kavşak senaryoları
3. Gerçek zamanlı veri entegrasyonu
4. Web arayüzü geliştirme

## Kaynaklar
- [OpenStreetMap](https://www.openstreetmap.org)
- [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API)
- [PID Control Theory](https://en.wikipedia.org/wiki/PID_controller)
- [MATLAB Documentation](https://www.mathworks.com/help/matlab/)

## Lisans
Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## İletişim
- E-posta: [e-posta-adresi]
- GitHub: [github-profil-linki]

---
*Bu proje [Üniversite Adı] [Bölüm Adı] Bölümü Bitirme Projesi olarak hazırlanmıştır.*