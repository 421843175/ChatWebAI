import 'dart:convert';

import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/http_service.dart';

/**
 * 商品详情页 - 高端电商风格
 */
class GoodsDetailPage extends StatefulWidget {
  final int goodsId;

  const GoodsDetailPage({Key? key, required this.goodsId}) : super(key: key);

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  final HttpService _http = HttpService();
  GoodsModel? _goods;
  GoodsDescription _description = GoodsDescription();
  List<EvaluateModel> _evaluateList = [];
  bool _isLoading = true;
  String _currentUsername = '';
  int _currentRole = 2;
  bool _isSelfGoods = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadGoodsDetail(),
      _loadCurrentUser(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGoodsDetail() async {
    try {
      final response = await _http.get(ApiConfig.goodsDetail, params: {'id': widget.goodsId});
      if (response.data['code'] == 200) {
        final data = response.data['data'];
        setState(() {
          _goods = GoodsModel.fromJson(data);
          _parseDescription(_goods!.description);
          _parseEvaluate(_goods!.evaluate);
          _isSelfGoods = _currentUsername.isNotEmpty && _goods!.merchant == _currentUsername;
        });
      }
    } catch (e) {
      print('加载商品详情失败: $e');
    }
  }

  void _parseDescription(String description) {
    if (description.isEmpty) return;
    try {
      final parsed = json.decode(description);
      setState(() {
        _description = GoodsDescription.fromJson(parsed);
      });
    } catch (e) {
      // 不是JSON格式，保持空描述
    }
  }

  void _parseEvaluate(dynamic evaluate) {
    print('评价数据原始值: $evaluate, 类型: ${evaluate.runtimeType}');
    if (evaluate == null || evaluate.toString().isEmpty) {
      print('评价为空');
      _evaluateList = [];
      return;
    }

    try {
      List<dynamic> list;
      if (evaluate is List) {
        list = evaluate;
      } else if (evaluate is String) {
        print('评价是字符串，开始解析: $evaluate');
        final parsed = json.decode(evaluate);
        list = parsed is List ? parsed : [parsed];
      } else {
        list = [evaluate];
      }

      print('解析后评价列表长度: ${list.length}');

      setState(() {
        _evaluateList = list
            .where((item) => item != null && item is Map)
            .map((item) {
              // 确保所有字段类型正确，特别是 time 和 username 可能是 int
              final Map<String, dynamic> fixedItem = {};
              item.forEach((key, value) {
                if (key == 'time' || key == 'username' || key == 'comment' || key == 'rating') {
                  fixedItem[key] = value;
                }
              });
              return EvaluateModel.fromJson(fixedItem);
            })
            .toList();
        print('转换后评价列表长度: ${_evaluateList.length}');
      });
    } catch (e) {
      print('评价解析失败: $e');
      _evaluateList = [];
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final token = await _http.getToken();
      if (token == null) return;

      final response = await _http.get(ApiConfig.getMy, params: {'usertoken': token});
      if (response.data['code'] == 200) {
        final data = response.data['data'];
        setState(() {
          _currentUsername = data['username'] ?? '';
          _currentRole = data['role'] ?? 2;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  Future<void> _contactMerchant() async {
    if (_isSelfGoods || _goods == null) return;

    try {
      final token = await _http.getToken();
      if (token == null) return;

      await _http.post(ApiConfig.toChat, data: {
        'usertoken': token,
        'item': {
          'merchant': _goods!.merchant,
          'src': _goods!.src,
          'name': _goods!.name,
          'price': _goods!.price,
        },
      });

      if (mounted) {
        Navigator.pushNamed(context, '/chat', arguments: {'user': _goods!.merchant, 'role': _currentRole});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('操作失败'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '暂无';
    // 如果是纯数字时间戳（13位），转换为可读日期
    if (RegExp(r'^\d{13}$').hasMatch(date)) {
      try {
        final timestamp = int.parse(date);
        final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return date;
      }
    }
    // 正常日期格式
    if (date.contains('T')) {
      return date.replaceAll('T', ' ').substring(0, date.length > 19 ? 19 : date.length);
    }
    return date.length > 19 ? date.substring(0, 19) : date;
  }

  bool get _canEvaluate => _currentRole == 2 && !_isSelfGoods;

  void _showEvaluateDialog() {
    double rating = 5.0; // 评分范围 0.5-5.0，可点半颗星
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '商品评价',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F304E)),
                ),
                const SizedBox(height: 20),
                const Text(
                  '评分（5星制，可点半颗星，5星=10分）',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF21304C)),
                ),
                const SizedBox(height: 12),
                // 5星评分UI，支持点击整星和半星
                Row(
                  children: List.generate(5, (index) {
                    // 当前星 index (0-4)，rating 是 0.5-5.0
                    final starValue = index + 1; // 当前星的值 1-5
                    final isFullStar = rating >= starValue; // 是否需要显示满星
                    final isHalfStar = !isFullStar && rating >= starValue - 0.5; // 是否需要显示半星

                    return GestureDetector(
                      onTap: () {
                        // 点击切换：整星 -> 半星 -> 下一个整星
                        if (rating == starValue) {
                          // 如果当前点击的是已选中的整星，改为半星
                          setModalState(() => rating = starValue - 0.5);
                        } else if (rating == starValue - 0.5) {
                          // 如果当前点击的是半星，改为整星
                          setModalState(() => rating = starValue.toDouble());
                        } else {
                          // 否则设置为整星
                          setModalState(() => rating = starValue.toDouble());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          isFullStar
                              ? Icons.star
                              : isHalfStar
                                  ? Icons.star_half
                                  : Icons.star_border,
                          size: 32,
                          color: const Color(0xFFB77718),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // 显示当前评分对应的分数
                Text(
                  '当前评分：${rating.toStringAsFixed(1)} 星（${(rating * 2).toStringAsFixed(0)} 分）',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A8)),
                ),
                const SizedBox(height: 20),
                const Text(
                  '评价内容（选填）',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF21304C)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '分享您的购物体验...',
                    hintStyle: const TextStyle(color: Color(0xFF8B95A8)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              '取消',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF56657D)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => _submitEvaluate(rating, commentController.text, () => Navigator.pop(context)),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4A14A), Color(0xFFB77718)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              '提交评价',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitEvaluate(double rating, String comment, VoidCallback onClose) async {
    try {
      final token = await _http.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录'), backgroundColor: Colors.red),
        );
        return;
      }

      final response = await _http.post(ApiConfig.evaluateSubmit, data: {
        'username': token,
        'goodsId': widget.goodsId,
        'merchant': _goods!.merchant,
        'score': rating * 2,  // 5颗心=10分，评分乘以2转换
        'content': comment,
      });

      if (response.data['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('评价提交成功'), backgroundColor: Color(0xFF4CAF50)),
        );
        onClose();
        // 重新加载商品详情以显示新评价
        _loadGoodsDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? '评价提交失败'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评价提交失败: $e'), backgroundColor: Colors.red),
      );
    }
  }
  bool get _isPremiumGoods => _goods != null && _goods!.star > 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goods == null
              ? const Center(child: Text('商品不存在'))
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(child: _buildHeroSection()),
                    SliverToBoxAdapter(child: _buildContentGrid()),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: const Color(0xFFF6F1E7),
      foregroundColor: const Color(0xFF1F304E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.share, size: 16, color: Color(0xFF8C96A9)),
              SizedBox(width: 4),
              Text('分享', style: TextStyle(fontSize: 12, color: Color(0xFF8C96A9))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片预览区
          Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF192338), Color(0xFF293B5D), Color(0xFFD5B06F)],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: _goods!.src.isNotEmpty
                      ? Image.network(
                          _goods!.src,
                          width: double.infinity,
                          height: 320,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 320,
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: double.infinity,
                              height: 320,
                              child: Container(
                                color: const Color(0xFFF5F5F5),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                            );
                          },
                        )
                      : const Center(child: Icon(Icons.image, size: 64, color: Colors.white54)),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'CURATED ITEM',
                      style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 商品信息面板
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFEA).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '精品商品 / 一对一咨询',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9D6D22), letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 12),
                // 标题
                Text(
                  _description.productName.isNotEmpty ? _description.productName : _goods!.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F304E),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // 副标题
                Text(
                  '由 ${_goods!.merchant} 发布，支持进入专属会话立即咨询。',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF7D899D), height: 1.6),
                ),
                const SizedBox(height: 20),
                // 价格卡片
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B2943), Color(0xFF2F4670)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '专属咨询价',
                              style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 2),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '¥',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  _goods!.price.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isPremiumGoods)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Text(
                            '精品臻选',
                            style: TextStyle(fontSize: 11, color: Colors.white, letterSpacing: 1),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 元数据网格
                _buildMetaGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetaItem('商家', _goods!.merchant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetaItem('发布时间', _formatDate(_goods!.date)),
              ),
            ],
          ),
          if (_description.brand.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetaItem('品牌', _description.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetaItem('品名', _description.productName),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8B95A8)),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F304E)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 商品亮点卡片
          _buildNarrativeCard(),
          const SizedBox(height: 16),
          // 商品信息卡片
          _buildStructureCard(),
          const SizedBox(height: 16),
          // 评价卡片
          _buildEvaluateCard(),
        ],
      ),
    );
  }

  Widget _buildNarrativeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(fontSize: 11, color: Color(0xFFA58A56), letterSpacing: 3),
          ),
          const SizedBox(height: 8),
          const Text(
            '商品亮点',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F304E)),
          ),
          const SizedBox(height: 16),
          // 评分横幅
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2943), Color(0xFFB77718)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('综合评分', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (_goods!.star > 0) ...[
                            // 显示5颗星
                            ...List.generate(5, (index) {
                              final starValue = index + 1;
                              final ratingStar = _goods!.star / 2;  // 分数转成心数
                              final isFullStar = ratingStar >= starValue;
                              final isHalfStar = !isFullStar && ratingStar >= starValue - 0.5;
                              return Icon(
                                isFullStar ? Icons.star : (isHalfStar ? Icons.star_half : Icons.star_border),
                                size: 20,
                                color: Colors.white,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${_goods!.star.toStringAsFixed(0)}分',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ] else
                            const Text('暂无评分', style: TextStyle(fontSize: 18, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isPremiumGoods)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('精品臻选', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 产品特点
          if (_description.features.isNotEmpty) ...[
            _buildSectionTitle('产品特点'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _description.features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5B06F).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f, style: const TextStyle(fontSize: 13, color: Color(0xFF99681F))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          // 使用场景
          if (_description.scenes.isNotEmpty) ...[
            _buildSectionTitle('使用场景'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _description.scenes
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F304E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF43516B))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          // 备注说明
          if (_description.remark.isNotEmpty) ...[
            _buildSectionTitle('备注说明'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _description.remark,
                style: const TextStyle(fontSize: 14, color: Color(0xFF43516B), height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // 纯文本描述（备用）
          if (!_description.hasContent && _goods!.description.isNotEmpty) ...[
            _buildSectionTitle('商品说明'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _goods!.description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF43516B), height: 1.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStructureCard() {
    final hasContent = _description.productPrices.isNotEmpty || _description.specifications.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STRUCTURED VIEW',
            style: TextStyle(fontSize: 11, color: Color(0xFFA58A56), letterSpacing: 3),
          ),
          const SizedBox(height: 8),
          const Text(
            '商品信息',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F304E)),
          ),
          const SizedBox(height: 16),
          // 价格方案
          if (_description.productPrices.isNotEmpty) ...[
            _buildSectionTitle('价格方案'),
            const SizedBox(height: 10),
            ..._description.productPrices.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name.isEmpty ? '方案' : p.name, style: const TextStyle(color: Color(0xFF8592A7))),
                      Text('¥${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F304E))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          // 规格参数
          if (_description.specifications.isNotEmpty) ...[
            _buildSectionTitle('规格参数'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: _description.specifications
                    .asMap()
                    .entries
                    .map((entry) => Column(
                          children: [
                            if (entry.key > 0)
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.value['key'] ?? '', style: const TextStyle(color: Color(0xFF8592A7))),
                                  Text(entry.value['value'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F304E))),
                                ],
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  '当前商品暂无结构化描述信息。',
                  style: TextStyle(color: Color(0xFF7B8699)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvaluateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVALUATIONS',
                    style: TextStyle(fontSize: 11, color: Color(0xFFA58A56), letterSpacing: 3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '商品评价',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F304E)),
                  ),
                ],
              ),
              if (_canEvaluate)
                GestureDetector(
                  onTap: _showEvaluateDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A14A), Color(0xFFB77718)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '写评价',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 评价列表
          if (_evaluateList.isNotEmpty)
            ..._evaluateList.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.username.isEmpty ? '匿名用户' : e.username,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F304E)),
                            ),
                          ),
                          Row(
                            children: [
                              // 显示5颗星（可点半颗）
                              ...List.generate(5, (index) {
                                final starValue = index + 1;
                                final ratingStar = e.rating / 2;  // 分数转成心数
                                final isFullStar = ratingStar >= starValue;
                                final isHalfStar = !isFullStar && ratingStar >= starValue - 0.5;
                                return Icon(
                                  isFullStar ? Icons.star : (isHalfStar ? Icons.star_half : Icons.star_border),
                                  size: 16,
                                  color: const Color(0xFFB77718),
                                );
                              }),
                              const SizedBox(width: 4),
                              Text(
                                '${e.rating.toStringAsFixed(0)}分',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB77718)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.time.isNotEmpty ? _formatDate(e.time) : '',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8A97AB)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.comment.isEmpty ? '该用户未留下评价内容' : e.comment,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF56657D), height: 1.5),
                      ),
                    ],
                  ),
                ))
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _canEvaluate ? '当前商品还没有评价，快来成为第一个评价的人吧。' : '当前商品还没有评价。',
                  style: const TextStyle(color: Color(0xFF7B8699)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF21304C)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 继续逛逛按钮
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFF20314D).withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text(
                      '继续逛逛',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF20314D)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 立即咨询按钮
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _isSelfGoods ? null : _contactMerchant,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isSelfGoods
                          ? [const Color(0xFFB8BECb), const Color(0xFF9097A8)]
                          : [const Color(0xFFD4A14A), const Color(0xFFB77718)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: _isSelfGoods
                        ? []
                        : [
                            BoxShadow(color: const Color(0xFFB77718).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      _isSelfGoods ? '不能咨询自己' : '立即咨询',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
