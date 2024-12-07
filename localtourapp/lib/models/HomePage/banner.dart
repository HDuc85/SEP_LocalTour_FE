class BannerModel {
 final String bannerUrls;

 BannerModel({required this.bannerUrls});

 factory BannerModel.fromJson(String json) {
  return BannerModel(bannerUrls: json);
 }

 static List<BannerModel> fromJsonList(List<dynamic> jsonList) {
  return jsonList.map((url) => BannerModel.fromJson(url)).toList();
 }
}
