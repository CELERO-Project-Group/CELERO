<?php $this->
load->view('template/header'); ?>
<div class="container">
    <div class="col-md-10 well">
        <h>
            <b>
                User Manual Download
            </b>
        </h>
        <br>
        <br> <!-- file name for the user manual is case sensitive on the server! -->
        <a href="<?php echo asset_url('28_8_20_Celero_User_Manual_prnt.pdf'); ?>">
            <div style="background-color:#2D8B42; color:white; text-align: center;">
                <?php echo lang("usermanual"); ?>
                <span class="glyphicon glyphicon-book">
                </span>
            </div>
        </a>
    </div>
    <br>
        <br>
            <br>
                <br>
                    <br>
                    <br>
                        <?php if($this->
                        session->userdata('site_lang') == "turkish"): ?>
                        <div class="col-md-10">
                        	<!-- Turkish FAQ -->
                            <div class="swissheader">
                                <?php echo lang("faq"); ?>
                            </div>
                            <div class="helpheader">
                                Bir akış nasıl eklenir?
                            </div>
                            <div class="helpbody">
                                Firma sayfası aracılığı ile erişilen veri yönetimi modülü üzerinde akış tabına basın ve "akış ekle" tuşu ile açılan formu doldurun. Formu onayladığınızda firmaya ait akış eklenecektir.
                            </div>
                            <div class="helpheader">
                                Bir bileşeni nasıl eklerim?
                            </div>
                            <div class="helpbody">
                                Firma sayfası aracılığı ile erişilen veri yönetimi modülü üzerinde bileşen tabına basın ve açılan formu doldurun. Formu onayladığınızda firmaya ait akışa bağlı bileşen eklenecektir.
                            </div>
                            <div class="helpheader">
                                Bir işlemi nasıl eklerim?
                            </div>
                            <div class="helpbody">
                                Firma sayfası aracılığı ile erişilen veri yönetimi modülü üzerinde işlem tabına basın ve açılan formu doldurun. Formu onayladığınızda firmaya ait akışa bağlı işlem eklenecektir.
                            </div>
                            <div class="helpheader">
                                Bir ekipmanı nasıl eklerim?
                            </div>
                            <div class="helpbody">
                                Firma sayfası aracılığı ile erişilen veri yönetimi modülü üzerinde ekipman tabına basın ve açılan formu doldurun. Formu onayladığınızda firmaya ait işleme bağlı ekipman eklenecektir.
                            </div>
                            <div class="helpheader">
                                Bir ürünü nasıl eklerim?
                            </div>
                            <div class="helpbody">
                                Firma sayfası aracılığı ile erişilen veri yönetimi modülü üzerinde ürün tabına basın ve açılan formu doldurun. Formu onayladığınızda firmaya ait ürün eklenecektir.
                            </div>
                            <div class="helpheader">
                                Firmaya ait Fayda-Maliyet Analizini nasıl yapabilirim?
                            </div>
                            <div class="helpbody">
                                Proje açtıkdan sonra Analizler sekmesinde bulunan Fayda-Maliyet Analizi tuşuna basılarak ilgili sayfaya erişilir.
KPI analizi sayfasında tanımlanan ve analiz için seçilen potansiyeller bu sayfada listelenecektir. 
Potansiyele ait ilgili değerleri tablo içerisine girip kaydet tuşuna bastığınızda sistem otomatik olarak grafik ve tablo analiz sonuçlarını oluşturacaktır.
                            </div>
                            <div class="helpheader">
                                Temiz Üretim potansiyellerini nasıl listelerim?
                            </div>
                            <div class="helpbody">
                                Proje açtıkdan sonra Analizler tabında Temiz Üretim tuşuna basın.
