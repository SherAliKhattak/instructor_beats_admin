import 'package:flutter/material.dart';

/// Instructor Beats brand colors (matches consumer app).
class AppColors {
  AppColors._();

  static const Color background = Colors.white;
  static const Color primary = Color(0xFF255DC0);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color accent = Color(0xFF3B82F6);
  static const Color title = Color(0xFF1F2937);
  static const Color description = Color(0xFF6B7280);
  static const Color skip = Color(0xFF9CA3AF);

  static const List<Color> iconGradient = [
    Color(0xFF5B3CC6),
    Color(0xFF1D4ED8),
  ];

  static const List<Color> landingGradient = [
    Color(0xFF255DC0),
    Color(0xFF4B189B),
    Color(0xFF255DC0),
  ];

  static const Color buttonPrimaryText = Color(0xFF255DC0);
  static const Color videoCaption = Color(0xFF4B5563);

  static const Color playlistCardShadow = Color(0x1A000000);
  static const Color playlistDetails = Color(0xFF6B7280);
  static const Color playlistTagBg = Color(0xFFF3F4F6);
  static const Color playlistTagText = Color(0xFF4B5563);
  static const Color playlistTagBpmBg = Color(0xFFE2EAF7);
  static const Color playlistTagBpmText = Color(0xFF3562C1);

  static const Color infoListIconBg = Color(0xFFE2EAF7);
  static const Color infoListIconText = Color(0xFF1E40AF);
  static const Color infoListChevron = Color(0xFF9CA3AF);

  static const Color pricingCardBg = Color(0xFFF3F4F6);
  static const Color statContainerBg = Color(0xFFF8F8FC);
  static const Color statTextColor = Color(0xFF533483);
  static const Color statNumberBlue = Color(0xFF255DC0);
  static const Color statNumberPurple = Color(0xFF4B189B);
  static const Color statLabelColor = Color(0xFF6B7280);

  static const List<Color> statTracksGradient = [
    Color(0xFFF3F5FA),
    Color(0xFFE7EBF5),
  ];
  static const Color statTracksValue = Color(0xFF2E6BEB);

  static List<Color> get statPlaylistsGradient => [
        const Color(0xFF4B189B).withValues(alpha: 0.1),
        const Color(0xFF4B189B).withValues(alpha: 0.05),
      ];
  static const Color statPlaylistsValue = Color(0xFF6C3DAB);

  static List<Color> get statInstructorsGradient => [
        const Color(0xFF255DC0).withValues(alpha: 0.1),
        const Color(0xFF4B189B).withValues(alpha: 0.1),
      ];
  static const Color statInstructorsValue = Color(0xFF4C4ED6);

  static const Color annualCardBorder = Color(0xFF255DC0);
  static const List<Color> bestValueGradient = [
    Color(0xFF255DC0),
    Color(0xFF4B189B),
  ];
  static const List<Color> annualButtonGradient = [
    Color(0xFF255DC0),
    Color(0xFF4B189B),
  ];
  static const Color checkmarkCircleBg = Color(0xFFF3F4F6);
  static const Color checkmarkBlue = Color(0xFF3562C1);

  static const Color profileBadgeBg = Color(0xFFE8E0F5);
  static const Color profileBadgeBorder = Color(0xFF9B8BB8);
  static const Color profilePlanPillBg = Color(0xFFE2EAF7);
  static const Color profilePlanPillText = Color(0xFF1E40AF);
  static const Color profileStatBorder = Color(0xFFE5E7EB);

  static const Color chipBpmBg = Color(0xFF5B8DEE);
  static const Color chipEnergeticBg = Color(0xFF9B6DD2);
  static const Color chipHighEnergyBg = Color(0xFFE07B54);

  static const Color inviteBenefitsCardBg = Color(0xFFF8FAFC);
  static const Color inviteCheckmarkCircle = Color(0xFFE0E7FF);
  static const Color inviteCheckmark = Color(0xFF4F46E5);

  static const Color storageCardBg = Color(0xFFEFEFF7);
  static const Color storageCardBorder = Color(0xFFD4E0F0);
  static const Color storageProgressFilled = Color(0xFF4C5BFD);
  static const Color storageProgressFilledEnd = Color(0xFF2E38B3);
  static const Color storageProgressUnfilled = Color(0xFFE0E0E0);

  /// Inputs / pagination inactive (admin UI)
  static const Color fieldFill = Color(0xFFF3F4F6);
  static const Color fieldBorder = Color(0xFFE5E7EB);
  static const Color paginationInactive = Color(0xFFE5E7EB);
}

/// Admin shell palette (light, Instructor Beats–branded).
abstract final class DashColors {
  DashColors._();

  /// Page background behind shell.
  static const Color canvas = Color(0xFFF3F4F6);

  /// Main content background.
  static const Color surface = Colors.white;

  /// Sidebar / navigation background.
  static const Color sidebar = Colors.white;

  /// Card and table background.
  static const Color card = Colors.white;

  /// Subtle outlines for cards, tables, sidebar separators.
  static const Color border = Color(0xFFE5E7EB);

  /// Primary text (titles, labels).
  static const Color textPrimary = AppColors.title;

  /// Secondary text (descriptions, meta).
  static const Color textMuted = AppColors.description;

  /// Accent colors used sparingly in dashboards.
  static const Color green = Color(0xFF22C55E);
  static const Color blue = AppColors.primary;
  static const Color orange = Color(0xFFF59E0B);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color red = Color(0xFFEF4444);
  static const Color violet = Color(0xFF8B5CF6);
}
