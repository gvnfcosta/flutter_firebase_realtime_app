import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

class CustomProgessIndicator extends StatelessWidget {
  const CustomProgessIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: Colors.white24,
              color: AppColors.foregroundIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBarData extends StatelessWidget {
  const AppBarData({
    super.key,
    required this.aboveText,
    required this.belowText,
  });

  final String aboveText;
  final String belowText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aboveText,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 20),
        if (belowText.isNotEmpty)
          Text(belowText.toUpperCase(), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
