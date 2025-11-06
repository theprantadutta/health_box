# HealthBox Material 3 Design System Guide

## Overview

HealthBox uses a comprehensive Material 3 design system that ensures consistency, accessibility, and a professional medical aesthetic across all screens and components.

## Design Philosophy

- **Medical Blue Palette**: Trust and professionalism with soft, calming colors
- **Minimal & Clean**: Low elevation, subtle shadows, rounded corners
- **Accessibility First**: WCAG AA compliant contrast ratios, text scaling support
- **Smooth Interactions**: 150-350ms animations with easeOutCubic curves
- **Offline-First**: Visual feedback for sync states, graceful degradation

---

## 1. Design Tokens

All design tokens are defined in `lib/shared/theme/design_system.dart`.

### Colors

#### Primary Brand Colors
```dart
HealthBoxDesignSystem.primaryBlue        // #2563EB - Main brand color
HealthBoxDesignSystem.primaryBlueLight   // #3B82F6 - Light variant
HealthBoxDesignSystem.primaryBlueDark    // #1D4ED8 - Dark variant
```

#### Secondary Accent Colors
```dart
HealthBoxDesignSystem.accentPurple       // #8B5CF6
HealthBoxDesignSystem.accentGreen        // #10B981
HealthBoxDesignSystem.accentOrange       // #F97316
HealthBoxDesignSystem.accentPink         // #EC4899
HealthBoxDesignSystem.accentCyan         // #06B6D4
```

#### Semantic Colors
```dart
HealthBoxDesignSystem.successColor       // #059669
HealthBoxDesignSystem.warningColor       // #D97706
HealthBoxDesignSystem.errorColor         // #DC2626
```

#### Neutral Palette
```dart
HealthBoxDesignSystem.neutral50  // #FAFAFA - Lightest
HealthBoxDesignSystem.neutral100 // #F5F5F5
HealthBoxDesignSystem.neutral200 // #E5E5E5
HealthBoxDesignSystem.neutral300 // #D4D4D4
HealthBoxDesignSystem.neutral400 // #A3A3A3
HealthBoxDesignSystem.neutral500 // #737373 - Medium
HealthBoxDesignSystem.neutral600 // #525252
HealthBoxDesignSystem.neutral700 // #404040
HealthBoxDesignSystem.neutral800 // #262626
HealthBoxDesignSystem.neutral900 // #171717 - Darkest
```

#### Surface Colors
```dart
HealthBoxDesignSystem.surfacePrimary     // White
HealthBoxDesignSystem.surfaceSecondary   // #FEFEFE
HealthBoxDesignSystem.surfaceTertiary    // #F8FAFC
```

#### Text Colors
```dart
HealthBoxDesignSystem.textPrimary        // neutral900 - Main text
HealthBoxDesignSystem.textSecondary      // neutral600 - Secondary text
HealthBoxDesignSystem.textTertiary       // neutral500 - Tertiary text
HealthBoxDesignSystem.textDisabled       // neutral400 - Disabled text
```

### Typography

#### Font Sizes
```dart
textSizeXs   = 12.0   // Small labels, captions
textSizeSm   = 14.0   // Body small, secondary text
textSizeBase = 16.0   // Body text (default)
textSizeLg   = 18.0   // Large body, small headings
textSizeXl   = 20.0   // Headings
textSize2xl  = 24.0   // Large headings
textSize3xl  = 30.0   // Page titles
textSize4xl  = 36.0   // Display titles
```

#### Line Heights
```dart
lineHeightTight   = 1.25   // Display text
lineHeightSnug    = 1.375  // Headings
lineHeightNormal  = 1.5    // Body text (default)
lineHeightRelaxed = 1.625  // Long-form content
lineHeightLoose   = 2.0    // Very spacious
```

