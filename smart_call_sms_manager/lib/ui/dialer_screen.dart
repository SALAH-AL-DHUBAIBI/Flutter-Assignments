import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/dialer_controller.dart';

class DialerScreen extends StatelessWidget {
  const DialerScreen({super.key});

  Widget _buildKey(String val, {String? sub, required DialerController controller}) {
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
            color: Colors.grey.withOpacity(0.08),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Colors.black87)),
              if (sub != null && sub.isNotEmpty) 
                Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[600], letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DialerController controller = Get.put(DialerController());
    
    // Make system bars visible and dark
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height to adapt layout
          final height = constraints.maxHeight;
          final isSmallScreen = height < 700;
          
          return Column(
            children: [
              // Flexible top space
              const Spacer(flex: 2),
              
              // Display Area
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                // Removed fixed height to prevent overflow
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.contactName != null) 
                      Text(
                        controller.contactName!, 
                        style: TextStyle(fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (controller.number.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: isSmallScreen ? 0 : 4.0),
                        child: Text(
                          controller.number,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28, 
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              )),
              
              const Spacer(flex: 1),
              
              // Keypad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Row(children: [
                      _buildKey("1", sub: "", controller: controller), 
                      _buildKey("2", sub: "ABC", controller: controller), 
                      _buildKey("3", sub: "DEF", controller: controller)
                    ]),
                    SizedBox(height: isSmallScreen ? 4 : 8), // Tighter spacing
                    Row(children: [
                      _buildKey("4", sub: "GHI", controller: controller), 
                      _buildKey("5", sub: "JKL", controller: controller), 
                      _buildKey("6", sub: "MNO", controller: controller)
                    ]),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Row(children: [
                      _buildKey("7", sub: "PQRS", controller: controller), 
                      _buildKey("8", sub: "TUV", controller: controller), 
                      _buildKey("9", sub: "WXYZ", controller: controller)
                    ]),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Row(children: [
                       Expanded(child: InkWell(
                         onLongPress: (){ HapticFeedback.selectionClick(); controller.onKeyPress("*"); }, 
                         onTap: (){ HapticFeedback.lightImpact(); controller.onKeyPress("*"); }, 
                         child: Container(
                           height: 72,
                           alignment: Alignment.center,
                           child: const Text("*", style: TextStyle(fontSize: 36, color: Colors.black54))
                         )
                       )),
                       _buildKey("0", sub: "+", controller: controller),
                       Expanded(child: InkWell(
                         onLongPress: (){ HapticFeedback.selectionClick(); controller.onKeyPress("#"); }, 
                         onTap: (){ HapticFeedback.lightImpact(); controller.onKeyPress("#"); }, 
                         child: Container(
                           height: 72,
                           alignment: Alignment.center,
                           child: const Text("#", style: TextStyle(fontSize: 36, color: Colors.black54))
                         )
                       )),
                    ]),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 16 : 24), // Reduced bottom gap
              
              // Actions
              Padding(
                padding: EdgeInsets.only(bottom: isSmallScreen ? 16.0 : 32.0), // Reduced bottom padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 70), // Spacer
                    FloatingActionButton.large(
                      onPressed: controller.makeCall,
                      backgroundColor: Colors.green[600],
                      elevation: 2,
                      child: const Icon(Icons.phone, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Obx(() => controller.number.isNotEmpty
                        ? IconButton(
                            onPressed: controller.onBackspace,
                            icon: const Icon(Icons.backspace_outlined, color: Colors.black54, size: 26),
                            tooltip: 'Delete',
                          )
                        : const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
