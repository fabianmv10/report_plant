import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final DateFormat dateFormatter = DateFormat('dd-MM-yy');
    
    return CustomCard(
      accentColor: shiftColor,
      title: title,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shift,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: shiftColor,
                ),
              ),
              Text(
                leader,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                dateFormatter.format(timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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

}