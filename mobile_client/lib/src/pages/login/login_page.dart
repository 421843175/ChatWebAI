import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api.dart';

/**
 * HTTP服务类
 */
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  late final Dio _dio;

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseURL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await _dio.post(url, data: data);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usertoken', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usertoken');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usertoken');
  }
}

/**
 * 登录注册页面
 */
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final HttpService _http = HttpService();
  final _formKey = GlobalKey<FormState>();
  bool _isRegister = false;
  bool _isLoading = false;

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNickController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  String _selectedRole = '2';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerNickController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    print('登录按钮被点击');
    if (!_formKey.currentState!.validate()) {
      print('表单验证失败');
      return;
    }

    setState(() => _isLoading = true);
    print('开始登录...');

    try {
      final response = await _http.post(
        ApiConfig.login,
        data: {
          'username': _loginUsernameController.text.trim(),
          'password': _loginPasswordController.text.trim(),
        },
      );

      print('登录响应: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final code = data['code'] ?? 500;

      if (code == 200) {
        final tokenData = data['data'];
        final token = tokenData?.toString() ?? '';
        await _http.saveToken(token);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final message = data['message'] ?? '登录失败';
        _showError(message);
      }
    } catch (e) {
      print('登录错误: $e');
      _showError('网络错误: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _doRegister() async {
    print('注册按钮被点击');
    if (!_formKey.currentState!.validate()) {
      print('表单验证失败');
      return;
    }

    if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
      _showError('两次输入密码不一致');
      return;
    }

    setState(() => _isLoading = true);
    print('开始注册...');

    try {
      final response = await _http.post(
        ApiConfig.register,
        data: {
          'username': _registerUsernameController.text.trim(),
          'password': _registerPasswordController.text.trim(),
          'nick': _registerNickController.text.trim(),
          'role': _selectedRole,
        },
      );

      print('注册响应: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final code = data['code'] ?? 500;

      if (code == 200) {
        _showSuccess('注册成功，请登录');
        setState(() => _isRegister = false);
      } else {
        final message = data['message'] ?? '注册失败';
        _showError(message);
      }
    } catch (e) {
      print('注册错误: $e');
      _showError('网络错误: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF64CCC5)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.chat_rounded, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '智能客服',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Tab切换
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  // 表单
                  _isRegister ? _buildRegisterForm() : _buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegister = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isRegister ? const Color(0xFF667EEA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '登录',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isRegister ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegister = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isRegister ? const Color(0xFF64CCC5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '注册',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isRegister ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _loginUsernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '账号',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.person, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? '请输入账号' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '密码',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入密码';
            if (value.length < 6) return '密码长度至少6位';
            return null;
          },
        ),
        const SizedBox(height: 24),
        // 登录按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _doLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('登录', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        TextFormField(
          controller: _registerNickController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '昵称',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.badge, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? '请输入昵称' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _registerUsernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '账号',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.person, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? '请输入账号' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _registerPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '密码',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入密码';
            if (value.length < 6) return '密码长度至少6位';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _registerConfirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '确认密码',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? '请确认密码' : null,
        ),
        const SizedBox(height: 16),
        // 角色选择
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = '1'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedRole == '1' ? const Color(0xFF667EEA).withOpacity(0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedRole == '1' ? const Color(0xFF667EEA) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, color: _selectedRole == '1' ? const Color(0xFF667EEA) : Colors.white54),
                      const SizedBox(width: 8),
                      Text('我是卖家', style: TextStyle(color: _selectedRole == '1' ? const Color(0xFF667EEA) : Colors.white54)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRole = '2'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedRole == '2' ? const Color(0xFF64CCC5).withOpacity(0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedRole == '2' ? const Color(0xFF64CCC5) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, color: _selectedRole == '2' ? const Color(0xFF64CCC5) : Colors.white54),
                      const SizedBox(width: 8),
                      Text('我是买家', style: TextStyle(color: _selectedRole == '2' ? const Color(0xFF64CCC5) : Colors.white54)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 注册按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _doRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64CCC5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('创建账户', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}