#### Font Weights
```dart
fontWeightLight     = FontWeight.w300  // 300
fontWeightNormal    = FontWeight.w400  // 400 (default)
fontWeightMedium    = FontWeight.w500  // 500
fontWeightSemiBold  = FontWeight.w600  // 600
fontWeightBold      = FontWeight.w700  // 700
fontWeightExtraBold = FontWeight.w800  // 800
```

### Spacing

Based on 4px grid system:

```dart
spacing1  = 4.0    // 4px
spacing2  = 8.0    // 8px
spacing3  = 12.0   // 12px
spacing4  = 16.0   // 16px (default padding)
spacing5  = 20.0   // 20px
spacing6  = 24.0   // 24px
spacing8  = 32.0   // 32px
spacing10 = 40.0   // 40px
spacing12 = 48.0   // 48px
spacing16 = 64.0   // 64px
spacing20 = 80.0   // 80px
spacing24 = 96.0   // 96px
```

### Border Radius

```dart
radiusNone = 0.0
radiusSm   = 4.0    // Subtle rounding
radiusBase = 8.0    // Default for buttons, inputs
radiusMd   = 12.0   // Cards, containers
radiusLg   = 16.0   // Large cards
radiusXl   = 20.0   // Extra large
radius2xl  = 24.0   // Dialogs
radius3xl  = 28.0   // Modals
radiusFull = 9999.0 // Circular (pills, avatars)
```

### Shadows & Elevation

```dart
shadowXs     // Subtle elevation (1px drop)
shadowSm     // Low elevation (buttons, chips)
shadowBase   // Default cards
shadowMd     // Raised cards, popovers
shadowLg     // Modals, dialogs
shadowXl     // Maximum elevation
```

**Colored Shadows** for gradient elements:
```dart
HealthBoxDesignSystem.coloredShadow(color, opacity: 0.3)
HealthBoxDesignSystem.softGlow(color)
HealthBoxDesignSystem.strongGlow(color)
```

### Animation Tokens

#### Durations
```dart
durationFast   = 150ms  // Micro-interactions
durationBase   = 250ms  // Default transitions
durationSlow   = 350ms  // Complex animations
durationSlower = 500ms  // Page transitions
```

#### Curves
```dart
curveEaseOut     // Most interactions (default)
curveEaseInOut   // Smooth transitions
curveBounce      // Success feedback
curveElastic     // Playful interactions
```

---

## 2. Component Tokens

### Buttons

```dart
buttonHeightSm   = 32.0  // Small buttons
buttonHeightBase = 40.0  // Default buttons
buttonHeightLg   = 48.0  // Large CTAs
```

**Padding**: `horizontal: 16-32px`, `vertical: 8-16px` based on size

### Input Fields

```dart
inputHeightSm   = 32.0
inputHeightBase = 40.0
inputHeightLg   = 48.0
```

**Border**: 1px solid, 2px on focus
**Fill**: Light surface background with transparency

### Cards

```dart
cardPaddingSm   = spacing3 (12px)
cardPaddingBase = spacing4 (16px)
cardPaddingLg   = spacing6 (24px)
```

**Elevation**: `low` (default), `medium`, `high`, `floating`

---

## 3. Medical-Themed Gradients

HealthBox includes pre-defined gradients for different medical record types:

### Record Type Gradients

```dart
medicationGradient       // Blue → Cyan
prescriptionGradient     // Purple → Light Purple
labReportGradient        // Orange → Yellow
vaccinationGradient      // Green → Light Green
allergyGradient          // Red → Light Red
chronicConditionGradient // Indigo → Purple
surgicalGradient         // Cyan → Dark Cyan
radiologyGradient        // Purple → Indigo
pathologyGradient        // Amber → Orange
dentalGradient           // Cyan → Blue
mentalHealthGradient     // Light Purple → Purple
```

**Usage**:
```dart
final gradient = HealthBoxDesignSystem.getRecordTypeGradient('medication');
```

### Status Gradients

