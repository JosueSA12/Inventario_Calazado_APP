import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventario/core/providers/notificacion_provider.dart';

class PanelNotificaciones extends StatelessWidget {
  const PanelNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificacionProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context, provider),
          const Divider(height: 1),
          Expanded(
            child: provider.notificaciones.isEmpty
                ? _buildEmptyState()
                : _buildLista(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificacionProvider provider) {
    final unreadCount = provider.notificaciones.where((n) => !n.leida).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Notificaciones",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (provider.tieneNotificaciones)
            TextButton.icon(
              onPressed: () {
                provider.limpiarNotificaciones();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text("Limpiar todo"),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          const Text(
            "No tienes notificaciones",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cuando recibas alguna aparecerá aquí",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(BuildContext context, NotificacionProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.notificaciones.length,
      itemBuilder: (context, index) {
        final n = provider.notificaciones[index];
        return _buildNotificacionCard(context, n, index, provider);
      },
    );
  }

  Widget _buildNotificacionCard(
    BuildContext context,
    Notificacion n,
    int index,
    NotificacionProvider provider,
  ) {
    return Dismissible(
      key: Key('notification_${n.id}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (index < provider.notificaciones.length) {
          provider.eliminarNotificacion(index);
        }
      },
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: n.color.withOpacity(0.12),
            child: Icon(n.icono, color: n.color, size: 26),
          ),
          title: Text(
            n.titulo,
            style: TextStyle(
              fontWeight: n.leida ? FontWeight.w500 : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              n.mensaje,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              if (!n.leida)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            provider.marcarComoLeida(index);
          },
        ),
      ),
    );
  }
}
