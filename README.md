# Retail Sales Analysis (SQL + Power BI)

## Proje Özeti

Bu projede, perakende satış verileri kullanılarak uçtan uca bir satış analizi gerçekleştirilmiştir.  
Veri hazırlama ve raporlama süreçleri SQL ile yürütülmüş, elde edilen veriler Power BI kullanılarak yönetim seviyesinde dashboard’lara dönüştürülmüştür.  
Amaç; satış performansını üst seviyede izlemek, trendleri analiz etmek ve karar destek süreçlerine katkı sağlayacak bir raporlama yapısı oluşturmaktır.

---

## Cevaplanan İş Soruları

Bu proje kapsamında aşağıdaki iş sorularına yanıt aranmıştır:

- Satışlar zaman içerisinde nasıl değişiyor? (trend analizi)
- Aylık satış performansında artış ve düşüşler nasıl gerçekleşiyor? (MoM değişim)
- En yüksek satış hangi ayda gerçekleşmiştir?
- Satış performansı bölgelere göre nasıl dağılıyor?
- Hangi ürün kategorileri daha yüksek gelir sağlıyor?
- Müşteri segmentlerine göre satış dağılımı nasıldır?
- Kısa vadeli satış değişimleri ile uzun vadeli trend arasında nasıl bir ilişki vardır?

---

## Proje Süreci

1. Ham satış verisi SQL ile temizlenmiş ve standart hale getirilmiştir  
2. Aylık satışlar ve KPI odaklı raporlama view’leri oluşturulmuştur  
3. Bu view’ler Power BI’a aktarılmış ve iki ayrı dashboard oluşturulmuştur

---

## Power BI Dashboard’ları

### 1️) Sales Performance Overview
Bu dashboard, satışların zaman içerisindeki genel performansını ve temel KPI’ları göstermektedir.

**Öne Çıkan Bulgular:**
- Satışlar aylara göre dalgalı bir yapı göstermektedir (sezonsallık / kampanya etkisi)
- Son ayda satışlarda ciddi bir düşüş gözlemlenmiştir (MoM: -35.27%)
- Buna rağmen uzun vadede genel trend artış yönündedir
- Yılın son çeyreğinde (Q4) satışların zirve yaptığı görülmektedir
- Aylık değişimlerin yüksek olması, kısa vadeli takibin önemini göstermektedir

**Dashboard İçeriği:**
- Aylık satış trendi
- Aydan aya değişim (MoM)
- Son ay satış KPI kartı
- MoM değişim yüzdesi

---

### 2️) Sales Breakdown Overview
Bu dashboard, en yüksek performans gösteren ayın detaylı dağılımını analiz etmektedir.

**Öne Çıkan Bulgular**
- En yüksek satış hacmi Kasım ayında (~88K) gerçekleşmiştir
- East bölgesi, toplam satışların en büyük payını oluşturmaktadır
- Technology kategorisi en yüksek performansı göstermektedir
- Consumer segmenti, toplam satışların yarısından fazlasını oluşturmaktadır

**Dashboard İçeriği:**
- Bölgeye göre satış dağılımı
- Kategoriye göre satış dağılımı
- Segmente göre satış dağılımı

> Tüm görseller, en yüksek satış yapılan ayın verilerini göstermektedir.

---

## Veri Kaynağı
- Veri Seti: Retail Sales Dataset (2015–2018)
- Kaynak: Kaggle
- Veri seti projeye dahil edilmiştir ve SQL analiz sürecinde kullanılmıştır

---

## Proje Yapısı

<pre>
retail-sales-analysis-sql-powerbi/
│
├── data/
│ └── superstore_fixed.csv
│
├── powerbi/
│ ├── sales_breakdown_overview.png
│ └── sales_performance_overview.png
│
├── sql/
│ └── general_sales_views.sql
│
└── README.md
</pre>