Firmalara ait paylaştırma bilgileri listelenecektir. 
Paylaştırmalar düzenlenebilir ve yeni paylaştırma "Paylaştırma Tanımla" tuşuna basılarak yeni paylaştırma tanımlanabilir.
                            </div>
                            <div class="helpheader">
                                Firmalara ait Eko-takip bilgilerini nasıl görebilirim?
                            </div>
                            <div class="helpbody">
                                Proje açtıkdan sonra o projeye dahil firmalara ait ekipmanlar üzerine kurulmuş eko-takip sistemi verilerine Analizler sekmesinde bulunan Firma Takibi tuşuna basarak erişebilirsiniz. Aynı zamanda firma verileri sayfasında ekipman sekmesine ekipman tablolalarında bulunan Tracking Data tuşuna basarak ekipmana ait eko-takip verilerine erişebilirsiniz.
                            </div>
                            <div class="helpheader">
                                Nasıl kayıt olurum ?
                            </div>
                            <div class="helpbody">
                                Anasayfada bulunan üye ol tuşuna basın, çıkan formu eksiksiz olarak doldurun. Captcha onayını doldurmayı unutmayın ve "Üye ol" tuşuna basın.
                            </div>
                            <div class="helpheader">
                                Sisteme nasıl girerim ?
                            </div>
                            <div class="helpbody">
                                Anasayfada bulunan giriş yap tuşuna basın ve kullanıcı adı şifrenizi girerek formu onaylayın
                            </div>
                            <div class="helpheader">
                                Danışman kaydımı nasıl yapabilirim?
                            </div>
                            <div class="helpbody">
                                Giriş yaptıkdan sonra erişilen kullanıcı sayfasında bulunan "Danışman ol" tuşuna basarak danışman olabilirsiniz.
                            </div>
                            <div class="helpheader">
                                Danışman listesini nasıl görebilirim ?
                            </div>
                            <div class="helpbody">
                                Profiller sekmesinden Danışmanlar sayfasına giderek sistemde bulunan tüm danışmanları listeleyebilirsiniz.
                            </div>
                            <div class="helpheader">
                                Nasıl firma eklerim?
                            </div>
                            <div class="helpbody">
                                Giriş yaptıkdan sonra Firmalar sekmesine tıklayın ve Firma oluştur tuşuna basın. Formu eksiksiz bir şekilde doldurun ve "firma oluştur" tuşuna basın
                            </div>
                            <div class="helpheader">
                                Firma verilerini nasıl eklerim ve düzenlerim?
                            </div>
                            <div class="helpbody">
                                Firmalar sekmesine tıklayın ve tüm firmalar sekmesine geçin. İzniniz olan firmaların isimleri yanında bulunan "firma verisini düzenle" tuşuna basın. Akış sekmesi altında "akış ekle" butonuna tıkladığınızda beliren formu doldurun ve "akış ekle" tuşuna basın. Aynı zamanda firma sayfasından da veri yönetimi sayfasına aynı şekilde erişebilirsiniz.
                            </div>
                            <div class="helpheader">
                                Nasıl proje oluştururum?
                            </div>
                            <div class="helpbody">
                                - Projeler sekmesinden Proje oluştur tuşuna basın
- Formu doldurun
- "Proje oluştur" tuşuna basın ve sistem yeni oluşturulan proje sayfasına sizi yönlendirecektir.
                            </div>
                            <div class="helpheader">
                                Nasıl proje açarım?
                            </div>
                            <div class="helpbody">
                                - Projeler sekmesinden Projelerim sayfasına gidin.
