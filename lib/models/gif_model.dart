// To parse this JSON data, do
//
//     final gifModel = gifModelFromJson(jsonString);

import 'dart:convert';

GifModel gifModelFromJson(String str) => GifModel.fromJson(json.decode(str));

String gifModelToJson(GifModel data) => json.encode(data.toJson());

class GifModel {
  List<Datum> data;
  Pagination pagination;
  Meta meta;

  GifModel({
    this.data,
    this.pagination,
    this.meta,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) => GifModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
        "meta": meta.toJson(),
      };
}

class Datum {
  Type type;
  String id;
  String url;
  String slug;
  String bitlyGifUrl;
  String bitlyUrl;
  String embedUrl;
  String username;
  String source;
  String title;
  Rating rating;
  String contentUrl;
  String sourceTld;
  String sourcePostUrl;
  int isSticker;
  DateTime importDatetime;
  DateTime trendingDatetime;
  Images images;
  String analyticsResponsePayload;
  Analytics analytics;
  User user;

  Datum({
    this.type,
    this.id,
    this.url,
    this.slug,
    this.bitlyGifUrl,
    this.bitlyUrl,
    this.embedUrl,
    this.username,
    this.source,
    this.title,
    this.rating,
    this.contentUrl,
    this.sourceTld,
    this.sourcePostUrl,
    this.isSticker,
    this.importDatetime,
    this.trendingDatetime,
    this.images,
    this.analyticsResponsePayload,
    this.analytics,
    this.user,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        type: typeValues.map[json["type"]],
        id: json["id"],
        url: json["url"],
        slug: json["slug"],
        bitlyGifUrl: json["bitly_gif_url"],
        bitlyUrl: json["bitly_url"],
        embedUrl: json["embed_url"],
        username: json["username"],
        source: json["source"],
        title: json["title"],
        rating: ratingValues.map[json["rating"]],
        contentUrl: json["content_url"],
        sourceTld: json["source_tld"],
        sourcePostUrl: json["source_post_url"],
        isSticker: json["is_sticker"],
        importDatetime: DateTime.parse(json["import_datetime"]),
        trendingDatetime: DateTime.parse(json["trending_datetime"]),
        images: Images.fromJson(json["images"]),
        analyticsResponsePayload: json["analytics_response_payload"],
        analytics: Analytics.fromJson(json["analytics"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "type": typeValues.reverse[type],
        "id": id,
        "url": url,
        "slug": slug,
        "bitly_gif_url": bitlyGifUrl,
        "bitly_url": bitlyUrl,
        "embed_url": embedUrl,
        "username": username,
        "source": source,
        "title": title,
        "rating": ratingValues.reverse[rating],
        "content_url": contentUrl,
        "source_tld": sourceTld,
        "source_post_url": sourcePostUrl,
        "is_sticker": isSticker,
        "import_datetime": importDatetime.toIso8601String(),
        "trending_datetime": trendingDatetime.toIso8601String(),
        "images": images.toJson(),
        "analytics_response_payload": analyticsResponsePayload,
        "analytics": analytics.toJson(),
        "user": user == null ? null : user.toJson(),
      };
}

class Analytics {
  Onclick onload;
  Onclick onclick;
  Onclick onsent;

  Analytics({
    this.onload,
    this.onclick,
    this.onsent,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => Analytics(
        onload: Onclick.fromJson(json["onload"]),
        onclick: Onclick.fromJson(json["onclick"]),
        onsent: Onclick.fromJson(json["onsent"]),
      );

  Map<String, dynamic> toJson() => {
        "onload": onload.toJson(),
        "onclick": onclick.toJson(),
        "onsent": onsent.toJson(),
      };
}

class Onclick {
  String url;

  Onclick({
    this.url,
  });

  factory Onclick.fromJson(Map<String, dynamic> json) => Onclick(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}

class Images {
  The480WStill downsizedLarge;
  The480WStill fixedHeightSmallStill;
  FixedHeight original;
  FixedHeight fixedHeightDownsampled;
  The480WStill downsizedStill;
  The480WStill fixedHeightStill;
  The480WStill downsizedMedium;
  The480WStill downsized;
  The480WStill previewWebp;
  DownsizedSmall originalMp4;
  FixedHeight fixedHeightSmall;
  FixedHeight fixedHeight;
  DownsizedSmall downsizedSmall;
  DownsizedSmall preview;
  FixedHeight fixedWidthDownsampled;
  The480WStill fixedWidthSmallStill;
  FixedHeight fixedWidthSmall;
  The480WStill originalStill;
  The480WStill fixedWidthStill;
  Looping looping;
  FixedHeight fixedWidth;
  The480WStill previewGif;
  The480WStill the480WStill;
  DownsizedSmall hd;

  Images({
    this.downsizedLarge,
    this.fixedHeightSmallStill,
    this.original,
    this.fixedHeightDownsampled,
    this.downsizedStill,
    this.fixedHeightStill,
    this.downsizedMedium,
    this.downsized,
    this.previewWebp,
    this.originalMp4,
    this.fixedHeightSmall,
    this.fixedHeight,
    this.downsizedSmall,
    this.preview,
    this.fixedWidthDownsampled,
    this.fixedWidthSmallStill,
    this.fixedWidthSmall,
    this.originalStill,
    this.fixedWidthStill,
    this.looping,
    this.fixedWidth,
    this.previewGif,
    this.the480WStill,
    this.hd,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        downsizedLarge: The480WStill.fromJson(json["downsized_large"]),
        fixedHeightSmallStill:
            The480WStill.fromJson(json["fixed_height_small_still"]),
        original: FixedHeight.fromJson(json["original"]),
        fixedHeightDownsampled:
            FixedHeight.fromJson(json["fixed_height_downsampled"]),
        downsizedStill: The480WStill.fromJson(json["downsized_still"]),
        fixedHeightStill: The480WStill.fromJson(json["fixed_height_still"]),
        downsizedMedium: The480WStill.fromJson(json["downsized_medium"]),
        downsized: The480WStill.fromJson(json["downsized"]),
        previewWebp: The480WStill.fromJson(json["preview_webp"]),
        originalMp4: DownsizedSmall.fromJson(json["original_mp4"]),
        fixedHeightSmall: FixedHeight.fromJson(json["fixed_height_small"]),
        fixedHeight: FixedHeight.fromJson(json["fixed_height"]),
        downsizedSmall: DownsizedSmall.fromJson(json["downsized_small"]),
        preview: DownsizedSmall.fromJson(json["preview"]),
        fixedWidthDownsampled:
            FixedHeight.fromJson(json["fixed_width_downsampled"]),
        fixedWidthSmallStill:
            The480WStill.fromJson(json["fixed_width_small_still"]),
        fixedWidthSmall: FixedHeight.fromJson(json["fixed_width_small"]),
        originalStill: The480WStill.fromJson(json["original_still"]),
        fixedWidthStill: The480WStill.fromJson(json["fixed_width_still"]),
        looping: Looping.fromJson(json["looping"]),
        fixedWidth: FixedHeight.fromJson(json["fixed_width"]),
        previewGif: The480WStill.fromJson(json["preview_gif"]),
        the480WStill: The480WStill.fromJson(json["480w_still"]),
        hd: json["hd"] == null ? null : DownsizedSmall.fromJson(json["hd"]),
      );

  Map<String, dynamic> toJson() => {
        "downsized_large": downsizedLarge.toJson(),
        "fixed_height_small_still": fixedHeightSmallStill.toJson(),
        "original": original.toJson(),
        "fixed_height_downsampled": fixedHeightDownsampled.toJson(),
        "downsized_still": downsizedStill.toJson(),
        "fixed_height_still": fixedHeightStill.toJson(),
        "downsized_medium": downsizedMedium.toJson(),
        "downsized": downsized.toJson(),
        "preview_webp": previewWebp.toJson(),
        "original_mp4": originalMp4.toJson(),
        "fixed_height_small": fixedHeightSmall.toJson(),
        "fixed_height": fixedHeight.toJson(),
        "downsized_small": downsizedSmall.toJson(),
        "preview": preview.toJson(),
        "fixed_width_downsampled": fixedWidthDownsampled.toJson(),
        "fixed_width_small_still": fixedWidthSmallStill.toJson(),
        "fixed_width_small": fixedWidthSmall.toJson(),
        "original_still": originalStill.toJson(),
        "fixed_width_still": fixedWidthStill.toJson(),
        "looping": looping.toJson(),
        "fixed_width": fixedWidth.toJson(),
        "preview_gif": previewGif.toJson(),
        "480w_still": the480WStill.toJson(),
        "hd": hd == null ? null : hd.toJson(),
      };
}

class The480WStill {
  String url;
  String width;
  String height;
  String size;

  The480WStill({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  factory The480WStill.fromJson(Map<String, dynamic> json) => The480WStill(
        url: json["url"],
        width: json["width"],
        height: json["height"],
        size: json["size"] == null ? null : json["size"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
        "size": size == null ? null : size,
      };
}

class DownsizedSmall {
  String height;
  String mp4;
  String mp4Size;
  String width;

  DownsizedSmall({
    this.height,
    this.mp4,
    this.mp4Size,
    this.width,
  });

  factory DownsizedSmall.fromJson(Map<String, dynamic> json) => DownsizedSmall(
        height: json["height"],
        mp4: json["mp4"],
        mp4Size: json["mp4_size"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "mp4": mp4,
        "mp4_size": mp4Size,
        "width": width,
      };
}

class FixedHeight {
  String height;
  String mp4;
  String mp4Size;
  String size;
  String url;
  String webp;
  String webpSize;
  String width;
  String frames;
  String hash;

  FixedHeight({
    this.height,
    this.mp4,
    this.mp4Size,
    this.size,
    this.url,
    this.webp,
    this.webpSize,
    this.width,
    this.frames,
    this.hash,
  });

  factory FixedHeight.fromJson(Map<String, dynamic> json) => FixedHeight(
        height: json["height"],
        mp4: json["mp4"] == null ? null : json["mp4"],
        mp4Size: json["mp4_size"] == null ? null : json["mp4_size"],
        size: json["size"],
        url: json["url"],
        webp: json["webp"],
        webpSize: json["webp_size"],
        width: json["width"],
        frames: json["frames"] == null ? null : json["frames"],
        hash: json["hash"] == null ? null : json["hash"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "mp4": mp4 == null ? null : mp4,
        "mp4_size": mp4Size == null ? null : mp4Size,
        "size": size,
        "url": url,
        "webp": webp,
        "webp_size": webpSize,
        "width": width,
        "frames": frames == null ? null : frames,
        "hash": hash == null ? null : hash,
      };
}

class Looping {
  String mp4;
  String mp4Size;

  Looping({
    this.mp4,
    this.mp4Size,
  });

  factory Looping.fromJson(Map<String, dynamic> json) => Looping(
        mp4: json["mp4"],
        mp4Size: json["mp4_size"],
      );

  Map<String, dynamic> toJson() => {
        "mp4": mp4,
        "mp4_size": mp4Size,
      };
}

enum Rating { G }

final ratingValues = EnumValues({"g": Rating.G});

enum Type { GIF }

final typeValues = EnumValues({"gif": Type.GIF});

class User {
  String avatarUrl;
  String bannerImage;
  String bannerUrl;
  String profileUrl;
  String username;
  String displayName;
  bool isVerified;

  User({
    this.avatarUrl,
    this.bannerImage,
    this.bannerUrl,
    this.profileUrl,
    this.username,
    this.displayName,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        avatarUrl: json["avatar_url"],
        bannerImage: json["banner_image"],
        bannerUrl: json["banner_url"],
        profileUrl: json["profile_url"],
        username: json["username"],
        displayName: json["display_name"],
        isVerified: json["is_verified"],
      );

  Map<String, dynamic> toJson() => {
        "avatar_url": avatarUrl,
        "banner_image": bannerImage,
        "banner_url": bannerUrl,
        "profile_url": profileUrl,
        "username": username,
        "display_name": displayName,
        "is_verified": isVerified,
      };
}

class Meta {
  int status;
  String msg;
  String responseId;

  Meta({
    this.status,
    this.msg,
    this.responseId,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        status: json["status"],
        msg: json["msg"],
        responseId: json["response_id"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
        "response_id": responseId,
      };
}

class Pagination {
  int totalCount;
  int count;
  int offset;

  Pagination({
    this.totalCount,
    this.count,
    this.offset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalCount: json["total_count"],
        count: json["count"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "count": count,
        "offset": offset,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
