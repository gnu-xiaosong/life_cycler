import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';

class TaskTodosCard extends StatefulWidget {
  Map data;
  TaskTodosCard(this.data, {super.key});

  @override
  State<TaskTodosCard> createState() => _TaskTodosCardState(data);
}

class _TaskTodosCardState extends State<TaskTodosCard> {
  Map data;
  _TaskTodosCardState(this.data);

  @override
  Widget build(BuildContext context) {
    return cardTodos(data);
  }

  // 卡片形式
  Widget cardTodos(Map data) {
    return AppinioSwiper(
      cardBuilder: (BuildContext context, int index) {
        // 自定义卡片内容
        return Custom3DCard(
          elevation: 4,
          color: Colors.cyan,
          child: SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: Text(data["data"].toString()),
            ),
          ),
        );
      },
      cardCount: data["data"].length,
    );
  }
}
