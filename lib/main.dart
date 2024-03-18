import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class Article {
  final String title;
  final String author;
  final String url;
  final String imageUrl;
  final String content;

  Article({
    required this.title,
    required this.author,
    required this.url,
    required this.imageUrl,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Article>> _futureArticles;

  @override
  void initState() {
    super.initState();
    _futureArticles = _fetchArticles();
  }

  Future<List<Article>> _fetchArticles() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=f3e22111c1534f60ae0f4b8aba98653c'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> articlesJson = jsonData['articles'];
      final List<Article> articles = articlesJson
          .map((articleJson) => Article.fromJson(articleJson))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight + 10, // Điều chỉnh chiều cao của thanh ứng dụng
        titleSpacing:
            0, // Đặt khoảng cách giữa các phần tử trong thanh ứng dụng là 0
        title: Align(
          alignment: Alignment.centerLeft, // Căn tiêu đề sang trái
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Explore',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài viết',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tất cả',
                        style: TextStyle(fontSize: 16.0, color: Colors.white)),
                  ),
                ),
                Text('Chính trị', style: TextStyle(fontSize: 16.0)),
                Text('Thể thao', style: TextStyle(fontSize: 16.0)),
                Text('Sức khỏe', style: TextStyle(fontSize: 16.0)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return ListTile(
                        leading: article.imageUrl.isNotEmpty
                            ? Image.network(article.imageUrl)
                            : Icon(Icons.image),
                        title: Text(article.title),
                        subtitle: Text(article.author),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailPage(article: article),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl)
                : Icon(Icons.image),
            SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Author: ${article.author}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            Text(
              article.content, // Hiển thị mô tả
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'URL: ${article.url}',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
