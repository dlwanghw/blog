
enum Season {
  spring,
  summer,
  autumn,
  winter
}

class DemoEnum {
  DemoEnum(){
    print('  enum season initialized in contruction the default index is ${season.index}');
    print('  enum season initialized in contruction the default name is ${season.name}');
    print('  enum equal usage: the season is equal with season.summer ${season == Season.summer}');

  }
  Season season = Season.spring;

}