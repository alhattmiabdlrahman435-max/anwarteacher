import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/settings_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.teacher;

  AnimationController? _animationController;
  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _idFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    _initializeAnimations();
  }

  static const int _totalSteps = 6;

  void _initializeAnimations() {
    if (_animationController != null) {
      if (_fadeAnimations.length == _totalSteps) return;
      _animationController!.dispose();
      _animationController = null;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    const double stepTime = 0.1;
    const double animDuration = 0.4;

    _fadeAnimations = List.generate(_totalSteps, (index) {
      final start = index * stepTime;
      final end = (start + animDuration).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _animationController!,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(_totalSteps, (index) {
      final start = index * stepTime;
      final end = (start + animDuration).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    _animationController!.forward();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate network request duration
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await ref.read(authProvider.notifier).login(
      _idController.text,
      _passwordController.text,
      _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      AppNotification.show(
        context,
        type: AppNotificationType.success,
        title: _selectedRole == UserRole.teacher 
            ? 'مرحباً بك يا معلم' 
            : 'مرحباً بكِ يا مشرفة التحضير',
      );

      if (_selectedRole == UserRole.teacher) {
        context.go('/dashboard');
      } else {
        context.go('/assistant/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely re-initialize if needed (handles hot reload states)
    _initializeAnimations();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final activeColor = isDark ? AppColors.uiPalettePrimary : AppColors.primary;

    if (_fadeAnimations.isEmpty || _slideAnimations.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF070A13), const Color(0xFF02040A)]
                : [const Color(0xFFEBF3FC), const Color(0xFFF3F7FB), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Fixed Header Row with Switcher Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _CircleIconButton(
                          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          onTap: () {
                            ref.read(settingsProvider.notifier).toggleTheme(!isDark);
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _CircleIconButton(
                          icon: Icons.language_rounded,
                          onTap: () {
                            ref.read(settingsProvider.notifier).toggleLanguage();
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),

              // 2. Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            
                            // STAGGER 0: School Logo Card & Centered Name
                            _StaggeredReveal(
                              fadeAnimation: _fadeAnimations[0],
                              slideAnimation: _slideAnimations[0],
                              child: Column(
                                children: [
                                  Container(
                                    width: 105,
                                    height: 105,
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/icons/app_icon.jpeg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    isArabic 
                                        ? 'رياض ومدارس أنوار العلى النموذجية' 
                                        : 'Riyadh & Anwar Al-Ola Model Schools',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // STAGGER 1: Main Login Card Container
                            _StaggeredReveal(
                              fadeAnimation: _fadeAnimations[1],
                              slideAnimation: _slideAnimations[1],
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceAltDark : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E3A8A).withValues(alpha: isDark ? 0.3 : 0.05),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Header title
                                    Text(
                                      context.loc.login,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    // Dynamic Subtitle
                                    Text(
                                      _selectedRole == UserRole.teacher 
                                          ? (isArabic ? 'مرحباً بك مجدداً يا معلم' : 'Welcome back, Teacher')
                                          : (isArabic ? 'مرحباً بكِ مجدداً يا مشرفة' : 'Welcome back, Assistant'),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),

                                    // STAGGER 2: Role Switcher
                                    _StaggeredReveal(
                                      fadeAnimation: _fadeAnimations[2],
                                      slideAnimation: _slideAnimations[2],
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _RoleCard(
                                              icon: Icons.school_rounded,
                                              label: context.loc.teacherRole,
                                              isSelected: _selectedRole == UserRole.teacher,
                                              isDark: isDark,
                                              onTap: () {
                                                setState(() {
                                                  _selectedRole = UserRole.teacher;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: _RoleCard(
                                              icon: Icons.checklist_rtl_rounded,
                                              label: context.loc.assistantRole,
                                              isSelected: _selectedRole == UserRole.assistant,
                                              isDark: isDark,
                                              onTap: () {
                                                setState(() {
                                                  _selectedRole = UserRole.assistant;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),

                                    // STAGGER 3: Employee ID Input (Mockup Style with float labels)
                                    _StaggeredReveal(
                                      fadeAnimation: _fadeAnimations[3],
                                      slideAnimation: _slideAnimations[3],
                                      child: TextFormField(
                                        controller: _idController,
                                        focusNode: _idFocusNode,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: context.loc.employeeId,
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          labelStyle: TextStyle(
                                            color: _idFocusNode.hasFocus 
                                                ? activeColor 
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.badge_outlined,
                                            color: _idFocusNode.hasFocus 
                                                ? activeColor 
                                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                          ),
                                          filled: true,
                                          fillColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.04),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFCBD5E1),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: activeColor,
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(
                                              color: AppColors.error,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context.loc.pleaseEnterEmployeeId;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // STAGGER 4: Password Input (Mockup Style with float labels)
                                    _StaggeredReveal(
                                      fadeAnimation: _fadeAnimations[4],
                                      slideAnimation: _slideAnimations[4],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          TextFormField(
                                            controller: _passwordController,
                                            focusNode: _passwordFocusNode,
                                            obscureText: _obscurePassword,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: context.loc.password,
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              labelStyle: TextStyle(
                                                color: _passwordFocusNode.hasFocus 
                                                    ? activeColor 
                                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.lock_outlined,
                                                color: _passwordFocusNode.hasFocus 
                                                    ? activeColor 
                                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                  color: _passwordFocusNode.hasFocus 
                                                      ? activeColor 
                                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                              ),
                                              filled: true,
                                              fillColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.04),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFCBD5E1),
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: activeColor,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: const BorderSide(
                                                  color: AppColors.error,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: const BorderSide(
                                                  color: AppColors.error,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return context.loc.pleaseEnterPassword;
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                              onPressed: () {
                                                AppNotification.show(
                                                  context,
                                                  type: AppNotificationType.info,
                                                  title: context.loc.forgotPasswordComingSoon,
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                                foregroundColor: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.primary,
                                              ),
                                              child: Text(
                                                context.loc.forgotPassword,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),

                                    // STAGGER 5: Login Proceed Button
                                    _StaggeredReveal(
                                      fadeAnimation: _fadeAnimations[5],
                                      slideAnimation: _slideAnimations[5],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _LoginButton(
                                            onTap: _isLoading ? null : _login,
                                            isLoading: _isLoading,
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: AppSpacing.lg),
                                          Text(
                                            context.loc.versionLabel('1.0.0'),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _StaggeredReveal extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget child;

  const _StaggeredReveal({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isSelected = widget.isSelected;
    final activeColor = isDark ? AppColors.uiPalettePrimary : AppColors.primary;

    final cardBg = isDark
        ? (isSelected ? activeColor.withValues(alpha: 0.12) : AppColors.surfaceAltDark)
        : (isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white);
    
    final borderColor = isSelected
        ? activeColor
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.18));

    final iconColor = isSelected 
        ? (isDark ? Colors.white : activeColor) 
        : (isDark ? Colors.white54 : AppColors.textSecondaryLight);
    final textColor = isSelected 
        ? (isDark ? Colors.white : activeColor) 
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: isDark ? 0.35 : 0.16),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? activeColor.withValues(alpha: 0.1) 
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: iconColor, size: 30),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -8,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceAltDark : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: isDark ? AppColors.surfaceAltDark : Colors.white,
                      size: 10,
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceAltDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDark;

  const _LoginButton({
    required this.onTap,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active = onTap != null && !isLoading;
    final primaryColor = const Color(0xFF1E3A8A); // Deep Navy Matching Reference

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: active 
              ? (isDark ? Colors.white : primaryColor) 
              : Colors.grey.withValues(alpha: 0.3),
          foregroundColor: isDark ? primaryColor : Colors.white,
          elevation: active ? 4 : 0,
          shadowColor: active 
              ? (isDark ? Colors.white.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.35)) 
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: isDark ? primaryColor : Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.loc.login,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? primaryColor : Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward, 
                    color: isDark ? primaryColor : Colors.white, 
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}
