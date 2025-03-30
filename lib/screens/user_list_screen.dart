import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


enum DataType { users, posts }

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  static const _pageSize = 10;
  final PagingController<int, User> _userPagingController = PagingController(firstPageKey: 1);
  final PagingController<int, Post> _postPagingController = PagingController(firstPageKey: 1);
  late ApiService apiService;
  DataType? _currentDataType;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    apiService = ApiService(dio);
    _userPagingController.addPageRequestListener((pageKey) {
      if (_currentDataType == DataType.users) _fetchUsers(pageKey);
    });

    _postPagingController.addPageRequestListener((pageKey) {
      if (_currentDataType == DataType.posts) _fetchPosts(pageKey);
    });
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  // Hàm hiển thị thông báo
  void _showNotification(String message) async {
    var androidDetails = const AndroidNotificationDetails(
      'channel_id',
      'New Data Notification',
      importance: Importance.high,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Cập nhật dữ liệu',
      message,
      generalNotificationDetails,
    );
  }

  Future<void> _fetchUsers(int pageKey) async {
    try {
      final newItems = await apiService.getUsers(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _userPagingController.appendLastPage(newItems);
      } else {
        _userPagingController.appendPage(newItems, pageKey + 1);
      }
      _showNotification("User list have been updated!");
    } catch (error) {
      _userPagingController.error = error;
    }
  }

  Future<void> _fetchPosts(int pageKey) async {
    try {
      final newItems = await apiService.getPosts(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _postPagingController.appendLastPage(newItems);
      } else {
        _postPagingController.appendPage(newItems, pageKey + 1);
      }
      _showNotification("Post list have been updated!");
    } catch (error) {
      _postPagingController.error = error;
    }
  }

  void _onGetUsersPressed() {
    setState(() {
      _currentDataType = DataType.users;
      _userPagingController.refresh();
    });
  }

  void _onGetPostsPressed() {
    setState(() {
      _currentDataType = DataType.posts;
      _postPagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data List")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _onGetUsersPressed,
                child: Text("Get Users"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _onGetPostsPressed,
                child: Text("Get Posts"),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_currentDataType == DataType.users) {
                  _userPagingController.refresh();
                } else if (_currentDataType == DataType.posts) {
                  _postPagingController.refresh();
                }
              },
              child: _currentDataType == DataType.users
                  ? PagedListView<int, User>(
                pagingController: _userPagingController,
                builderDelegate: PagedChildBuilderDelegate<User>(
                  itemBuilder: (context, user, index) => ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Text(user.gender),
                  ),
                ),
              )
                  : _currentDataType == DataType.posts
                  ? PagedListView<int, Post>(
                pagingController: _postPagingController,
                builderDelegate: PagedChildBuilderDelegate<Post>(
                  itemBuilder: (context, post, index) => ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.body),
                  ),
                ),
              )
                  : Center(child: Text("Select an option")),
            ),
          )
        ],
      ),
    );
  }
}
