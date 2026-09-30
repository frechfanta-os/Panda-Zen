import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assets/environment_assets.dart';
import '../../assets/ui_assets.dart';
import '../../audio/audio_manager.dart';
import '../../game/providers/progression_provider.dart';
import '../../services/localization_service.dart';
import 'package:panda_zen/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late double _musicVol;
  late double _sfxVol;

  @override
  void initState() {
    super.initState();
    final audio = AudioManager();
    _musicEnabled = audio.music.isEnabled;
    _sfxEnabled = audio.sfx.isEnabled;
    _musicVol = audio.music.volume;
    _sfxVol = audio.sfx.volume;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final audio = AudioManager();
    final save = ref.watch(saveServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(EnvironmentAssets.world1BambooForest, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          UiAssets.getSprite(UiSprite.btnBack, locale),
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.settings,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Settings Container
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Music
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.music,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              Switch(
                                value: _musicEnabled,
                                activeTrackColor: const Color(0xFF4CAF50),
                                onChanged: (val) {
                                  setState(() => _musicEnabled = val);
                                  audio.music.setEnabled(val);
                                  save.setMusicEnabled(val);
                                },
                              ),
                            ],
                          ),
                          Slider(
                            value: _musicVol,
                            activeColor: const Color(0xFF4CAF50),
                            onChanged: _musicEnabled
                                ? (val) {
                                    setState(() => _musicVol = val);
                                    audio.music.setVolume(val);
                                    save.setMusicVolume(val);
                                  }
                                : null,
                          ),
                          const Divider(),

                          // SFX
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.sound,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              Switch(
                                value: _sfxEnabled,
                                activeTrackColor: const Color(0xFF4CAF50),
                                onChanged: (val) {
                                  setState(() => _sfxEnabled = val);
                                  audio.sfx.isEnabled = val;
                                  save.setSfxEnabled(val);
                                },
                              ),
                            ],
                          ),
                          Slider(
                            value: _sfxVol,
                            activeColor: const Color(0xFF4CAF50),
                            onChanged: _sfxEnabled
                                ? (val) {
                                    setState(() => _sfxVol = val);
                                    audio.sfx.volume = val;
                                    save.setSfxVolume(val);
                                  }
                                : null,
                          ),
                          const Divider(),

                          // Language
                          Text(
                            l10n.language,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: Text(l10n.english),
                                selected: locale.languageCode == 'en',
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text(l10n.french),
                                selected: locale.languageCode == 'fr',
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
                                  }
                                },
                              ),
                            ],
                          ),
                          const Divider(),

                          // How to play
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.help_outline, color: Color(0xFF3E2723)),
                              title: Text(
                                l10n.howToPlay,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showHowToPlayDialog(context, l10n),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.howToPlay,
          style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.howToPlayText,
          style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
          ),
        ],
      ),
    );
  }
}
