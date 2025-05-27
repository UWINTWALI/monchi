class EnvConfig {
  static String _apiBaseUrl = 'http://172.31.30.73:3000/api'; // Default value

  static String get apiBaseUrl => _apiBaseUrl;

  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static void initializeDevConfig() {
    // You can add more environment-specific configurations here
    setApiBaseUrl('http://172.31.30.73:3000/api');
  }

  static void initializeProdConfig() {
    // Production configuration can be set here
    setApiBaseUrl('https://your-production-api.com/api');
  }
}
