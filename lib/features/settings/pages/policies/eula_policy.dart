import 'package:flutter/material.dart';

class EulaPage extends StatelessWidget {
  const EulaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları (EULA)'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
SON KULLANICI LİSANS SÖZLEŞMESİ (EULA)

1. ŞARTLARIN KABULÜ
Bu uygulamayı kullanarak, aşağıdaki koşulları ve hükümleri kabul etmiş sayılırsınız. Eğer bu koşulları kabul etmiyorsanız, uygulamayı kullanmamalısınız.

2. UYGUNSUZ İÇERİK VE KULLANICI DAVRANIŞI
Uygunsuz, saldırgan, ayrımcı, tehdit edici veya yasa dışı içerikler paylaşmak yasaktır. Bu tür içeriklerin tespit edilmesi veya bildirilmesi halinde, söz konusu içerik derhal kaldırılacak ve ilgili kullanıcının hesabı kapatılabilecektir.

3. İÇERİK RAPORLAMA
Kullanıcılar, uygulama içerisinde gördükleri uygunsuz içerikleri raporlayabilir. Raporlar tarafımızca incelenecek ve 24 saat içerisinde gerekli işlemler yapılacaktır.

4. KULLANICI ENGELLEME
Kullanıcılar, istemedikleri diğer kullanıcıları engelleme hakkına sahiptir. Engellediğiniz kullanıcıların içerikleri ve mesajları size görünmez.

5. SORUMLULUK
Kullanıcılar, paylaştıkları içeriklerden kendileri sorumludur. Uygulamamız, kullanıcıların paylaşımlarının doğruluğu ya da hukuka uygunluğu konusunda sorumlu değildir.

6. HESABIN FESHİ
Bu koşullara uymayan kullanıcıların hesaplarını sonlandırma hakkımız saklıdır.

7. KOŞULLARDA DEĞİŞİKLİK
Bu sözleşmeyi zaman zaman güncelleyebiliriz. Güncellenen koşullar uygulama içerisinde duyurulacaktır. Uygulamayı kullanmaya devam etmeniz, değişiklikleri kabul ettiğiniz anlamına gelir.

Devam ederek bu koşulları anladığınızı ve kabul ettiğinizi onaylamış olursunuz.
''',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