```dart
successGradient  // Green gradient for success states
warningGradient  // Amber gradient for warnings
errorGradient    // Red gradient for errors
infoGradient     // Blue gradient for information
```

### Background Gradients

```dart
subtleBackgroundGradient  // Very subtle for backgrounds
boldBackgroundGradient    // Blue → Purple → Pink
meshBackgroundGradient    // Multi-color mesh (splash screens)
```

---

## 4. Core Components

All components are located in `lib/shared/widgets/`.

### HealthButton (`gradient_button.dart`)

**Stateful button with animations, haptics, and medical themes.**

```dart
HealthButton(
  onPressed: () {},
  style: HealthButtonStyle.primary,  // primary, success, warning, error
  size: HealthButtonSize.medium,     // small, medium, large
  medicalTheme: MedicalButtonTheme.primary,  // Optional theme
  child: Text('Save Record'),

  // Optional enhancements
  gradient: HealthBoxDesignSystem.medicalBlue,
  elevation: CardElevation.low,
  enableHoverEffect: true,
  enablePressEffect: true,
  enableHaptics: true,
  useGradientShadow: true,

  // Premium effects
  shimmerEffect: false,
  pulseEffect: false,
  glowEffect: false,
)
```

**Styles**:
- `primary`: Medical blue gradient
- `success`: Green gradient
- `warning`: Orange gradient
- `error`: Red gradient

### GradientChip (`gradient_chip.dart`)

**Chips for tags, filters, and categories.**

```dart
GradientChip(
  label: 'Medication',
  gradient: HealthBoxDesignSystem.medicationGradient,
  selected: true,
  onDeleted: () {},
  onTap: () {},
  icon: Icons.medication,
)
```

**Variants**:
- `GradientFilterChip`: For filtering lists
- `TagChip`: For record categorization

### ModernTextField (`modern_text_field.dart`)

**Text input with gradient focus borders.**

```dart
ModernTextField(
  labelText: 'Medication Name',
  hintText: 'Enter medication name',
  controller: _controller,
  focusGradient: HealthBoxDesignSystem.medicalBlue,
  useGradientBorder: true,
  prefixIcon: Icon(Icons.medication),
  keyboardType: TextInputType.text,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

### ModernCard (`modern_card.dart`)

**Container with elevation, gradients, and interactions.**

```dart
ModernCard(
  elevation: CardElevation.low,
  medicalTheme: MedicalCardTheme.primary,
  onTap: () {},
  enableHoverEffect: true,
  useGradientShadow: true,
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card content'),
    ],
  ),

  // Premium effects
  gradientBorder: false,
  enableGlassmorphism: false,
  shimmerEffect: false,
)
```

---

## 5. Layout Guidelines

### Dashboard Screen

**Structure**:
- App Bar: 64dp height, centered title
- Body: Vertical scroll with padding `spacing4` (16px)
- Cards: `radiusLg` (16px), `elevation: low`
- Spacing between cards: `spacing4` (16px)

**Components**:
- Quick Actions: 2-column grid of gradient buttons
- Recent Activity: List of cards with timeline
- Upcoming Reminders: Compact cards with badges

### Medical Records List

**Structure**:
- App Bar with search icon
- Floating Action Button (bottom-right)
- List items: `ModernCard` with `onTap`
- Item height: 96-120px

**Card Content**:
- Leading: Record type icon with gradient background
- Title: Bold, `textSizeLg`
- Subtitle: Secondary text, `textSizeSm`
- Trailing: Date or arrow icon

### Record Detail Screen

**Structure**:
- App Bar with back button, title, edit/delete actions
- Hero transition from list card
- Sections with dividers
- Bottom action bar (if needed)

**Content Sections**:
- Header card with gradient (record type)
- Information cards: white background, `radiusMd`
- Attachments grid: 2-3 columns
- Tags: Wrap of `GradientChip`

### Form Screens

**Structure**:
- Scrollable body with padding `spacing4`
- Input fields: `ModernTextField` with `spacing3` vertical spacing
- Sections: Group related fields with headers
- Bottom: Sticky action buttons

**Validation**:
- Inline error messages below fields
- Error color: `HealthBoxDesignSystem.errorColor`
- Success color: `HealthBoxDesignSystem.successColor`

### Settings Screen

**Structure**:
- List of sections with headers
- Items: `ListTile` or custom card
- Dividers: Subtle, 1px, `neutral200`

---

## 6. Accessibility Guidelines

### Contrast Ratios

All color combinations meet **WCAG AA standards** (4.5:1 for normal text, 3:1 for large text).

- Primary text on white: `neutral900` (17:1)
- Secondary text on white: `neutral600` (7:1)
- Primary button: White text on blue (4.5:1+)

### Text Scaling

The app supports **text scaling from 0.8x to 1.3x**:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(scale.clamp(0.8, 1.3)),
  ),
  child: child,
)
```

