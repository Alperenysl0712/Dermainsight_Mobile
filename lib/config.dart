class AppConfig{
  static const String _baseUrl = 'http://172.26.200.249:8000';

  static String get statusCheckUrl => '$_baseUrl/health/';

  static String get getUserByUsernameUrl => '$_baseUrl/getUserByUsername/';

  static String get registerUrl => '$_baseUrl/register/';

  static String get getPatientsByDoctorUrl => '$_baseUrl/getPatientsByDoctor/';

  static String get getDiseaseInfoUrl => '$_baseUrl/getDiseaseInfo/';

  static String get getPatientsUrl => '$_baseUrl/getPatients/';

  static String get getDiseasesUrl => '$_baseUrl/getDiseases/';

  static String get createDiseaseInfoUrl => '$_baseUrl/createDiseaseInfo/';

  static String get uploadImageUrl => '$_baseUrl/getAiDisease/';

  static String get createCsvUrl => '$_baseUrl/createNewCsv/';
}