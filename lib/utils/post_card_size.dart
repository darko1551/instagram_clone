class PostCardSize {
  static final PostCardSize _singleton = PostCardSize._internal();

  factory PostCardSize() {
    return _singleton;
  }

  PostCardSize._internal();

  List<double> heightList = [];

  double getSum(int index) {
    //heightList = heightList.reversed.toList();
    double sum = 0;
    for (int i = 0; i < index; i++) {
      sum += heightList[i];
    }
    heightList.clear();
    return sum;
  }
}