### Focus Indicators

All interactive elements have **visible focus rings**:
- Default: 2px border with primary color
- Keyboard navigation: High-contrast outline
- Touch targets: Minimum 48x48dp

### Semantics

All custom widgets include proper semantics:

```dart
Semantics(
  button: true,
  enabled: true,
  label: 'Save record',
  hint: 'Tap to save this medical record',
  child: widget,
)
```

---

## 7. Responsive Design

### Breakpoints

```dart
mobileMaxWidth  = 480px   // Phone portrait
tabletMaxWidth  = 1024px  // Tablet portrait/landscape
desktopMinWidth = 1025px  // Desktop and above
```

### Adaptive Components

Components automatically adjust padding, radius, and size:

```dart
final padding = AppTheme.getResponsivePadding(context);
// Mobile: 16px, Tablet: 24px, Desktop: 32px

final radius = AppTheme.getResponsiveCardRadius(context);
// Mobile: 12px, Tablet: 16px, Desktop: 20px
```

---

## 8. Dark Mode

HealthBox fully supports **dark mode** with automatically adjusted colors:

### Color Adjustments

- **Surfaces**: Dark slate colors (`#0F172A`, `#1E293B`)
- **Text**: Light gray (`neutral50`, `neutral300`)
- **Primary**: Lighter blue for better contrast
- **Shadows**: Increased opacity for visibility

### Gradient Adjustments

Dark mode uses darker gradient variants:

```dart
// Light mode
HealthBoxDesignSystem.medicalBlue

// Dark mode
HealthBoxDesignSystem.darkMedicalBlue
```

### Theme Switching

```dart
final themeMode = ref.watch(themeModeProvider);
// ThemeMode.light, ThemeMode.dark, ThemeMode.system
```

---

## 9. Usage Examples

### Building a Medical Record Card

```dart
ModernCard(
  elevation: CardElevation.low,
  onTap: () => goToRecordDetail(record.id),
  child: Row(
    children: [
      // Gradient icon
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: HealthBoxDesignSystem.getRecordTypeGradient(record.type),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(getRecordIcon(record.type), color: Colors.white),
      ),
      SizedBox(width: HealthBoxDesignSystem.spacing3),

      // Content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing1),
            Text(
              record.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HealthBoxDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),

      // Trailing
      Icon(Icons.chevron_right, color: HealthBoxDesignSystem.neutral400),
    ],
  ),
)
```