- Açmak istediğiniz proje ismi yanında bulunan "projeyi aç" tuşuna basın.
- Proje açıldıktan sonra projelerim sekmesinde görünecektir. Aynı zamanda proje sayfası açılacaktır.
                            </div>
                            <div class="helpheader">
                                Nasıl projeyi kapatırım?
                            </div>
                            <div class="helpbody">
                                - Projelerim sekmesine gidin ve "Projeyi kapat" tuşuna basın.
                            </div>
                            <div class="helpheader">
                                KPI bilgisini nasıl düzenler ve kaydederim
                            </div>
                            <div class="helpbody">
                                Proje açtıkdan sonra Analizler sekmesine girin ve "Temiz Üretim" tuşuna basın. Temiz üretim yönetim ekranında firma tablolarının içinde bulunan "KPI verilerini görüntüle" tuşuna basın ve KPI sayfasına erişin. Oluşturulan paylaştırma tablosunda Benchmark KPI bilgilerini girip Kaydet tuşuna bastığınızda sistem KPI karşılaştırmalarını otomatik olarak yapıp gerekli analiz grafik ve tablolalarını oluşturacaktır.
                            </div>
                            <div class="helpheader">
                                Firma ve detay bilgilerine harita üzerinde nasıl erişirim?
                            </div>
                            <div class="helpbody">
                                Kullanıcı sisteme giriş yaptıktan sonra , kullanıcı menüsü üzerindeki 'CBS' butonuna tıklar (Kullanıcı bir proje açmış olmak zorundadır)
                            </div>
                            <div class="helpheader">
                                Otomatik ve manuel IS potansiyeli biribirinden nasıl ayrılır?
                            </div>
                            <div class="helpbody">
                                Kullanıcı 'IS potansiyel Belirleme' butonuna bastığında aşağı kayan menü açılır.
 Kullanıcı 'Otomatik IS' linkine tıklayabilir. Otomatik seçim belirlemede sistem belirli akışlara göre sabit nalizler yapar ve kullanıcıya hazır seçenekler sunar.
 Manuel potansiyel belirleme işleminde ise sistem kendi eşleniklerinin yanında kullanıcıya potansiyel eşlenikleri belirlenme ve atama olanağı sağlar.
                            </div>
                            <div class="helpheader">
                                Otomatik IS potansiyeli belirleme aracı nasıl çalışır?
                            </div>
                            <div class="helpbody">
                                Adım 1 : Akışlar (Sol üst tablo) : Kullanıcı IS poansiyel seçimleri için akışları belirler (Birden çok akış seçilebilir)
 Adım 2 : Firma seçiniz ve potansiyel IS dökümünü yapınız (Sağ üst tablo) : Bu adımda kullanıcı firma ve akışlarını seçerek muhtemel IS akışları içinde hesaplanmasını sağlar
 2.1 Firma seçmek için kullanıcı tablodak şirket ismine tıklamak zorundadır. Seçilen satır 'sarı' arka plan rengine döner (*1 nolu şekil 'Otomatik IS seçim bölümü'). Birden çok seçenek mümkündür.
 Eğer kullanıcı tüm firmaları seçmek isterse , 'Tüm firmaları seç' butonuna basabilir (*2 şekil 'Otomatik IS seçim bölümü')
 Notes : * Akışlar 2. adımda seçilmeyecektir * Sadece açılan projelerdeki firmalar listelenecektir
 2.2 Kullanıcı hangi tip IS dökümünün yapılmasına karar vermek için açılır menüden 'IS senaryo tipi' seçer (*3 şekil 'Otomatik IS seçim bölümü'). Seçilen senaryoya göre IS potansiyeli bir sonraki
 adımda gösterilecektir
 • Akışları ikame etmek için (eğer senaryo 'girdi ve çıktı ikamesi' ise)
 • Akışları tedarik veya bertaraf edilmesi (eğer senaryo 'girdi ikamesi' veya 'çıktı ikamesi' ise)
 • Tüm potansiyeller (eğer senaryo 'Tüm seçenekler' ise)
 Son olarak kullanıcı 'IS potansiyeli hesapla' butonuna tıklayarak (*4 şekil 'Otomatik IS seçim bölümü') işlemi başlataır
 Sonuçlar 'adım 3' içinde görülen tablosunda görüntülenir
 Adım 3 : Is potansiyelleri arasında seçim yapılır (Sol alt tablo). Bu aşamada kullanıcı daha derinlemesine incelemek istediği seçenekleri seçer,
 3.1 Sonuçların analizi : Bu tablo tüm tanımlanmış IS potansiyellerini listeler. Her satır bir eşleşmeyi gösterir;
 • Belirli bir akış ve miktarı
 • Akışların kullanıldığı firmalar
 • Firmaların akışlarının yönleri, bu bilgiler akışların girdi eya çıktı olarak ve senaryo tiplerine göre ayrıştırılmasını sağlar
 3.2 Kullanıcı bir eşleşmeyi seçmek için ilgili satıra tıklar, seçilen satır arka plan rengi 'sarı' renge dönüşür (*5 şekil 'Otomatik IS seçim bölümü')
 3.3 Son olarak kullanıcı 'Is potansiyel ekle' butonuna tıklayarak (*6 şekil 'Otomatik IS seçim bölümü') 4.adımda belirlenen akış şamalarını potansiyel olarak belirler
 Adım 4 : Potansiyel IS eşleşmelerinin kaydı (Sağ alt tablo) Adım 1 ve Adım 3' e kadar olan adımlar tekrar edilerek farklı senaryo ve firmalara göre elşleşmeler görüntülenebilir.
 Kullanıcı belirlenen potansiyeli bir senaryo adı altında sisteme kaydedebilir (*7 şekil 'Otomatik IS seçim bölümü'). Açılır pencerede gerekli alanları dolduran kullanıcı daha sonraki
 incelemek üzere eşleşmeleri sisteme kaydeder.
                            </div>
                            <div class="helpheader">
                                Manual IS potansiyeli belirleme aracı nasıl çalışır?
                            </div>
                            <div class="helpbody">
                                Adım 1. : Kullanıcı firma belirler
