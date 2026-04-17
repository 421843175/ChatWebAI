import 'dart:convert';

/**
 * 用户模型类 - 对应后端User实体
 */
class UserModel {
  // 用户名
  final String username;
  // 昵称
  final String nick;
  // 头像
  final String head;
  // 角色：1=卖家，2=买家
  final int role;
  // token令牌
  final String? token;

  UserModel({
    required this.username,
    required this.nick,
    required this.head,
    required this.role,
    this.token,
  });

  // 从JSON解析
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      nick: json['nick'] ?? '',
      head: json['head'] ?? '',
      role: json['role'] ?? 2,
      token: json['token'],
    );
  }

  // 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nick': nick,
      'head': head,
      'role': role,
      'token': token,
    };
  }
}

/**
 * 联系人模型 - 对应聊天好友
 */
class ContactModel {
  // 用户名
  final String username;
  // 昵称
  final String nickname;
  // 头像
  final String head;
  // 最后消息
  final String messageEnd;
  // 时间戳
  final String timestamp;
  // 未读消息数
  final int unreadnum;
  // 是否是机器人
  final int isRobot;

  ContactModel({
    required this.username,
    required this.nickname,
    required this.head,
    required this.messageEnd,
    required this.timestamp,
    required this.unreadnum,
    required this.isRobot,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? json['nick'] ?? '',
      head: json['head'] ?? '',
      messageEnd: json['messageEnd'] ?? '',
      timestamp: json['timestamp'] ?? '',
      unreadnum: json['unreadnum'] ?? 0,
      isRobot: json['isRobot'] ?? 0,
    );
  }
}

/**
 * 商品模型
 */
class GoodsModel {
  final int id;
  final String src;
  final String name;
  final double price;
  final String merchant;
  final String date;
  final String description;
  final double star;
  final List<dynamic> evaluate;

  GoodsModel({
    this.id = 0,
    required this.src,
    required this.name,
    required this.price,
    required this.merchant,
    this.date = '',
    this.description = '',
    this.star = 0,
    this.evaluate = const [],
  });

  factory GoodsModel.fromJson(Map<String, dynamic> json) {
    // 获取图片URL，处理localhost问题（Flutter运行在真机/模拟器上时localhost无法访问）
    String src = json['src'] ?? json['image'] ?? '';
    // 将 localhost:8090 替换为实际后端地址，确保手机能正常访问
    if (src.startsWith('http://localhost:8090')) {
      src = src.replaceFirst('http://localhost:8090', 'http://192.168.31.88:8090');
    }
    return GoodsModel(
      id: json['id'] ?? 0,
      src: src,
      name: json['name'] ?? json['title'] ?? '',
      price: _parseDouble(json['price']),
      merchant: json['merchant'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      star: _parseDouble(json['star']),
      evaluate: _parseEvaluate(json['evaluate']),
    );
  }

  static List<dynamic> _parseEvaluate(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is List) return parsed;
      } catch (_) {}
    }
    return [];
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/**
 * 商品描述结构化数据
 */
class GoodsDescription {
  final String brand;
  final String productName;
  final List<ProductPrice> productPrices;
  final List<String> features;
  final List<Map<String, String>> specifications;
  final List<String> scenes;
  final String remark;

  GoodsDescription({
    this.brand = '',
    this.productName = '',
    this.productPrices = const [],
    this.features = const [],
    this.specifications = const [],
    this.scenes = const [],
    this.remark = '',
  });

  factory GoodsDescription.fromJson(Map<String, dynamic> json) {
    List<ProductPrice> productPrices = [];
    if (json['productPrices'] != null) {
      productPrices = (json['productPrices'] as List)
          .map((e) => ProductPrice.fromJson(e))
          .toList();
    }

    List<Map<String, String>> specifications = [];
    if (json['specifications'] != null) {
      if (json['specifications'] is Map) {
        specifications = (json['specifications'] as Map).entries
            .map((e) => {'key': e.key.toString(), 'value': e.value.toString()})
            .toList();
      }
    }

    return GoodsDescription(
      brand: json['brand'] ?? '',
      productName: json['productName'] ?? '',
      productPrices: productPrices,
      features: List<String>.from(json['features'] ?? []),
      specifications: specifications,
      scenes: List<String>.from(json['scenes'] ?? []),
      remark: json['remark'] ?? '',
    );
  }

  bool get hasContent =>
      brand.isNotEmpty ||
      productName.isNotEmpty ||
      productPrices.isNotEmpty ||
      features.isNotEmpty ||
      specifications.isNotEmpty ||
      scenes.isNotEmpty ||
      remark.isNotEmpty;
}

/**
 * 价格方案
 */
class ProductPrice {
  final String name;
  final double price;

  ProductPrice({this.name = '', this.price = 0});

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      name: json['name'] ?? '',
      price: _parseDouble(json['price']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/**
 * 商品评价模型
 */
class EvaluateModel {
  final String username;
  final double rating;
  final String comment;
  final String time;

  EvaluateModel({
    this.username = '',
    this.rating = 0,
    this.comment = '',
    this.time = '',
  });

  factory EvaluateModel.fromJson(Map<String, dynamic> json) {
    return EvaluateModel(
      username: _parseString(json['username'] ?? json['user'], '匿名用户'),
      rating: _parseDouble(json['rating'] ?? json['score']),
      comment: _parseString(json['comment'] ?? json['content'], ''),
      time: _parseString(json['time'] ?? json['createTime'] ?? json['date'], ''),
    );
  }

  static String _parseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return defaultValue;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/**
 * 聊天消息模型
 */
class MessageModel {
  final String sender;
  final String content;
  final String time;
  final bool isSelf;

  MessageModel({
    required this.sender,
    required this.content,
    required this.time,
    required this.isSelf,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      isSelf: json['isSelf'] ?? false,
    );
  }
}