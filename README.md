# KONTROL PROJE: Adaptif PID Kontrollü Trafik Işığı Simülasyonu

Bu proje, MATLAB ve Simulink kullanılarak geliştirilmiş bir adaptif trafik ışığı kontrol sistemi simülasyonudur. Sistem, trafik yoğunluğuna göre yeşil ışık sürelerini dinamik olarak ayarlamak için PID kontrolcülerini kullanır. Proje, hem bir Simulink modeli (`traffic_model.slx`) aracılığıyla temel bir tek yönlü kuyruk ve ışık sistemini hem de daha kapsamlı, dört yönlü bir kavşağı simüle eden bir MATLAB betiğini (`main_simulation.m`) içerir.

## Projenin Amacı

Bu projenin temel amacı, trafik akışını optimize etmek, bekleme sürelerini azaltmak ve kavşak verimliliğini artırmak için adaptif bir trafik ışığı kontrol stratejisi geliştirmek ve simüle etmektir.

## Bileşenler

Proje iki ana simülasyon yaklaşımı sunar:

1.  **`create_traffic_model.m` ile oluşturulan Simulink Modeli (`traffic_model.slx`):**
    *   Tek bir trafik yönü için araç gelişlerini, kuyruk oluşumunu ve temel bir trafik ışığı kontrolünü (Stateflow ile) simüle eder.
    *   Kuyruk uzunluğunu hedef bir değerde tutmak için bir PID kontrolcü içerir.
    *   Simülasyon sonuçlarını (kuyruk uzunluğu, bekleme süresi vb.) Simulink Scope blokları üzerinden görselleştirir.

2.  **`main_simulation.m` MATLAB Betiği:**
    *   Dört yönlü bir kavşak (Kuzey, Güney, Doğu, Batı) için daha ayrıntılı bir simülasyon yürütür.
    *   Her yönden gelen araçları, oluşan kuyrukları ve trafik ışığı döngülerini yönetir.
    *   Kuzey-Güney ve Doğu-Batı yönleri için ayrı PID kontrolcüleri kullanarak trafik yoğunluğuna göre yeşil ışık sürelerini adaptif olarak ayarlar.
    *   Simülasyon sırasında ve sonunda çeşitli performans metriklerini (ortalama bekleme süresi, maksimum kuyruk uzunluğu, geçen toplam araç sayısı) hesaplar ve gösterir.
    *   Simülasyonu ve metrikleri görselleştirmek için iki ayrı MATLAB figürü oluşturur.

## Kurulum ve Çalıştırma

### Gereksinimler

*   MATLAB
*   Simulink
*   Stateflow (Simulink modeli için)

### Çalıştırma Adımları

#### 1. Simulink Modeli (`traffic_model.slx`)

Bu model, tek bir yöndeki trafik ışığı ve kuyruk sistemini simüle eder.

1.  **Modeli Oluşturma:**
    MATLAB komut satırına aşağıdaki komutu yazın:
    ```matlab
    create_traffic_model
    ```
    Bu komut, proje dizininde `traffic_model.slx` adlı Simulink model dosyasını oluşturacaktır. Komut tamamlandığında konsolda "Simulink modeli başarıyla oluşturuldu!" mesajını göreceksiniz.

2.  **Modeli Açma (İsteğe Bağlı):**
    ```matlab
    open_system('traffic_model')
    ```