1.1 Kullanıcı firm atablosundaki satırları seçerek seçimini yapar (bakınız *1 şekil 6 )
Notlar  • 1.Adımda belirli bir akış seçilmez
 • Sadece seçilmiş projelerdeki firmalar sistemde gözükür
1.2 Daha sonra kullanıcı 'Akış detaylarını getir' düğmesine tıklar (bakınız şekil *2 )
Adım 2 : Kullanıcı firma akışlarından seçer (sol alt panel)
2.1 Kullanıcı akış seçmek için akış isminin olduğu satırı seçer. Seçilen satır arka plan rengi 'sarı' olacaktır (bakınız *3 in şekil 6)
2.2 Daha sonra Kullanaıcı 'Belirlenmiş akış bilgisini getir' düğmesine tıklar (bakınız *4 şekil 6)
Adım 3 : Belirlenmiş Akış (Sağ alt tablo) Bu adımda kullanıcı daha önce adım 2'de seçilen ve bu adımda seçilen akış iki akış arasında bir ilişki oluşturur. Bu işleyişde
Kullanıcı manuel olarak eşleşme gerçekleştirebilmektedir.
 Adım 4 : Potansiyel IS eşleşmelerinin kaydı farklı senaryo ve firmalara göre elşleşmeler görüntülenebilir.
 Kullanıcı belirlenen potansiyeli bir senaryo adı altında sisteme kaydedebilir . Açılır pencerede gerekli alanları dolduran kullanıcı daha sonraki
 incelemek üzere eşleşmeleri sisteme kaydeder.
                            </div>
                            <div class="helpheader">
                                Bir firma için IS senaryoları nasıl listelenir?
                            </div>
                            <div class="helpbody">
                                Kullanıcı sisteme giriş yaptıktan sonra , kullanıcı menüsü üzerindeki 'Analiz' butonuna tıklar (Kullanıcı bir proje açmış olmak zorundadır) ve 'IS Senaryoları' menüsüne tıklar
                            </div>
                        </div>
                        <?php else: ?>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/TndTasntKjk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/0F7TKdyX_6I" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/EXQXdQ5Lb1A" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/XNK3CwElNQg" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/TT217255jlY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <br>
                        <br>
                        <br>
                        <!-- English FAQ -->
                        <div class="col-md-10">
                            <div class="swissheader">
                                <?php echo lang("faq"); ?>
                            </div>
                            <div class="helpheader">
                                What is difference between a user and a consultant? 
                            </div>
                            <div class="helpbody">
                                User are the most basic accounts, they can create companies and projects. Consultants are more advanced users which can view company profiles. If consultants are invited into a project they can do IS and CP analysis for this project.
                            </div>
                          
                            <div class="helpheader">
                                How to register as a consultant
                            </div>
                            <div class="helpbody">
                                First access to the profile page. If the user wants to change his status to “consultant” for an existing profile, he can access the profile page by logging in. Once the profile page displays, the user clicks on the “become a consultant” button, located in the left upper corner of the page.
                            </div>
                            <div class="helpheader">
                                How does the IS service find matching flows?
                            </div>
                            <div class="helpbody">
                                For now the IS service matches flows only by "flow name" and Input / Output flow type.
                            </div>
                           
                            <div class="helpheader">
                                What is the difference between a automated and a manual IS potential identification?
                            </div>
                            <div class="helpbody">
                                When the user clicks on the “IS-Potential Identification” button, a scroll down menu appears. The user can choose to: <br>
-  Operate a automatic IS detection (“Automated IS” button). When operating an Automated IS detection, CELERO automatically detects Potential IS by matching the flows that have the same name. The user then selects from the pool of Potential IS the ones that seem the most relevant.<br>
-   Operate a manual IS detection (“Manual IS” button). When operating a Manual IS detection, CELERO displays all available flows from the opened project and the user himself matches the flow that can be mutualized.
                            </div>
	                     </div>
                        <?php endif ?>
                    </br>
                </br>
            </br>
        </br>
    </br>
</div>
<?php $this->
load->view('template/footer'); ?>