### Building a Form with Validation

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      ModernTextField(
        labelText: 'Medication Name *',
        controller: _nameController,
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      ),
      SizedBox(height: HealthBoxDesignSystem.spacing3),

      ModernTextField(
        labelText: 'Dosage',
        controller: _dosageController,
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: HealthBoxDesignSystem.spacing6),

      HealthButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveMedication();
          }
        },
        style: HealthButtonStyle.primary,
        size: HealthButtonSize.large,
        child: Text('Save Medication'),
      ),
    ],
  ),
)
```

### Building a Filter Chip Bar

```dart
Wrap(
  spacing: HealthBoxDesignSystem.spacing2,
  runSpacing: HealthBoxDesignSystem.spacing2,
  children: [
    GradientFilterChip(
      label: 'All',
      selected: selectedFilter == 'all',
      onSelected: () => setFilter('all'),
    ),
    GradientFilterChip(
      label: 'Medications',
      selected: selectedFilter == 'medication',
      onSelected: () => setFilter('medication'),
      selectedGradient: HealthBoxDesignSystem.medicationGradient,
      icon: Icons.medication,
    ),
    GradientFilterChip(
      label: 'Lab Reports',
      selected: selectedFilter == 'lab_report',
      onSelected: () => setFilter('lab_report'),
      selectedGradient: HealthBoxDesignSystem.labReportGradient,
      icon: Icons.science,
    ),
  ],
)
```

---

## 10. Best Practices

### DO ✅

- **Use design tokens** instead of hardcoded values
- **Follow spacing system** (multiples of 4px)
- **Apply semantic colors** (success, warning, error)
- **Use appropriate elevation** (low for most cards)
- **Maintain consistent padding** (`spacing4` for most content)
- **Apply proper text styles** from theme
- **Support both light and dark modes**
- **Test with text scaling** (0.8x - 1.3x)
- **Use Material 3 components** from theme
- **Apply appropriate border radius** based on component

### DON'T ❌

- **Don't use inline colors** - always reference design system
- **Don't hardcode spacing** - use spacing tokens
- **Don't mix elevation styles** - stay consistent
- **Don't forget dark mode** - test both themes
- **Don't ignore accessibility** - check contrast and focus
- **Don't create custom components** without theme support
- **Don't use arbitrary radius values** - use token scale
- **Don't nest cards** without considering elevation
- **Don't forget animations** - use duration tokens
- **Don't ignore responsive design** - test multiple sizes

---

## 11. Testing Checklist

When implementing new screens or components:

- [ ] Uses design tokens (no hardcoded colors/spacing)
- [ ] Follows Material 3 guidelines
- [ ] Works in both light and dark mode
- [ ] Supports text scaling (0.8x - 1.3x)
- [ ] Has proper focus indicators
- [ ] Includes semantic labels
- [ ] Animates smoothly (150-350ms)
- [ ] Uses appropriate elevation
- [ ] Maintains consistent padding
- [ ] Has proper contrast ratios (WCAG AA)
- [ ] Responsive on mobile, tablet, desktop
- [ ] Uses gradient shadows for gradient elements
- [ ] Includes haptic feedback (where appropriate)
- [ ] Has loading and error states
- [ ] Integrates with Riverpod (no UI logic in widgets)

---

## Resources

- **Design System**: `lib/shared/theme/design_system.dart`
- **Theme Configuration**: `lib/shared/theme/app_theme.dart`
- **Material 3 Theme**: `lib/shared/theme/material3_theme.dart`
- **Core Components**: `lib/shared/widgets/`
- **Main App Entry**: `lib/main.dart`

---

## Quick Reference Card

| Token | Value | Usage |
|-------|-------|-------|
| Primary Color | `#2563EB` | Buttons, links, accents |
| Success Color | `#059669` | Success states, confirmations |
| Error Color | `#DC2626` | Errors, warnings, destructive actions |
| Body Text | `16px` / `neutral900` | Default text size and color |
| Heading Large | `24px` / `bold` | Page titles |
| Spacing | `16px` | Default padding between elements |
| Card Radius | `12-16px` | Default card border radius |
| Button Height | `40px` | Default button height |
| Input Height | `40px` | Default text field height |
| Animation | `250ms` / `easeOut` | Default transition |
| Shadow | `low` | Default card elevation |

---

**Version**: 1.0
**Last Updated**: 2025-01-06
**Maintained by**: HealthBox Design Team
