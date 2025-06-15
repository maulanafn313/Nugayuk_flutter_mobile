import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';
import '../models/category.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiService {
  // Ganti dengan URL dasar API Laravel Anda
  static const baseUrl = 'http://192.168.208.243:8000/api';
  final _storage = FlutterSecureStorage();

  // Getter untuk token
  Future<String?> getToken() async => await _storage.read(key: 'token');

  // -- Auth --
  Future<bool> signUp(
    String name,
    String email,
    String pass,
    String passConfirm,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': pass,
        'password_confirmation': passConfirm,
      }),
    );
    return res.statusCode == 201;
  }

  Future<bool> signIn(String email, String pass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': pass}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'token', value: data['token']);
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      // Pastikan endpoint logout di Laravel Anda benar
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      await _storage.delete(key: 'token');
    }
  }

  // Contoh di services/service.dart
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      print('Token not found for getUserProfile');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', 
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Jika UserResource Laravel membungkus output dalam 'data'
      if (responseBody != null && responseBody['data'] is Map<String, dynamic>) {
        return responseBody['data'] as Map<String, dynamic>;
      }
      // Fallback jika tidak dibungkus 'data' (kurang umum untuk resource tunggal)
      return responseBody as Map<String, dynamic>;
    } else {
      print('Failed to get user profile: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // Ambil token
  Future<String?> get _token async => await _storage.read(key: 'token');

  // -- Schedule CRUD --
  Future<List<Schedule>> fetchSchedules() async {
    final token = await _token;
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final res = await http.get(
      Uri.parse('$baseUrl/schedules'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body)['data'];
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load schedules: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<List<Category>> fetchCategories() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final res = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      // Ensure the JSON structure matches what you expect.
      // If CategoryResource::collection is used, it should be {'data': [...]}
      final Map<String, dynamic> responseData = jsonDecode(res.body);
      if (responseData.containsKey('data') && responseData['data'] is List) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        // Handle cases where 'data' key is missing or not a list
        throw Exception(
          'Failed to parse categories: "data" key missing or not a list. Response: ${res.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to load categories: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<Schedule> createSchedule(Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final res = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return Schedule.fromJson(jsonDecode(res.body)['data']);
    } else {
      throw Exception(
        'Failed to create schedule: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<Schedule> updateSchedule(int id, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final res = await http.put(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(res.body)['data']);
    } else {
      throw Exception(
        'Failed to update schedule: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<bool> deleteSchedule(int id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    final res = await http.delete(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete schedule: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<Schedule> markScheduleAsDone(int id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. User not authenticated.');
    }
    // Asumsi ada endpoint untuk mark as done, jika tidak ada, Anda bisa menggunakan update
    // Misalnya, Anda bisa mengirim PUT request ke schedules/{id} dengan status: 'completed'
    final res = await http.put(
      Uri.parse('$baseUrl/schedules/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode({'status': 'completed'}),
    );

    if (res.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(res.body)['data']);
    } else {
      // Cetak body respons untuk debugging jika terjadi redirect atau error lain
      print(
        'Failed to mark schedule as done. Status: ${res.statusCode}, Body: ${res.body}',
      );
      throw Exception(
        'Failed to mark schedule as done: ${res.statusCode} ${res.body}',
      );
    }
  }
}
