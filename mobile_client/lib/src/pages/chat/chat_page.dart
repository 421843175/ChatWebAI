import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import '../../config/api.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/http_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/**
 * 聊天页面 - 采用极简现代设计
 * 大量留白配合精致的卡片设计
 */
class ChatPage extends StatefulWidget {
  final String? user;
  final int? role;

  const ChatPage({Key? key, this.user, this.role}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  // HTTP服务
  final HttpService _http = HttpService();
  // 消息列表
  final List<MessageModel> _messages = [];
  // 输入控制器
  final _messageController = TextEditingController();
  // 滚动控制器
  final _scrollController = ScrollController();
  // 当前聊天对象
  String _currentUser = '';
  // 当前用户（自己）
  String _myUsername = '';
  // 是否是机器人
  bool _isRobot = false;
  // 加载状态
  bool _isLoading = false;
  // WebSocket通道
  WebSocketChannel? _channel;
  // 联系人列表
  List<ContactModel> _contacts = [];
  // 搜索控制器
  final _searchController = TextEditingController();
  // 是否显示联系人列表
  bool _showContacts = true;
  // 动画控制器
  late AnimationController _animController;
  // 是否连接中
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user ?? '';
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _initData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  /**
   * 初始化数据
   */
  Future<void> _initData() async {
    final token = await _http.getToken();
    if (token == null) {
      _showError('未登录');
      return;
    }

    print('【调试】初始化数据');
    print('【调试】传入的user: ${widget.user}, role: ${widget.role}');
    print('【调试】当前用户(_currentUser): $_currentUser');

    if (_currentUser.isNotEmpty) {
      setState(() {
        _showContacts = false;
      });
      // 先获取会话状态（is_robot），再确定机器人模式
      await _loadConversationStatus();
      print('【调试】从店铺进入，机器人模式: $_isRobot');
      await _loadHistory();
      _connectWebSocket();
    } else {
      await _loadContacts();
    }

    await _loadMyInfo();
    _animController.forward();
  }

  /**
   * 获取当前会话状态（is_robot）
   * 如果是新建会话，默认机器人模式
   */
  Future<void> _loadConversationStatus() async {
    try {
      final token = await _http.getToken();
      // 商家会话用 roleid=1，平台客服用 roleid=0
      // 尝试两个 roleid，总有一个能查到
      for (final roleid in [1, 0]) {
        final response = await _http.get(
          ApiConfig.getFriend,
          params: {'usertoken': token, 'roleid': roleid},
        );

        print('【调试】获取会话状态，尝试 roleid: $roleid');

        if (response.data['code'] == 200) {
          final List contacts = response.data['data'] as List;
          print('【调试】联系人数量: ${contacts.length}');

          // 打印所有联系人
          for (var c in contacts) {
            print('【调试】联系人: ${c['username']}, isRobot: ${c['isRobot']}');
          }

          // 找到与当前聊天用户的会话
          ContactModel? matchedContact;
          for (var c in contacts) {
            if (c['username'] == _currentUser) {
              matchedContact = ContactModel.fromJson(c);
              break;
            }
          }

          if (matchedContact != null) {
            // 根据会话的 isRobot 字段设置机器人模式
            setState(() {
              _isRobot = matchedContact!.isRobot == 1;
            });
            print('【调试】获取会话状态成功: isRobot=${matchedContact.isRobot}, _isRobot=$_isRobot');
            return;
          }
        }
      }

      // 所有 roleid 都查不到，默认机器人模式
      setState(() {
        _isRobot = true;
      });
      print('【调试】未找到会话，默认机器人模式');
    } catch (e) {
      print('获取会话状态失败: $e');
      // 默认设置为机器人模式
      setState(() {
        _isRobot = true;
      });
    }
  }

  /**
   * 加载联系人列表
   */
  Future<void> _loadContacts() async {
    try {
      final token = await _http.getToken();
      final response = await _http.get(
        ApiConfig.getFriend,
        params: {'usertoken': token, 'roleid': widget.role ?? 1},
      );

      if (response.data['code'] == 200) {
        setState(() {
          _contacts = (response.data['data'] as List)
              .map((e) => ContactModel.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      print('加载联系人失败: $e');
    }
  }

  /**
   * 加载自己的信息
   */
  Future<void> _loadMyInfo() async {
    try {
      final token = await _http.getToken();
      final response = await _http.get(ApiConfig.getMy, params: {'usertoken': token});

      if (response.data['code'] == 200) {
        setState(() {
          _myUsername = response.data['data']['username'];
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  /**
   * 连接WebSocket
   */
  void _connectWebSocket() {
    try {
      // 使用实际后端地址（WebSocket端口是8091，不是8090）
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.31.88:8091/socket.io'),
      );

      print('【调试】连接WebSocket，当前聊天用户: $_currentUser');

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onDone: () {
          print('【调试】WebSocket连接断开');
          setState(() => _isConnected = false);
        },
        onError: (error) {
          print('WebSocket错误: $error');
          setState(() => _isConnected = false);
        },
      );

      // 发送认证
      _sendAuth();
      setState(() => _isConnected = true);
    } catch (e) {
      print('WebSocket连接失败: $e');
    }
  }

  /**
   * 发送认证消息
   */
  Future<void> _sendAuth() async {
    final token = await _http.getToken();
    if (token != null && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'AUTH',
        'token': token,
      }));
    }
  }

  /**
   * 处理接收到的消息
   */
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      print('【调试】收到WebSocket消息: $json');
      print('【调试】当前用户: $_myUsername, 当前聊天对象: $_currentUser');

      if (json['type'] == 'message') {
        final sender = json['sender'] ?? '';
        final content = json['content'] ?? '';
        print('【调试】消息发送者: $sender, 是否是自己: ${sender == _myUsername}');

        final message = MessageModel(
          sender: sender,
          content: content,
          time: _formatTime(DateTime.now()),
          isSelf: sender == _myUsername,
        );

        setState(() {
          _messages.add(message);
        });

        _scrollToBottom();
      }
    } catch (e) {
      print('解析消息失败: $e');
    }
  }

  /**
   * 格式化时间
   */
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

/**
   * 加载聊天历史
   */
  Future<void> _loadHistory() async {
    if (_currentUser.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final token = await _http.getToken();
      final response = await _http.get(
        ApiConfig.getMy,
        params: {'usertoken': token},
      );

      if (response.data['code'] == 200) {
        final myUsername = response.data['data']['username'];

        // 调用获取历史记录的 API
        final historyResponse = await _http.get(
          'http://192.168.31.88:8090/chat/getHistory',
          params: {'usertoken': token, 'receiver': _currentUser},
        );

        print('【调试】历史记录响应: ${historyResponse.data}');

        if (historyResponse.data['code'] == 200) {
          final List historyList = historyResponse.data['data'] as List;
          print('【调试】历史记录数量: ${historyList.length}');

          setState(() {
            _messages.clear();
            _messages.addAll(historyList.map((msg) => MessageModel(
              sender: msg['sender'] ?? '',
              content: msg['content'] ?? '',
              time: msg['time'] ?? '',
              isSelf: msg['sender'] == myUsername,
            )));
          });

          print('【调试】已加载 $_messages.length 条历史消息');
        }
      }
    } catch (e) {
      print('加载历史失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /**
   * 发送消息
   */
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 添加自己发送的消息
    final myMessage = MessageModel(
      sender: _myUsername,
      content: text,
      time: _formatTime(DateTime.now()),
      isSelf: true,
    );

    setState(() {
      _messages.add(myMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // 如果是"转人工"命令
    if (text == '转人工') {
      await _toArtificial(text);
      return;
    }

    // 判断是否机器人模式
    if (_isRobot) {
      await _chatWithRobot(text);
    } else {
      await _chatWithPeople(text);
    }
  }

  /**
   * 与机器人聊天
   */
  Future<void> _chatWithRobot(String text) async {
    try {
      final token = await _http.getToken();
      final response = await _http.post(
        ApiConfig.robot,
        data: {
          'usertoken': token,
          'receiver': _currentUser,
          'content': text,
        },
      );

      print('机器人响应: ${response.data}');

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        String botReply = '';

        // 解析机器人回复 - 根据Vue前端代码，回复在data[1].content
        if (data is List && data.length > 1) {
          botReply = data[1]['content'] ?? '';
        } else if (data is Map) {
          botReply = data['content'] ?? data['reply'] ?? '';
        }

        if (botReply.isNotEmpty) {
          final botMessage = MessageModel(
            sender: _currentUser,
            content: botReply,
            time: _formatTime(DateTime.now()),
            isSelf: false,
          );

          setState(() {
            _messages.add(botMessage);
          });

          _scrollToBottom();
        }
      }
    } catch (e) {
      print('机器人聊天失败: $e');
      _showError('机器人服务暂时不可用');
    }
  }

  /**
   * 与真人聊天
   */
  Future<void> _chatWithPeople(String text) async {
    try {
      final token = await _http.getToken();
      final messageData = {
        'type': 'MSG',
        'token': token,
        'body': text,
        'to': _currentUser,
      };

      print('【调试】发送消息给真人');
      print('【调试】接收者(to): $_currentUser');
      print('【调试】消息内容(body): $text');
      print('【调试】当前是否机器人模式: $_isRobot');
      print('【调试】WebSocket连接状态: ${_channel != null}');

      _channel?.sink.add(jsonEncode(messageData));
      print('【调试】消息已发送');
    } catch (e) {
      print('发送消息失败: $e');
      _showError('发送失败');
    }
  }

  /**
   * 转人工
   */
  Future<void> _toArtificial(String text) async {
    try {
      final token = await _http.getToken();
      print('【调试】转人工开始');
      print('【调试】当前用户: $_currentUser');
      print('【调试】转人工前机器人模式: $_isRobot');

      final response = await _http.get(
        ApiConfig.toArtificial,
        params: {'usertoken': token, 'merchant': _currentUser},
      );

      print('【调试】转人工响应: ${response.data}');

      if (response.data['code'] == 200) {
        final botMessage = MessageModel(
          sender: _currentUser,
          content: response.data['data'] ?? '已为您转接人工客服',
          time: _formatTime(DateTime.now()),
          isSelf: false,
        );

        setState(() {
          _messages.add(botMessage);
          _isRobot = false;
        });

        print('【调试】转人工成功，已切换到人工模式: $_isRobot');

        _scrollToBottom();
      }
    } catch (e) {
      print('转人工失败: $e');
    }
  }

  /**
   * 滚动到底部
   */
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /**
   * 选择联系人
   */
  void _selectContact(ContactModel contact) {
    print('【调试】选择联系人');
    print('【调试】联系人用户名: ${contact.username}');
    print('【调试】是否机器人: ${contact.isRobot == 1}');

    setState(() {
      _currentUser = contact.username;
      _isRobot = contact.isRobot == 1;
      _showContacts = false;
      _messages.clear();
    });

    print('【调试】设置后 _currentUser: $_currentUser, _isRobot: $_isRobot');

    _loadHistory();
    _connectWebSocket();
  }

  /**
   * 显示错误
   */
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // 消息列表
            Expanded(child: _buildMessageList()),
            // 输入框
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /**
   * 构建AppBar
   */
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: _currentUser.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFAAAAAA),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isRobot ? '机器人客服' : '在线',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Text(
              '选择联系人',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        if (_currentUser.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              setState(() => _showContacts = !_showContacts);
            },
          ),
      ],
    );
  }

  /**
   * 构建消息列表
   */
  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_showContacts) {
      return _buildContactList();
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _currentUser.isNotEmpty
                  ? '开始和 $_currentUser 聊天'
                  : '选择一个联系人开始聊天',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '发送"转人工"可转接人工客服',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildMessageItem(message),
        );
      },
    );
  }

  /**
   * 构建消息项
   */
  Widget _buildMessageItem(MessageModel message) {
    return Align(
      alignment: message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: message.isSelf ? const Color(0xFF667EEA) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(message.isSelf ? 22 : 6),
            bottomRight: Radius.circular(message.isSelf ? 6 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(message.isSelf ? 0.1 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isSelf ? Colors.white : const Color(0xFF2D2D2D),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.time,
              style: TextStyle(
                color: message.isSelf
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFFBBBBBB),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 构建联系人列表
   */
  Widget _buildContactList() {
    return Column(
      children: [
        // 搜索框
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '搜索联系人',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFBBBBBB)),
              border: InputBorder.none,
            ),
          ),
        ),
        // 联系人列表
        Expanded(
          child: _contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: Color(0xFFDDDDDD),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无联系人',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 60)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildContactItem(contact),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /**
   * 构建联系人项
   */
  Widget _buildContactItem(ContactModel contact) {
    return GestureDetector(
      onTap: () => _selectContact(contact),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF64CCC5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: contact.head.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              contact.head,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFF667EEA)),
                  ),
                ),
                // 在线状态
                if (contact.isRobot == 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.nickname,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Text(
                        contact.timestamp,
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.messageEnd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (contact.unreadnum > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE74C3C), Color(0xFFE74C3C)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contact.unreadnum.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 构建输入区域
   */
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 输入框
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: _currentUser.isNotEmpty,
                  decoration: InputDecoration(
                    hintText: _currentUser.isEmpty
                        ? '请先选择联系人'
                        : '输入消息...',
                    hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 发送按钮
            GestureDetector(
              onTap: _currentUser.isEmpty ? null : _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _currentUser.isEmpty
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                  color: _currentUser.isEmpty
                      ? const Color(0xFFDDDDDD)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: _currentUser.isEmpty
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}