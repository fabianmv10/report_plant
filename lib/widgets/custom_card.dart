import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Widget personalizado para mostrar tarjetas con estilos consistentes
class CustomCard extends StatelessWidget {
  /// Título de la tarjeta
  final String? title;
  
  /// Subtítulo opcional de la tarjeta
  final String? subtitle;
  
  /// Icono opcional para mostrar junto al título
  final IconData? icon;
  
  /// Color del icono y la barra superior
  final Color? accentColor;
  
  /// Contenido de la tarjeta
  final Widget child;
  
  /// Acción opcional al hacer tap en la tarjeta
  final VoidCallback? onTap;
  
  /// Padding interno para el contenido
  final EdgeInsetsGeometry contentPadding;
  
  /// Si es true, muestra la barra de título
  final bool showHeader;
  
  /// Elevación de la tarjeta
  final double elevation;
  
  /// Si es true, aplica una animación de elevación al hacer hover
  final bool hoverEffect;

  /// Constructor para CustomCard
  const CustomCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    required this.child,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.showHeader = true,
    this.elevation = 2.0,
    this.hoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppTheme.primaryColor;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: AppTheme.mediumBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: AppTheme.mediumBorderRadius,
        child: InkWell(
          borderRadius: AppTheme.mediumBorderRadius,
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader && title != null) ...[
                _buildHeader(context, effectiveAccentColor),
              ],
              Padding(
                padding: contentPadding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado de la tarjeta con título, subtítulo e icono
  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.textTheme.titleLarge?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Variante de CustomCard optimizada para datos de reportes
class ReportCard extends StatelessWidget {
  /// Título del reporte
  final String title;
  
  /// Shift o turno del reporte
  final String shift;
  
  /// Líder o responsable del reporte
  final String leader;
  
  /// Fecha/hora del reporte
  final DateTime timestamp;
  
  /// Widget opcional para información adicional
  final Widget? content;
  
  /// Acción al tocar la tarjeta
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.shift,
    required this.leader,
    required this.timestamp,
    this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shiftColor = AppTheme.shiftColors[shift] ?? AppTheme.primaryColor;
    
    return CustomCard(
      accentColor: shiftColor,
      icon: Icons.assignment,
      title: title,
      subtitle: 'Turno: $shift',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Líder: $leader',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _formatDate(timestamp),
                style: TextStyle(
                  color: context.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 12),
            content!,
          ],
        ],
      ),
    );
  }

  /// Formatea una fecha en formato legible
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${_getDayName(date.weekday)} ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  /// Formatea la hora en formato HH:MM
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Obtiene el nombre del día de la semana
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lunes';
      case 2: return 'Martes';
      case 3: return 'Miércoles';
      case 4: return 'Jueves';
      case 5: return 'Viernes';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }
}

/// Tarjeta para datos estadísticos con valor numérico destacado
class StatCard extends StatelessWidget {
  /// Título de la estadística
  final String title;
  
  /// Valor numérico para mostrar
  final String value;
  
  /// Descripción opcional o contexto
  final String? subtitle;
  
  /// Icono para la estadística
  final IconData icon;
  
  /// Color de acento
  final Color color;
  
  /// Tendencia (positiva, negativa o neutral)
  final Trend trend;
  
  /// Valor de la tendencia (ejemplo: "+5%")
  final String? trendValue;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trend = Trend.neutral,
    this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      showHeader: false,
      elevation: 2,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, 
                    color: context.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null || trendValue != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textTheme.bodySmall?.color,
                          ),
                        ),
                      if (subtitle != null && trendValue != null)
                        const SizedBox(width: 8),
                      if (trendValue != null)
                        Row(
                          children: [
                            Icon(
                              _getTrendIcon(),
                              color: _getTrendColor(),
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trendValue!,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTrendColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según la tendencia
  Color _getTrendColor() {
    switch (trend) {
      case Trend.up:
        return AppTheme.successColor;
      case Trend.down:
        return AppTheme.errorColor;
      case Trend.neutral:
        return AppTheme.infoColor;
    }
  }

  /// Obtiene el icono según la tendencia
  IconData _getTrendIcon() {
    switch (trend) {
      case Trend.up:
        return Icons.trending_up;
      case Trend.down:
        return Icons.trending_down;
      case Trend.neutral:
        return Icons.trending_flat;
    }
  }
}

/// Enum para representar tendencias en StatCard
enum Trend { up, down, neutral }