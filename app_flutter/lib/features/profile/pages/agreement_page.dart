import 'package:flutter/material.dart';
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

/// 协议/关于我们页面
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _agreement?.title ?? widget.type.label,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.textHint)),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadAgreement, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_agreement == null) {
      return const Center(child: Text('暂无内容'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本和更新时间
          if (_agreement!.version.isNotEmpty || _agreement!.updateTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  if (_agreement!.version.isNotEmpty)
                    Text(
                      '版本 ${_agreement!.version}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  if (_agreement!.version.isNotEmpty &&
                      _agreement!.updateTime != null)
                    const Text(
                      ' · ',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  if (_agreement!.updateTime != null)
                    Text(
                      '更新于 ${_formatDate(_agreement!.updateTime!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                ],
              ),
            ),
          // HTML 内容
          HtmlWidget(
            _agreement!.content,
            textStyle: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
