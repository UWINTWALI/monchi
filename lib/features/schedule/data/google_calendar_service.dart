import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../presentation/schedule_page.dart';

class GoogleCalendarService {
  static final _scopes = [calendar.CalendarApi.calendarScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> addScheduleToCalendar(Schedule schedule) async {
    final account = await _googleSignIn.signIn();
    if (account == null) return;
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final calendarApi = calendar.CalendarApi(authenticateClient);

    final event = calendar.Event()
      ..summary = schedule.title
      ..description = schedule.comment
      ..start = calendar.EventDateTime(
        date: schedule.startDate,
        dateTime: schedule.startDate,
        timeZone: 'UTC',
      )
      ..end = calendar.EventDateTime(
        date: schedule.endDate,
        dateTime: schedule.endDate,
        timeZone: 'UTC',
      );

    await calendarApi.events.insert(event, "primary");
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
