class EnvConfig {
  static String _apiBaseUrl = 'http://172.31.15.56:3000/api'; // Defined ONCE here

  static String get apiBaseUrl => _apiBaseUrl;  // Correct getter syntax

  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static void initializeDevConfig() {
    // Uncomment and set if you want a different dev URL
    // setApiBaseUrl('http://your-dev-api-url/api');
  }

  static void initializeProdConfig() {
    // Uncomment and set if you want a different prod URL
    // setApiBaseUrl('https://your-production-api.com/api');
  }
}
