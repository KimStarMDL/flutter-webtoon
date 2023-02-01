class WebtoonModel {
  final String title, thumb, id;

  WebtoonModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['thumb'],
        id = json['id'];

  // late final String title, thumb, id;

  // WebtoonModel(Map<String, dynamic> json) {
  //   title = json['title'];
  //   thumb = json['thumb'];
  //   id = json['id'];
  // }
}
