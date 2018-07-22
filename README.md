
# mnhani

iOS için Askeri GPS Uygulaması - *Military GPS Application for iOS*

[![Version](https://img.shields.io/badge/Version-4.0-ff9500.svg)](https://swift.org/)
[![Build](https://img.shields.io/badge/Build-14-ff9500.svg)](https://swift.org/)
[![Language](https://img.shields.io/badge/Swift-4.1-ff9500.svg)](https://swift.org/)
[![Mapbox](https://img.shields.io/badge/Mapbox-4.1.1-4264fb.svg)](https://www.mapbox.com/)
[![Material](https://img.shields.io/badge/Material-56.0.0-ff9500.svg)](https://material.io/)
[![FormToolbar](https://img.shields.io/badge/FormToolbar-1.1-ff9500.svg)](https://github.com/sgr-ksmt/FormToolbar)
[![Website](https://img.shields.io/website-up-down-green-red/http/abuzeremre.com.svg)](http://abuzeremre.com/)
[![OpenSource](https://img.shields.io/badge/Open-Source-ff9500.svg)](https://swift.org/)

## 1. Amaç

Kendimi GitHub ve Swift dilinde geliştirmek, uygulamayı da daha iyi bir hale getirmek için açık kaynak yaptım. Yapacağınız her türlü yardım sadece uygulamayı geliştirmeyecek, aynı zamanda yazdığınız kodları inceleyen beni de daha iyi bir seviyeye getirecektir.

*I made the application open source in order to develop and better implement GitHub and Swift language myself. Any help you will make will not only improve the application, but it will also bring me to a better level, who will be examining the codes you write at the same time. That's why I have no commercial concerns.*

Görseller için [linke](http://abuzeremre.com/mnhani-app) tıklayınız. - *See the [link](http://abuzeremre.com/mnhani-app) for screenshots.*

## 2. Özellikler - *Features*

### 2.1 Genel - *General*

- [x] Sade ve Hızlı - *Simple and Fast*
- [x] Kolay koordinat paylaşma - *Easy coordinat sharing*
- [x] Türkçe - *Turkish*

### 2.2 Harita Özellikleri - *Map Features*

- [x] Topografik harita - *Topographic Map*
- [ ] Çevrimdışı harita - *Offline Map*
- [ ] 3 Boyutlu harita - *3D Map*
- [ ] Grid çizgileri - *Grid Lines*

### 2.3 İşaretleme Özellikleri - *Mark-Up Features*

- [x] Nokta ekleme - *Add Custom Annotations*
- [ ] Eklenen noktaları gruplama - *Grouped Annotations*
- [x] Çizgi ekleme - *Add Lines*
- [ ] Alan ekleme - *Add Area*

### 2.4 Diğer

- [x] Kullanıcı Kılavuzu - *User Guide* :point_right: [wiki](https://github.com/aeosmanoglu/mnhani/wiki)

## 3. Uygulamanın Yapısı - *The Structure of the Application*

### 3.1 Current View Controller

Kullanıcının bulunduğu yüksekliği ve MGRS koordinatını gösterir. Kopyalama tuşu ile koordinat panoya kopyalanır. Ekle tuşu ile konum CoreData içine kaydedilir.

*Indicates the height of the user and the MGRS coordinate. The copy button copies the coordinate to the clipboard. The location is saved in CoreData with the Add key.*

### 3.2 Map View Controller

Kullanıcının konumunu ve baktığı yönü topografik ve uydu+sokak haritasında gösterir. Harita merkezinin koordinatını ve kullanıcıya olan uzaklığını verir. Kopyalama tuşu ile merkez koordinat panoya kopyalanır. Ekle tuşu ile konum CoreData içine kaydedilir. CoreData içindeki bütün konumlar harita üzerinde gösterilir.

*The user's position and direction is shown in topographic and satellite + street map. It gives the coordinates of the map center and its distance to the user. The center coordinate is copied to the dashboard with the copy key. The location is saved in CoreData with the Add key. All locations in CoreData are shown on the map.*

### 3.3 Points Table View Controller

Tüm kayıtlı noktaları listeler. Noktalar arasında arama yapılabilir. Noktalar silinip düzeltilebilir. Ekle tuşu ile yeni nokta eklenir.

*Lists all saved points. Points can be searchable and manageable.The new point is added with the Add key.*

## 4. Lines Table View Controller

Tüm kayıtlı çizgileri ve uzunluklarını listeler. Çizgiler arasında arama yapılabilir. Çizgiler silinebilinir.

*Lists all saved lines and lengths. Lines can be searchable and manageable.*

###### .gitignore

İçinde MapBox API anahtarım bulunduğu için Info.plist dosyasını kaldırdım. - *I ignored the Info.plist file because it contains my MapBox API Key*

> Anlayışınız ve yardımlarınız için teşekkür ederim.
> Thank you for your helps and understood.
