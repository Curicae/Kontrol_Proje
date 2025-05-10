# KONTROL PROJE: Adaptif PID Kontrollü Trafik Işığı Simülasyonu

<!-- Opsiyonel: Projenizi temsil eden bir logo veya görseli buraya ekleyebilirsiniz -->
<!-- Örnek: <p align="center"><img src="images/project_logo.png" width="200"></p> -->

[![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange?style=for-the-badge&logo=mathworks)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-Required-blue?style=for-the-badge&logo=mathworks)](https://www.mathworks.com/products/simulink.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT) <!-- Lisansınızı buraya göre güncelleyin veya kaldırın -->

Bu proje, **[Ders Adınız/Bölüm Adınız]** final projesi kapsamında MATLAB ve Simulink kullanılarak geliştirilmiş bir adaptif trafik ışığı kontrol sistemi simülasyonudur. Sistem, trafik yoğunluğuna göre yeşil ışık sürelerini dinamik olarak ayarlayarak kavşaklardaki trafik akışını optimize etmeyi hedefler.

## ✨ Temel Özellikler

*   Trafik yoğunluğuna duyarlı adaptif PID kontrolü.
*   Tek yönlü ve dört yönlü kavşak simülasyonları.
*   MATLAB ve Simulink (Stateflow ile) kullanılarak modüler tasarım.
*   Detaylı performans metrikleri ve görselleştirmeler.
*   Hem Simulink modeli (`traffic_model.slx`) hem de kapsamlı MATLAB betiği (`main_simulation.m`) ile analiz imkanı.

## 🎯 Projenin Amacı

Bu projenin temel amacı, trafik akışını optimize etmek, bekleme sürelerini azaltmak ve kavşak verimliliğini artırmak için adaptif bir trafik ışığı kontrol stratejisi geliştirmek ve simülasyonunu yapmaktır. Bu çalışma, **[Üniversite Adınız, Bölüm Adınız]** bünyesindeki **[Ders Kodu ve Adı, örn: KTRL401 Kontrol Sistemleri Tasarımı]** dersinin final projesi olarak hazırlanmıştır.

## 🛠️ Bileşenler

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

## ⚙️ Kurulum ve Çalıştırma

### Gereksinimler

| Yazılım/Araç Kutusu | Sürüm/Not          |
| :------------------ | :----------------- |
| MATLAB              | R2021a veya üstü   |
| Simulink            | Gerekli            |
| Stateflow           | Simulink modeli için |

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
    *   Kuyruk Uzunluğu (Queue Length)
    *   Bekleme Süresi (Wait Time)
    *   Trafik Işığı Sinyali
    *   PID Kontrol Sinyali

    *Örnek Çıktı Görünümleri (Simulink Scope'ları):*
    <!-- Proje dizininizde bir "images" klasörü oluşturup ekran görüntülerini oraya kaydedin -->
    <!-- Örnek: -->
    <!-- ![Simulink Kuyruk Uzunluğu](images/simulink_kuyruk_uzunlugu.png) -->
    <!-- ![Simulink Bekleme Süresi](images/simulink_bekleme_suresi.png) -->
    <p align="center">
      <em>(Simulink Scope'larından alınmış örnek ekran görüntülerini buraya ekleyin. Örneğin, kuyruk uzunluğunun zamanla nasıl değiştiğini gösteren bir grafik.)</em>
    </p>

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
        *   Her yöndeki araç kuyrukları ve aktif olan trafik ışıkları görselleştirilir.
        *   Simülasyon ilerledikçe bu görsel dinamik olarak güncellenir.

        *Örnek Çıktı Görünümü (Kavşak Figürü):*
        <!-- Örnek: -->
        <!-- ![Kavşak Simülasyon Anı](images/kavsak_simulasyonu.gif) <!-- GIF kullanmak daha etkili olabilir --> -->
        <p align="center">
          <em>(`visualize_intersection` fonksiyonunun ürettiği kavşak görselinin bir örneğini/GIF'ini buraya ekleyin.)</em>
        </p>

    *   **Pencere 2: "Trafik Işığı Simülasyonu" (Metrik Grafikleri)**
        *   Bu pencerede, simülasyon boyunca toplanan önemli performans metriklerinin zaman içindeki değişimi grafiklerle gösterilir (Kuyruk Uzunlukları, Ortalama Bekleme Süreleri, Işık Süreleri).

        *Örnek Çıktı Görünümü (Metrik Grafikleri Figürü):*
        <!-- Örnek: -->
        <!-- ![Metrik Grafikleri](images/metrik_grafikleri.png) -->
        <p align="center">
          <em>(`plot_metrics` fonksiyonunun ürettiği grafiklerin bir örneğini buraya ekleyin.)</em>
        </p>

    Simülasyon tamamlandığında, konsolda aşağıdaki gibi özet performans metrikleri de yazdırılacaktır:
    ```
    Performans Metrikleri:
    Toplam geçen araç: [sayı]
    Ortalama bekleme süreleri (K,G,D,B): [süre], [süre], [süre], [süre] saniye
    Maksimum kuyruk uzunlukları (K,G,D,B): [araç sayısı], [araç sayısı], [araç sayısı], [araç sayısı] araç
    ```

## 🏗️ Proje Mimarisi (Opsiyonel ama Tavsiye Edilir)

<!-- Bu bölüme, sistemin genel mimarisini veya `main_simulation.m` ile `traffic_model.slx` arasındaki ilişkiyi gösteren basit bir akış şeması veya açıklama ekleyebilirsiniz. Bu, projenizin anlaşılırlığını artıracaktır. -->
<!-- Örnek: images/mimari.png -->

## 🗣️ Geri Bildirim ve Öneriler

Bu kişisel bir final projesi olsa da, proje hakkındaki geri bildirimleriniz ve önerileriniz benim için değerlidir. Lütfen düşüncelerinizi "Issues" bölümünden veya [E-posta Adresiniz (opsiyonel)] üzerinden paylaşmaktan çekinmeyin.

## 📜 Lisans

Bu proje [Lisans Adı, örn: MIT Lisansı] altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.
<!-- Proje kök dizinine bir LISANS dosyası (örneğin LICENSE.txt veya LICENSE.md) eklemeyi unutmayın. Eğer bir lisans kullanmıyorsanız bu bölümü ve rozeti kaldırabilirsiniz. -->

## 🙏 Teşekkür

Bu projenin geliştirilmesi sürecindeki değerli yönlendirmeleri ve destekleri için başta danışman hocam **[Danışman Hocanızın Adı Soyadı, Ünvanı]** olmak üzere, **[Üniversite Adınız, Bölüm Adınız]**'e ve **[Dersin Adı]** dersini veren tüm hocalarıma teşekkür ederim.

---
**Geliştirici:** [Adınız Soyadınız] - [Öğrenci Numaranız (opsiyonel)]
[GitHub Profil Linkiniz (opsiyonel)]
[LinkedIn Profil Linkiniz (opsiyonel)]
