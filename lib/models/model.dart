
class BoardingModel {
  final String image;
  final String title;
  final String body;

  BoardingModel({required this.image, required this.title, required this.body});
}
List<BoardingModel> boarding = [
    BoardingModel(
      image: 'assets/3.png',
      title: 'اهلا ومرحبا بكم في تطبيق مهرة ',
      body: '',
    ),
    BoardingModel(
      image: 'assets/2.png',
      title: 'التطبيق الأول في اليمن ',
      body: 'الذي يوفر بيئة حاضنة لجميع أصحاب المشاريع الصغيرة',
    ),
    BoardingModel(
      image: 'assets/1.png',
      title: 'وصول سريع وسلس ',
      body: 'لكل ما تحتاجون اليه من منتجات منزلية واحتياجات أخرى في بيئة واحدة ',
    ),
    BoardingModel(
      image: 'assets/4.png',
      title: 'لنشر جميع ابداعاتكم للعالم ',
      body: 'بقالب تفاعلي ومتنوع من خلال الصور والفيديوهات والتواصل الفعال مع المستخدمين ',
    ),
  ];