3.  **Simülasyonu Başlatma:**
    ```matlab
    sim('traffic_model')
    ```
    Bu komut simülasyonu başlatacaktır.

    **Beklenen Simulink Çıktıları:**
    Simülasyon çalışırken veya bittikten sonra `traffic_model/Visualization` alt sistemindeki Scope blokları açılacaktır. Bu grafiklerde şunları gözlemleyebilirsiniz:
    *   **Kuyruk Uzunluğu (Queue Length):** Zamanla değişen araç kuyruğunun uzunluğunu gösterir.
    *   **Bekleme Süresi (Wait Time):** Araçların kuyrukta geçirdiği tahmini ortalama bekleme süresini gösterir.
    *   **Trafik Işığı Sinyali:** Trafik ışığının (örneğin kırmızı/yeşil) durumunu gösteren bir sinyal.
    *   **PID Kontrol Sinyali:** PID kontrolcünün ürettiği ve muhtemelen ışık zamanlamasını etkileyen kontrol sinyalini gösterir.

    *Örnek Çıktı Görünümleri (Simulink Scope'ları):*
    *(Buraya Simulink Scope'larından alınmış örnek ekran görüntüleri veya çizimlerini ekleyebilirsiniz. Örneğin, kuyruk uzunluğunun zamanla nasıl değiştiğini gösteren bir grafik.)*
    *   **Kuyruk Uzunluğu Grafiği:** Genellikle zaman ekseninde dalgalanan bir çizgi olarak görülür; araç geldikçe artar, araçlar geçtikçe azalır.
    *   **Bekleme Süresi Grafiği:** Kuyruk uzunluğuyla orantılı olarak artıp azalır.

#### 2. Kapsamlı Kavşak Simülasyonu (`main_simulation.m`)

Bu betik, dört yönlü bir kavşağı daha detaylı simüle eder ve kendi görselleştirmelerini üretir.

1.  **Simülasyonu Başlatma:**
    MATLAB komut satırına aşağıdaki komutu yazın:
    ```matlab
    main_simulation
    ```
    Betik çalışmaya başladığında konsolda "Trafik Işığı Simülasyonu Başlatılıyor..." mesajını ve ardından simülasyon adımlarına dair bilgileri göreceksiniz.

    **Beklenen `main_simulation.m` Çıktıları:**
    Betik çalıştırıldığında iki ana pencere (figure) açılacaktır:

    *   **Pencere 1: "Trafik Işığı Kavşağı"**
        *   Bu pencerede, dört yönlü kavşağın anlık durumu şematik olarak gösterilir.
        *   Her yöndeki araç kuyrukları (muhtemelen basit şekillerle veya sayılarla) ve aktif olan trafik ışıkları (renklerle) görselleştirilir.
        *   Simülasyon ilerledikçe bu görsel dinamik olarak güncellenir.

        *Örnek Çıktı Görünümü (Kavşak Figürü):*
        *(Buraya `visualize_intersection` fonksiyonunun ürettiği kavşak görselinin bir örneğini ekleyebilirsiniz. Dört kolu olan bir kavşak, her kolda bekleyen araçları temsil eden noktalar/çubuklar ve ışıkların rengi.)*

    *   **Pencere 2: "Trafik Işığı Simülasyonu" (Metrik Grafikleri)**
        *   Bu pencerede, simülasyon boyunca toplanan önemli performans metriklerinin zaman içindeki değişimi grafiklerle gösterilir.
        *   **Kuyruk Uzunlukları:** Genellikle dört yön (Kuzey, Güney, Doğu, Batı) için ayrı çizgilerle zamanla değişen kuyruk uzunlukları.
        *   **Ortalama Bekleme Süreleri:** Dört yön için zamanla değişen ortalama bekleme süreleri.
        *   **Işık Süreleri:** NS (Kuzey-Güney) yeşil, EW (Doğu-Batı) yeşil ve sarı ışık sürelerinin zaman içindeki değişimi (PID kontrolcüsünün adaptif ayarlamalarını yansıtır).

        *Örnek Çıktı Görünümü (Metrik Grafikleri Figürü):*
        *(Buraya `plot_metrics` fonksiyonunun ürettiği grafiklerin bir örneğini ekleyebilirsiniz. Üç alt grafikten oluşan bir figür: biri kuyruk uzunlukları, biri bekleme süreleri, biri de ışık süreleri için.)*

    Simülasyon tamamlandığında, konsolda aşağıdaki gibi özet performans metrikleri de yazdırılacaktır:
    ```
    Performans Metrikleri:
    Toplam geçen araç: [sayı]
    Ortalama bekleme süreleri (K,G,D,B): [süre], [süre], [süre], [süre] saniye
    Maksimum kuyruk uzunlukları (K,G,D,B): [araç sayısı], [araç sayısı], [araç sayısı], [araç sayısı] araç
    ```
