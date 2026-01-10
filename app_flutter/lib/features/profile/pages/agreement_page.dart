import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/agreement_service.dart';

/// 协议类型
enum AgreementType {
  userAgreement('user_agreement', '用户协议'),
  privacyPolicy('privacy_policy', '隐私政策'),
  aboutUs('about_us', '关于我们');

  final String value;
  final String label;
  const AgreementType(this.value, this.label);
}

/// 协议/关于我们页面 - Aurora UI + Glassmorphism
class AgreementPage extends StatefulWidget {
  final AgreementType type;

  const AgreementPage({super.key, required this.type});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  final AgreementService _service = AgreementService();
  Agreement? _agreement;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAgreement();
  }

  Future<void> _loadAgreement() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final agreement = switch (widget.type) {
        AgreementType.userAgreement => await _service.getUserAgreement(),
        AgreementType.privacyPolicy => await _service.getPrivacyPolicy(),
        AgreementType.aboutUs => await _service.getAboutUs(),
      };

      setState(() {
        _agreement = agreement;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimaryAdaptive(context),
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _agreement?.title ?? widget.type.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isDark = context.isDarkMode;
    if (_loading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                '加载中...',
                style: TextStyle(color: AppColors.textSecondaryAdaptive(context)),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/illustrations/error_network.svg',
                width: 160,
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHintAdaptive(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _loadAgreement,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_agreement == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/illustrations/no_search_result.svg',
              width: 140,
              height: 105,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无内容',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_agreement!.version.isNotEmpty ||
                _agreement!.updateTime != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_agreement!.version.isNotEmpty)
                      Text(
                        '版本 ${_agreement!.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHintAdaptive(context),
                        ),
                      ),
                    if (_agreement!.version.isNotEmpty &&
                        _agreement!.updateTime != null)
                      Text(
                        ' · ',
                        style: TextStyle(color: AppColors.textHintAdaptive(context)),
                      ),
                    if (_agreement!.updateTime != null)
                      Text(
                        '更新于 ${_formatDate(_agreement!.updateTime!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHintAdaptive(context),
                        ),
                      ),
                  ],
                ),
              ),
            HtmlWidget(
              _agreement!.content,
              textStyle: TextStyle(
                fontSize: 14,
                height: 1.8,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Aurora 背景
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkBackground, const Color(0xFF1A1A22), const Color(0xFF151518)]
              : [const Color(0xFFF8F6F3), const Color(0xFFF0EDE8), const Color(0xFFE8E4DD)],
        ),
      ),
      child: CustomPaint(painter: _AuroraPainter(isDark: isDark), size: Size.infinite),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final bool isDark;
  _AuroraPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.1),
      size.width * 0.35,
      paint,
    );
    paint.color = AppColors.accent.withValues(alpha: isDark ? 0.1 : 0.06);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.4),
      size.width * 0.3,
      paint,
    );
    paint.color = AppColors.tertiary.withValues(alpha: isDark ? 0.08 : 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.85),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.isDark != isDark;
}
