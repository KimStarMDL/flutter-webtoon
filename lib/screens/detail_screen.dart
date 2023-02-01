import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weptoon/models/webtoon_detail_model.dart';
import 'package:weptoon/models/webtton_episode_model.dart';
import 'package:weptoon/services/api_service.dart';
import 'package:weptoon/widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async {
    /* 핸드폰 저장소에 액세스 얻음 */
    prefs = await SharedPreferences.getInstance();
    /* liketoons라는 이름의 String List 탐색(List를 받아서 해당 List가 webtoon의 ID를 가지고 있는지 체크) */
    final likedToons = prefs.getStringList('likedToons');
    /* likedToons가 null이 아니면 */
    if (likedToons != null) {
      /* 사용자가 보고 있는 webtoon이 참(들어있다면)이면 좋아요를 누른 적이 있다(웹툰 ID를 가지고 있는지 확인) */
      if (likedToons.contains(widget.id) == true) {
        /* isLiked에 true값 적용하고 setState를 통해서 저장 */
        setState(() {
          isLiked = true;
        });
      }
/* likedToons가 null이면 */
    } else {
      await prefs.setStringList('likedToons', []);
    }
  }

  /* 1.사용자가 버튼을 클릭하면 List를 가져옴 */
  /* 2.만약 사용자가 이미 webtoon에 좋아요를 눌렀다면 해당 webtoon을 List에서 취소(제거) */
  /* 3.만약 사용자가 전에 좋아요를 누른 적이 없다면 해당 webtoon ID를 List에 추가 */
  onHeartTap() async {
    /* liketoons라는 이름의 String List 탐색 */
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      /* isLiked에 정보가 담겨져있고 참이라면 */
      if (isLiked) {
        likedToons.remove(widget.id);
        /* isLiked에 정보가 없다면 */
      } else {
        likedToons.add(widget.id);
      }
      /* 사용자가 제거 또는 추가를 하면 핸드폰 저장소에 다시 List 저장 */
      await prefs.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline,
            ),
          )
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 250,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            offset: const Offset(10, 10),
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      child: Image.network(widget.thumb),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //데이터가 있다면
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          '${snapshot.data!.genre} / ${snapshot.data!.age}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ); //about 데이터를 text로 반환한다.
                  }
                  return const Text("..."); //아니라면 text ...을 반환한다.
                },
              ),
              const SizedBox(
                height: 25,
              ),
              FutureBuilder(
                /* listView(많을 때 / 길이, 가늠이 안될 때) 또는 Column(적을 때) 사용 결정할 것 */
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    /* data가 있으면 */
                    return Column(
                      children: [
                        for (var episode in snapshot.data!)
                          Episode(
                            episode: episode,
                            webtoonId: widget.id,
                          ),
                      ],
                    );
                  }
                  return Container(); /* data가 없으면 Container 반환 */
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
