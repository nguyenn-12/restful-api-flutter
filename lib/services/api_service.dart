import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/post.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://gorest.co.in/public/v2")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/users") // API lấy danh sách người dùng
  Future<List<User>> getUsers(@Query("page") int page, @Query("per_page") int perPage);
  @GET("/posts")
  Future<List<Post>> getPosts(@Query("page") int page, @Query("per_page") int perPage);
}
