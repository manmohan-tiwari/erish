class MoodEdit {
  final String title;
  final String subtitle;
  final String image;

  const MoodEdit({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  static const List<MoodEdit> moods = [
    MoodEdit(
      title: 'The Getaway Edit',
      subtitle:
          'When you need sunshine, colour and a flight out of the ordinary.',
      image: 'assets/images/mood1.jpg',
    ),
    MoodEdit(
      title: 'The Statement Edit',
      subtitle: 'Bold prints. Unapologetic colour. You, but louder.',
      image: 'assets/images/mood2.jpg',
    ),
    MoodEdit(
      title: 'The Everyday Escape',
      subtitle:
          'Effortless silhouettes for mornings, markets and everything in between.',
      image: 'assets/images/mood3.jpg',
    ),
  ];
}
