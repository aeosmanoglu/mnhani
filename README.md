# mnhani
iOS için Askeri GPS Uygulaması - *Military GPS Application for iOS*

[![Version](https://img.shields.io/badge/Version-1.0-ff9500.svg)](https://swift.org/)
[![Build](https://img.shields.io/badge/Build-1-ff9500.svg)](https://swift.org/)
[![Language](https://img.shields.io/badge/Swift-4.1-ff9500.svg)](https://swift.org/)
[![Website](https://img.shields.io/website-up-down-green-red/http/abuzeremre.com.svg)](http://abuzeremre.com/)
[![OpenSource](https://img.shields.io/badge/Open-Source-ff9500.svg)](https://swift.org/)

<br>

## 1. Amaç
Kendimi GitHub ve Swift dilinde geliştirmek, uygulamayı da daha iyi bir hale getirmek için açık kaynak yaptım. Yapacağınız her türlü yardım sadece uygulamayı geliştirmeyecek, aynı zamanda yazdığınız kodları inceleyen beni de daha iyi bir seviyeye getirecektir. Bu yüzden hiç bir ticari kaygım yok. 

<br>

Görseller için [linke](http://abuzeremre.com/mnhani-app) tıklayınız.

<br>

## 2. Özellikler
### 2.1 Genel
- [x] Sade ve Hızlı - *Simple and Fast*
- [x] Kolay koordinat paylaşma
- [ ] Türkçe
### 2.2 Harita Özellikleri
- [x] Topografik harita
- [ ] Çevrimdışı harita
- [ ] 3 Boyutlu harita
- [ ] Grid çizgileri
### 2.3 İşaretleme Özellikleri
- [x] Nokta ekleme
- [ ] Eklenen noktaları gruplama
- [ ] Çizgi ekleme
- [ ] Alan ekleme
### 2.4 Diğer
- [ ] İngilizce Readme

<br>

## 3. Uygulamanın Yapısı
### 3.1 Current View Controller
Kullanıcının bulunduğu yüksekliği ve MGRS koordinatını gösterir. Kopyalama tuşu ile koordinat panoya kopyalanır. Ekle tuşu ile konum CoreData içine kaydedilir.

### 3.2 Map View Controller
Kullanıcının konumunu ve baktığı yönü topografik ve uydu+sokak haritasında gösterir. Harita merkezinin koordinatını ve kullanıcıya olan uzaklığını verir. Kopyalama tuşu ile merkez koordinat panoya kopyalanır. Ekle tuşu ile konum CoreData içine kaydedilir. CoreData içindeki bütün konumlar harita üzerinde gösterilir.

### 3.3 Points Table View Controller
Tüm kayıtlı noktaları listeler. Noktalar arasında arama yapılabilir.

<br>

## 4. Kaputun Altında
### 4.1 Core Data Management Swift File
CoreData içine nokta ekleme, çağırma ve silme fonksiyonlarını bulunduran dosya

### 4.2 Convert Swift File
Coğrafi (latitude & longitude) koordinatı MGRS koordinatlarına çeviren dosya

<br>

###### .gitignore
İçinde MapBox API anahtarım bulunduğu için Info.plist dosyasını kaldırdım.

> Anlayışınız ve yardımlarınız için teşekkür ederim.


