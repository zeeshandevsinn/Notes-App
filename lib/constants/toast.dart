import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ToastUtil {
  static void showSuccessToast(String message) {
    showOverlayNotification(
      position: NotificationPosition.bottom,
      (context) => _buildToast(
        context,
        message,
        Colors.green,
        [Color(0xFF00b09b), Color(0xFF96c93d)],
      ),
      duration: Duration(seconds: 2),
    );
  }

  static void showErrorToast(String message) {
    showOverlayNotification(
      (context) => _buildToast(
        context,
        message,
        Colors.red,
        [Color(0xFFff5f6d)],
      ),
      duration: Duration(seconds: 2),
    );
  }

  static Widget _buildToast(BuildContext context, String message,
      Color iconColor, List<Color> gradientColors) {
    return SlideDismissible(
      key: UniqueKey(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            leading: Icon(Icons.info, color: Colors.white),
            title: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
            tileColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            style: ListTileStyle.drawer,
            trailing: IconButton(
              icon: Icon(Icons.close, color: iconColor),
              onPressed: () {
                OverlaySupportEntry.of(context)?.dismiss();
              },
            ),
          ),
        ),
        color: gradientColors[0],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
