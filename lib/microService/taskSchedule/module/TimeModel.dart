import 'package:app_template/microService/taskSchedule/module/Model.dart';
import 'package:easy_localization/easy_localization.dart';

class TimeModel extends Model {
  /*
  今日是否在给定完整日期范围判定
   */
  bool nowDateIndateDuration(DateTime startDate, DateTime endDate) {
    // 统一转化为毫秒
    int startDateMs = startDate.microsecondsSinceEpoch;
    int enddateMs = endDate.microsecondsSinceEpoch;
    int nowMs = DateTime.now().microsecondsSinceEpoch;

    if (startDateMs <= nowMs && enddateMs >= nowMs) return true;
    return false;
  }

  /*
  今日是否在给定完整日期范围的判定：前中后
   */
  Map? nowDateIndateDurationPeriod(DateTime startDate, DateTime endDate) {
    // 统一转化为毫秒
    int startDateMs = startDate.millisecondsSinceEpoch;
    int enddateMs = endDate.millisecondsSinceEpoch;
    int nowMs = DateTime.now().millisecondsSinceEpoch;

    Range? rang;
    if (startDateMs <= nowMs && enddateMs >= nowMs) {
      // 中
      rang = Range.HANDLING;
    } else if (startDateMs > nowMs) {
      // 前
      rang = Range.FORWARD;
    } else if (enddateMs < nowMs) {
      // 后
      rang = Range.BACKWARD;
    }

    // 距离开始的秒数
    int relativeStartSecond = (nowMs - startDateMs).abs() ~/ 1000;
    // 距离结束的秒数
    int relativeEndSecond = (nowMs - enddateMs).abs() ~/ 1000;
    // 封装数据
    Map re = {
      "type": rang,
      "relativeStartSecond": relativeStartSecond,
      "relativeEndSecond": relativeEndSecond
    };
    return re;
  }

  /*
  根据给定的秒数字符化时间
   */
  String secondFormateTime(int second) {
    // 取出小时整数
    int hours = second ~/ (60 * 60);
    // 取出余下分钟数
    int minutes = (second - hours * (60 * 60)) ~/ 60;
    // 取出秒数
    int seconds = second % 60;

    String re = "${hours}" +
        "h".tr() +
        ":" +
        "${minutes}" +
        "m".tr() +
        ":" "${seconds}" +
        "s".tr();

    return re;
  }
}
