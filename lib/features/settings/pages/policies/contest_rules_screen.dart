import 'package:flutter/material.dart';

class ContestRulesScreen extends StatelessWidget {
  const ContestRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yarışma Kuralları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '''
**Resmî Yarışma Kuralları**

1. **Katılım Şartları:**  
Bu yarışma, uygulamaya kayıtlı olan tüm kullanıcılara açıktır.

2. **Yarışma Süresi:**  
Yarışma, her hafta pazartesi günü başlar ve o haftanın pazar günü günü saat 23:59'da (UTC) sona erer.

3. **Nasıl Katılabilirsiniz:**  
Kullanıcılar, yarışma süresi boyunca uygulama üzerinden geçerli bir katılım formu doldurarak katılabilir. Her kullanıcı yalnızca bir kere katılabilir.

4. **Kazananın Belirlenmesi:**  
Kazananlar tüm geçerli katılımlar arasından jüri tarafından seçilecektir. Kazananlarla, uygulamaya kayıt olurken verdikleri e-posta adresi üzerinden iletişime geçilecektir.

5. **Ödüller:**  
Büyük ödülün kazananı 1000 Tl kazanacaktır. Uygulamada açıklandığı şekilde ek ödüller de verilebilir.

6. **Genel Koşullar:**  
Katılımcılar bu resmî kurallara ve yarışma düzenleyicisinin tüm nihai kararlarına uymayı kabul eder.

7. **Gizlilik:**  
Kişisel bilgileriniz yalnızca bu yarışmanın amaçları doğrultusunda kullanılacak ve üçüncü taraflarla paylaşılmayacaktır.

8. **Sorumluluk Sınırı:**  
Katılımcılar yarışmaya katılarak, yarışma düzenleyicisi ve iştiraklerinin bu yarışmadan kaynaklanan herhangi bir sorumluluktan muaf olduğunu kabul eder.

**Önemli:**  
Apple Inc. bu yarışmanın sponsoru değildir ve yarışmanın yönetiminden ya da yürütülmesinden sorumlu değildir.

---

Sorularınız veya destek talepleriniz için lütfen cinematetr@gmail.com adresine ulaşın.

Bol şans!
          ''',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
