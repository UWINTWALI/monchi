import 'package:http/http.dart' as http;
import '../../../core/config/env_config.dart';

final String baseUrl = EnvConfig.apiBaseUrl;

// Example usage in a function:
Future<void> fetchSkills() async {
  final response = await http.get(Uri.parse('$baseUrl/skills'));
  // ...handle response...
}