class EventInformation {
  final String id;
  final String title;
  final String description;
  final String video;
  final String slug;
  final String url;
  final ActivityImages images;
  final ActivityPricing pricing;
  final ActivityGeolocation geolocation;
  final ActivityDate date;
  final List<dynamic> metadatas;
  final ActivitySettings settings;
  final Categories categories;
  final ActivityOrganizer organizer;
  final bool isPast;
  final bool soldOut;
  final int state;
  final String activityType;

  EventInformation(
      {required this.id,
      required this.title,
      required this.description,
      required this.video,
      required this.slug,
      required this.url,
      required this.images,
      required this.pricing,
      required this.geolocation,
      required this.date,
      required this.metadatas,
      required this.settings,
      required this.categories,
      required this.organizer,
      required this.isPast,
      required this.soldOut,
      required this.state,
      required this.activityType});

  factory EventInformation.fromJson(Map<String, dynamic> json) {
    return EventInformation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      video: json['video'],
      slug: json['slug'],
      url: json['url'],
      images: ActivityImages.fromJson(json['images']),
      pricing: ActivityPricing.fromJson(json['pricing']),
      geolocation: ActivityGeolocation.fromJson(json['geolocation']),
      date: ActivityDate.fromJson(json['date']),
      metadatas: json['metadatas'],
      settings: ActivitySettings.fromJson(json['settings']),
      categories: Categories.fromJson(json['categories']),
      organizer: ActivityOrganizer.fromJson(json['organizer']),
      isPast: json['isPast'],
      soldOut: json['soldOut'],
      state: json['state'],
      activityType: json['activityType'],
    );
  }
}

class ActivityImages {
  final FullImage activityImage;

  ActivityImages({required this.activityImage});

  factory ActivityImages.fromJson(Map<String, dynamic> json) {
    return ActivityImages(
        activityImage: FullImage.fromJson(json['activityImage']));
  }
}

class FullImage {
  final String url;

  FullImage({required this.url});

  factory FullImage.fromJson(Map<String, dynamic> json) {
    return FullImage(url: json['full']['url']);
  }
}

class ActivityPricing {
  final bool isFree;
  final String code;
  final String symbol;
  final double amount;

  ActivityPricing(
      {required this.isFree,
      required this.code,
      required this.symbol,
      required this.amount});

  factory ActivityPricing.fromJson(Map<String, dynamic> json) {
    return ActivityPricing(
      isFree: json['isFree'],
      code: json['code'],
      symbol: json['symbol'],
      amount: double.parse((json['amount'].toString())),
    );
  }
}

class ActivityGeolocation {
  final String city;
  final Country country;
  final String address;
  final Geopoint geopoint;

  ActivityGeolocation(
      {required this.city,
      required this.country,
      required this.address,
      required this.geopoint});

  factory ActivityGeolocation.fromJson(Map<String, dynamic> json) {
    return ActivityGeolocation(
        city: json['city'],
        country: Country.fromJson(json['country']),
        address: json['address'],
        geopoint: Geopoint.fromJson(json['geopoint']));
  }
}

class Country {
  final String code;

  Country({required this.code});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(code: json['code']);
  }
}

class Geopoint {
  final double latitude;
  final double longitude;

  Geopoint({required this.latitude, required this.longitude});

  factory Geopoint.fromJson(Map<String, dynamic> json) {
    return Geopoint(latitude: json['latitude'], longitude: json['longitude']);
  }
}

class ActivityDate {
  final DateTime starts;
  final DateTime ends;

  ActivityDate({required this.starts, required this.ends});

  factory ActivityDate.fromJson(Map<String, dynamic> json) {
    return ActivityDate(
      starts: DateTime.parse(json['starts']),
      ends: DateTime.parse(json['ends']),
    );
  }
}

class ActivitySettings {
  final bool foreignActivity;

  ActivitySettings({required this.foreignActivity});

  factory ActivitySettings.fromJson(Map<String, dynamic> json) {
    return ActivitySettings(foreignActivity: json['foreignActivity']);
  }
}

class Categories {
  final MainCategory main;

  Categories({required this.main});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(main: MainCategory.fromJson(json['main']));
  }
}

class MainCategory {
  final String name;
  final String slug;

  MainCategory({required this.name, required this.slug});

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(name: json['name'], slug: json['slug']);
  }
}

class ActivityOrganizer {
  final String id;
  final String? slug;
  final String firstName;
  final String lastName;

  ActivityOrganizer(
      {required this.id,
      required this.slug,
      required this.firstName,
      required this.lastName});

  factory ActivityOrganizer.fromJson(Map<String, dynamic> json) {
    return ActivityOrganizer(
        id: json['id'],
        slug: json['slug'],
        firstName: json['firstName'],
        lastName: json['lastName']);
  }
}

class EventInformationList {
  final List<EventInformation> events;

  EventInformationList({required this.events});

  factory EventInformationList.fromJson(List<dynamic> json) {
    List<EventInformation> events = [];
    events = json.map((i) => EventInformation.fromJson(i)).toList();

    return EventInformationList(events: events);
  }
}
