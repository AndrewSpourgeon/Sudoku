import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AvatarSettingsSheet extends StatefulWidget {
  final bool? initialValue;
  final Future<void> Function(bool) onSaved; // changed to Future for awaiting
  const AvatarSettingsSheet({
    super.key,
    required this.initialValue,
    required this.onSaved,
  });
  @override
  State<AvatarSettingsSheet> createState() => _AvatarSettingsSheetState();
}

class _AvatarSettingsSheetState extends State<AvatarSettingsSheet> {
  late bool _value;
  bool _saving = false; // saving state
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.6),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          color: const Color(0xFF2563EB), // blue icon
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Show Image on Leaderboard',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Switch.adaptive(
                          value: _value,
                          activeColor: const Color(0xFF2563EB), // blue toggle
                          onChanged: _saving
                              ? null
                              : (v) => setState(() => _value = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF374151),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF10B981,
                              ), // green save
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _saving
                                ? null
                                : () async {
                                    setState(() => _saving = true);
                                    try {
                                      await widget.onSaved(_value);
                                      if (mounted) Navigator.pop(context);
                                    } finally {
                                      if (mounted)
                                        setState(() => _saving = false);
                                    }
                                  },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_saving)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Lottie.asset(
                          'assets/lottie/loading.json',
                          repeat: true,
                          frameRate: FrameRate.max,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
