# Dökümantasyon

## Hakkında

Mnhani iOS için bir askeri GPS uygulamasıdır.

<<<<<<< HEAD
### Kütüphaneler
=======
[![Version](https://img.shields.io/badge/Version-3.3.2-ff9500.svg)](https://swift.org/)
[![Build](https://img.shields.io/badge/Build-13-ff9500.svg)](https://swift.org/)
[![Language](https://img.shields.io/badge/Swift-4.1-ff9500.svg)](https://swift.org/)
[![Mapbox](https://img.shields.io/badge/Mapbox-4.1-4264fb.svg)](https://www.mapbox.com/)
[![Material](https://img.shields.io/badge/Material-55.5-ff9500.svg)](https://material.io/)
[![FormToolbar](https://img.shields.io/badge/FormToolbar-1.1-ff9500.svg)](https://github.com/sgr-ksmt/FormToolbar)
[![Website](https://img.shields.io/website-up-down-green-red/http/abuzeremre.com.svg)](http://abuzeremre.com/)
[![OpenSource](https://img.shields.io/badge/Open-Source-ff9500.svg)](https://swift.org/)
>>>>>>> parent of 39ec0b8... Pod updates

{% hint style="info" %}
* versiyon 3.4
* build 14
* swift 4.1
* mapbox 4.1.1
* material design 56
* formtoolbar 1.1
{% endhint %}

### Yapılacaklar Listesi

* [x] Sade ve Hızlı 
* [x]  Kolay koordinat paylaşma
* [x]  Türkçe
* [x] Topografik harita 
* [ ] Çevrimdışı harita 
* [ ] 3 Boyutlu harita 
* [ ] Grid çizgileri
* [x] Nokta ekleme
* [ ] Eklenen noktaları gruplama 
* [x] Çizgi ekleme 
* [ ] Alan ekleme 

## Uygulama Yapısı ve Kullanım Kılavuzu

### Harita

![](.gitbook/assets/img_7102.png)

Harita Mapbox servis sağlayıcısı tarafından sağlanan Open Cycle Map'tir.

1. Konumunuzu ve yönünüzü gösteren işaret.
2. Kaydettiğiniz noktalar. Bu noktaları seçtiğinizde noktanın adını ve koordinatlarını görebilirsiniz.
3. Kaydettiğiniz çizgiler.
4. Haritanın yönünü gösteren pusula.
5. Konumunuzu takip etmeye yarayan düğme.
6. Harita yakınlaştırma ve uzaklaştırma düğmeleri.
7. Haritanın merkezi ve sizin bu noktaya olan mesafeniz. Kayıtlı bir noktaya olan mesafenizi ölçmek için o noktayı seçerek haritanın merkezine gelmesini sağlayabilir ya da haritayı sürükleyerek merkeze getirebilirsiniz.
8. Harita merkezinin koordinatları.
9. Paylaşmak için harita merkezinin koordinatlarını kopyalar. Böylece istediğiniz platformda \(mesajlaşma, not alma vb.\) yapıştırarak kullanabilirsiniz.
10. Harita merkezine nokta veya çizgi ekleme düğmesi.
11. Harita görüntüsünü değiştiren düğmeler.

