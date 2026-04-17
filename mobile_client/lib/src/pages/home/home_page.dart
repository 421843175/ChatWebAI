import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/http_service.dart';

/**
 * 主页/商品列表页面 - 电商风格设计
 * 清晰的商品展示，配合促销氛围
 */
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpService _http = HttpService();
  List<GoodsModel> _goods = [];
  String _nick = '';
  String _head = '';
  int _role = 2;
  bool _isLoading = true;
  // 搜索相关状态变量
  final TextEditingController _searchController = TextEditingController();  // 搜索框控制器
  String _searchKeyword = '';  // 搜索关键词
  bool _isSearching = false;  // 是否处于搜索状态
  // 分页相关状态变量
  int _currentPage = 1;  // 当前页码
  final int _pageSize = 10;  // 每页大小
  int _totalPages = 1;  // 总页数
  bool _isLoadingMore = false;  // 是否正在加载更多
  bool _hasMoreData = true;  // 是否还有更多数据

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 初始化时重置分页状态
    _currentPage = 1;
    _hasMoreData = true;
    try {
      await Future.wait([
        _loadGoods(),
        _loadUserInfo(),
      ]);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGoods() async {
    try {
      // 搜索模式下不走分页
      if (_isSearching) return;

      final response = await _http.get(
        ApiConfig.goodsList,
        params: {'page': _currentPage, 'size': _pageSize},
      );
      if (response.data['code'] == 200) {
        final pageData = response.data['data'];
        final List goodsData = pageData['records'] ?? pageData;

        setState(() {
          if (_currentPage == 1) {
            // 第一页：替换数据
            _goods = goodsData.map((e) => GoodsModel.fromJson(e)).toList();
          } else {
            // 后续页：追加数据
            _goods.addAll(goodsData.map((e) => GoodsModel.fromJson(e)).toList());
          }
          // 从分页信息获取总页数
          _totalPages = pageData['pages'] ?? 1;
          _hasMoreData = _currentPage < _totalPages;
        });
      }
    } catch (e) {
      print('加载商品失败: $e');
    }
  }

  // 下拉刷新：重置到第一页
  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    await Future.wait([
      _loadGoods(),
      _loadUserInfo(),
    ]);
  }

  // 加载更多：页码+1
  Future<void> _loadMoreGoods() async {
    if (_isLoadingMore || !_hasMoreData || _isSearching) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadGoods();

    setState(() {
      _isLoadingMore = false;
    });
  }

  // 执行商品搜索
  Future<void> _handleSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      // 如果关键词为空，加载全部商品
      _resetSearch();
      return;
    }
    try {
      setState(() {
        _isSearching = true;
        _searchKeyword = keyword;
      });
      final response = await _http.get(ApiConfig.goodsSearch, params: {'keyword': keyword});
      if (response.data['code'] == 200) {
        final List goodsData = response.data['data'];
        setState(() {
          _goods = goodsData.map((e) => GoodsModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print('搜索商品失败: $e');
      _showError('搜索失败，请重试');
    }
  }

  // 重置搜索，恢复全部商品列表
  Future<void> _resetSearch() async {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchKeyword = '';
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _loadGoods();
  }

  Future<void> _loadUserInfo() async {
    try {
      final token = await _http.getToken();
      if (token == null) return;

      final response = await _http.get(ApiConfig.getMy, params: {'usertoken': token});
      if (response.data['code'] == 200) {
        final data = response.data['data'];
        setState(() {
          _nick = data['nick'] ?? '';
          _head = data['head'] ?? '';
          _role = data['role'] ?? 2;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  Future<void> _contactMerchant(GoodsModel goods) async {
    try {
      final token = await _http.getToken();
      if (token == null) return;

      await _http.post(ApiConfig.toChat, data: {
        'usertoken': token,
        'item': {
          'merchant': goods.merchant,
          'src': goods.src,
          'name': goods.name,
          'price': goods.price,
        },
      });

      if (mounted) {
        Navigator.pushNamed(context, '/chat', arguments: {'user': goods.merchant, 'role': _role});
      }
    } catch (e) {
      _showError('操作失败');
    }
  }

  void _toChat(int role) {
    Navigator.pushNamed(context, '/chat', arguments: {'role': role});
  }

  Future<void> _logout() async {
    await _http.clearToken();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

@override
Widget build(BuildContext context) {
  // 返回页面的主体结构
  return Scaffold(
    // 设置整个页面的背景颜色为浅灰色
    backgroundColor: const Color(0xFFF5F5F5),
    // TODO:NOTICE 使用 RefreshIndicator 实现下拉刷新功能
    // RefreshIndicator 包裹 CustomScrollView，当用户下拉时会触发 onRefresh 回调
    // 页面主体内容
    body: _isLoading
        // 如果正在加载，显示圆形进度指示器
        ? const Center(child: CircularProgressIndicator())
        // 否则显示可下拉刷新的内容区域
        : RefreshIndicator(
            // 下拉刷新时的回调函数，用于重新加载数据
            onRefresh: _onRefresh,
            // 下拉刷新时的指示器样式，使用系统默认样式

            //页面正常试图
            // 可滚动的自定义视图
            child: NotificationListener<ScrollNotification>(
              // 监听滚动事件，实现上拉加载更多
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
                  // 距底部小于100像素时触发加载更多
                  _loadMoreGoods();
                }
                return false;
              },
              child: CustomScrollView(
                // 设置滚动物理效果，确保始终可滚动
                physics: const AlwaysScrollableScrollPhysics(),
                // 定义滚动区域内的各个子组件
                slivers: [
                  // 顶部促销banner组件
                  _buildPromoBanner(),
                  // 用户信息栏组件
                  _buildUserBar(),
                  // 搜索栏组件
                  _buildSearchBar(),
                  // 商品网格组件
                  _buildGoodsGrid(),
                  // 底部加载更多指示器
                  _buildLoadMoreIndicator(),
                  // 底部填充，避免内容被底部导航栏遮挡
                  const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
                ],
              ),
            ),
          ),
    // 底部导航栏组件
    bottomNavigationBar: _buildBottomBar(),
  );
}

  /**
   * 顶部高端banner - 参考前端设计风格
   */
  Widget _buildPromoBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          // 高端深色渐变背景，参考前端 collection-banner
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF162033), Color(0xFF22314D), Color(0xFFD5B06F)],
            stops: [0.0, 0.46, 1.0],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1B2538).withOpacity(0.22), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            // 左侧品牌区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 品牌标识
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EFE1).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB49A66).withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Text(
                            'CW',
                            style: const TextStyle(
                              color: Color(0xFF8F621D),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ChatWeb Select',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '高质感数字商品客服平台',
                            style: TextStyle(
                              color: Color(0xFFC0C8D4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 标题
                  const Text(
                    '精选数字商品',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '一对一专属咨询，精品臻选',
                    style: TextStyle(
                      color: Color(0xFFC0C8D4),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            // 右侧用户信息
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Premium标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.26)),
                  ),
                  child: const Text(
                    'Premium Selection',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 用户头像
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundImage: _head.isNotEmpty ? NetworkImage(_head) : null,
                        child: _head.isEmpty
                            ? const Icon(Icons.person, color: AppTheme.primaryColor, size: 20)
                            : null,
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nick.isNotEmpty ? _nick : '游客',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _role == 1 ? '卖家工作台' : '买家尊享',
                            style: const TextStyle(
                              color: Color(0xFFC0C8D4),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 用户信息栏
   */
  Widget _buildUserBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: _head.isNotEmpty ? NetworkImage(_head) : null,
              child: _head.isEmpty ? const Icon(Icons.person, color: AppTheme.primaryColor) : null,
              onBackgroundImageError: (exception, stackTrace) {},
            ),
            const SizedBox(width: 12),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好，${_nick.isNotEmpty ? _nick : "游客"}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _role == 1 ? '卖家身份' : '买家身份',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // 退出按钮
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 搜索栏
   */
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            // 搜索框行
            Row(
              children: [
                // 搜索图标
                const Icon(Icons.search, color: Colors.grey, size: 22),
                const SizedBox(width: 12),
                // 搜索输入框
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索商品名称 / 商家 / 关键词',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                // 搜索按钮
                GestureDetector(
                  onTap: _handleSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B2943), Color(0xFF2F4670)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '搜索',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                // 清空按钮（仅在有搜索内容时显示）
                if (_isSearching || _searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _resetSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '清空',
                        style: TextStyle(color: Color(0xFF53627B), fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // 搜索结果统计
            if (_isSearching) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '找到 ${_goods.length} 条搜索结果',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /**
   * 商品网格
   */
  Widget _buildGoodsGrid() {
    if (_goods.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFDDDDDD)),
              SizedBox(height: 16),
              Text('暂无商品', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGoodsCard(_goods[index]),
          childCount: _goods.length,
        ),
      ),
    );
  }

  /**
   * 底部加载更多指示器
   */
  Widget _buildLoadMoreIndicator() {
    // 搜索模式下不显示加载更多
    if (_isSearching) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (_isLoadingMore) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!_hasMoreData && _goods.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '— 已加载全部 ${_goods.length} 件商品 —',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  /**
   * 商品卡片 - 电商风格
   */
  Widget _buildGoodsCard(GoodsModel goods) {
    return GestureDetector(
      onTap: () {
        // 跳转到商品详情页
        Navigator.pushNamed(context, '/goods-detail', arguments: {'id': goods.id});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    goods.src.isNotEmpty
                        ? Image.network(
                            goods.src,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                          )
                        : Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.image, size: 40, color: Colors.grey)),
                    // 精品标签（star > 7 显示金色精品标签，否则不显示）
                    if (goods.star > 7)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // 金色渐变背景，精品臻选风格
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4A14A), Color(0xFFB77718)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB77718).withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text('精品', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 商品信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goods.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '¥${goods.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
                        ),
                        const Text('/ 起', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 底部导航栏
   */
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.store, '店铺', true, () {}),
              _buildNavItem(Icons.chat_bubble_outline, '聊天', false, () => _toChat(_role)),
              _buildNavItem(Icons.support_agent, '客服', false, () => _toChat(_role == 1 ? 0 : 1)),
              if (_role == 1) _buildNavItem(Icons.settings, '设置', false, () => Navigator.pushNamed(context, '/setting')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}