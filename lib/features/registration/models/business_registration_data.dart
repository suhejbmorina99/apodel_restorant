class BusinessRegistrationData {
  // Basic Information
  String? emriBiznesit;
  String? numriIdentifikues;
  String? numriMobil;
  String? shteti;
  String? qyteti;
  String? postalCode;
  String? adresa;

  // Category & Cuisine
  String? kategorite;
  String? kuzhina;

  // Opening Hours
  String? orariHapjes;
  String? orariMbylljes;

  BusinessRegistrationData({
    this.emriBiznesit,
    this.numriIdentifikues,
    this.numriMobil,
    this.shteti,
    this.qyteti,
    this.postalCode,
    this.adresa,
    this.kategorite,
    this.kuzhina,
    this.orariHapjes,
    this.orariMbylljes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'emri_biznesit': emriBiznesit,
      'numri_identifikues': numriIdentifikues,
      'numri_mobil': numriMobil,
      'shteti': shteti,
      'qyteti': qyteti,
      'postal_code': postalCode,
      'adresa': adresa,
      'kategorit': kategorite,
      'orari_hapjes': orariHapjes,
      'orari_mbylljes': orariMbylljes,
    };

    // Only add cuisine if it's not null
    if (kuzhina != null) {
      data['kuzhina'] = kuzhina;
    }

    return data;
  }
}
