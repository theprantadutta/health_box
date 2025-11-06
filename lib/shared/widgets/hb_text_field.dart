import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// ============================================================================
/// HBTextField - Standardized HealthBox Text Field
/// Material 3 text inputs with consistent styling and validation
/// ============================================================================

class HBTextField extends StatefulWidget {
  const HBTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.variant = HBTextFieldVariant.filled,
    this.useGradientBorder = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final HBTextFieldVariant variant;
  final bool useGradientBorder;

  @override
  State<HBTextField> createState() => _HBTextFieldState();

  // ============================================================================
  // Factory Constructors
  // ============================================================================

  /// Standard filled text field
  factory HBTextField.filled({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      variant: HBTextFieldVariant.filled,
    );
  }

  /// Outlined text field
  factory HBTextField.outlined({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    int? maxLines = 1,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      variant: HBTextFieldVariant.outlined,
    );
  }

  /// Password field with toggle visibility
  factory HBTextField.password({
    Key? key,
    TextEditingController? controller,
    String? label = 'Password',
    String? hint,
    String? helperText,
    IconData? prefixIcon = Icons.lock_outline,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: prefixIcon,
      obscureText: true,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  /// Multiline text field
  factory HBTextField.multiline({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    int minLines = 3,
    int? maxLines = 5,
    int? maxLength,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Email text field with validation
  factory HBTextField.email({
    Key? key,
    TextEditingController? controller,
    String? label = 'Email',
    String? hint,
    String? helperText,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  /// Phone number text field
  factory HBTextField.phone({
    Key? key,
    TextEditingController? controller,
    String? label = 'Phone Number',
    String? hint,
    String? helperText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  /// Number text field
  factory HBTextField.number({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool decimal = false,
  }) {
    return HBTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      prefixIcon: prefixIcon,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (!decimal) FilteringTextInputFormatter.digitsOnly,
        if (decimal) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}

class _HBTextFieldState extends State<HBTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;

    if (widget.initialValue != null && widget.controller == null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveErrorText = widget.errorText ?? _errorText;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: _buildDecoration(context, effectiveErrorText),
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      style: context.textTheme.bodyLarge,
    );
  }

  InputDecoration _buildDecoration(BuildContext context, String? errorText) {
    final hasError = errorText != null;

    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helperText,
      errorText: errorText,
      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
      prefix: widget.prefix,
      suffixIcon: _buildSuffixIcon(),
      suffix: widget.suffix,
      filled: widget.variant == HBTextFieldVariant.filled,
      fillColor: widget.variant == HBTextFieldVariant.filled
          ? context.colorScheme.surfaceContainerHighest
          : null,
      border: _buildBorder(context, isError: false),
      enabledBorder: _buildBorder(context, isError: false),
      focusedBorder: _buildBorder(context, isError: false, isFocused: true),
      errorBorder: _buildBorder(context, isError: true),
      focusedErrorBorder: _buildBorder(context, isError: true, isFocused: true),
      disabledBorder: _buildBorder(context, isError: false, isDisabled: true),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      errorMaxLines: 2,
      helperMaxLines: 2,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: _toggleObscureText,
      );
    }
    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon);
    }
    return null;
  }

  InputBorder _buildBorder(
    BuildContext context, {
    required bool isError,
    bool isFocused = false,
    bool isDisabled = false,
  }) {
    final borderRadius = BorderRadius.circular(AppRadii.md);

    if (widget.variant == HBTextFieldVariant.filled) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: isError
              ? context.colorScheme.error
              : isFocused
                  ? context.colorScheme.primary
                  : Colors.transparent,
          width: isFocused ? 2 : 1,
        ),
      );
    }

    // Outlined variant
    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: isError
            ? context.colorScheme.error
            : isDisabled
                ? context.colorScheme.outline.withValues(alpha: 0.38)
                : isFocused
                    ? context.colorScheme.primary
                    : context.colorScheme.outline,
        width: isFocused ? 2 : 1,
      ),
    );
  }
}

/// ============================================================================
/// Enums
/// ============================================================================

enum HBTextFieldVariant {
  filled,
  outlined,
}

/// ============================================================================
/// Common Validators
/// ============================================================================

class HBValidators {
  /// Required field validator
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Phone number validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Minimum length validator
  static String? Function(String?) minLength(int length, [String fieldName = 'This field']) {
    return (value) {
      if (value == null || value.isEmpty) {
        return '$fieldName is required';
      }
      if (value.length < length) {
        return '$fieldName must be at least $length characters';
      }
      return null;
    };
  }

  /// Maximum length validator
  static String? Function(String?) maxLength(int length, [String fieldName = 'This field']) {
    return (value) {
      if (value != null && value.length > length) {
        return '$fieldName must be at most $length characters';
      }
      return null;
    };
  }

  /// Number validator
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Positive number validator
  static String? positiveNumber(String? value) {
    final numberError = number(value);
    if (numberError != null) return numberError;

    final numValue = double.parse(value!);
    if (numValue <= 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  /// URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
