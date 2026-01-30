import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/dialer_controller.dart';

class DialerScreen extends StatelessWidget {
  const DialerScreen({super.key});

  /// Builds a single dialer key (number + optional letters)
  Widget _buildKey(
    BuildContext context,
    String val, {
    String? sub,
    required DialerController controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.onKeyPress(val);
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 72,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white10 : Colors.grey.withAlpha(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                val,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (sub != null && sub.isNotEmpty)
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DialerController controller = Get.put(DialerController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Match system UI with app theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxHeight < 700;

          return Column(
            children: [
              const Spacer(flex: 2),

              /// Display (Contact name + number)
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.contactName != null)
                        Text(
                          controller.contactName!,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (controller.number.isNotEmpty)
                        Padding(
                          padding:
                              EdgeInsets.only(top: isSmallScreen ? 0 : 4),
                          child: Text(
                            controller.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// Keypad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildKey(context, "1",
                            sub: "", controller: controller),
                        _buildKey(context, "2",
                            sub: "ABC", controller: controller),
                        _buildKey(context, "3",
                            sub: "DEF", controller: controller),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Row(
                      children: [
                        _buildKey(context, "4",
                            sub: "GHI", controller: controller),
                        _buildKey(context, "5",
                            sub: "JKL", controller: controller),
                        _buildKey(context, "6",
                            sub: "MNO", controller: controller),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Row(
                      children: [
                        _buildKey(context, "7",
                            sub: "PQRS", controller: controller),
                        _buildKey(context, "8",
                            sub: "TUV", controller: controller),
                        _buildKey(context, "9",
                            sub: "WXYZ", controller: controller),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Row(
                      children: [
                        _specialKey("*", controller),
                        _buildKey(context, "0",
                            sub: "+", controller: controller),
                        _specialKey("#", controller),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 16 : 24),

              /// Actions
              Padding(
                padding:
                    EdgeInsets.only(bottom: isSmallScreen ? 16 : 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 70),
                    FloatingActionButton.large(
                      onPressed: controller.makeCall,
                      backgroundColor: Colors.green[600],
                      child: const Icon(Icons.phone,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Obx(
                        () => controller.number.isNotEmpty
                            ? IconButton(
                                onPressed: controller.onBackspace,
                                icon: const Icon(
                                    Icons.backspace_outlined),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Special keys (* and #)
  Widget _specialKey(String value, DialerController controller) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.onKeyPress(value);
        },
        onLongPress: () {
          HapticFeedback.selectionClick();
          controller.onKeyPress(value);
        },
        child: Container(
          height: 72,
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}
