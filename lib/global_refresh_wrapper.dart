/* import 'package:flutter/material.dart';
import 'package:pet_family_app/global_refresh_provider.dart';
import 'package:provider/provider.dart';

class GlobalRefreshWrapper extends StatelessWidget {
  final Widget child;
  final bool enablePullToRefresh;
  
  const GlobalRefreshWrapper({
    super.key,
    required this.child,
    this.enablePullToRefresh = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final refreshProvider = context.watch<GlobalRefreshProvider>();
    
    // Se não quiser pull to refresh, retorna apenas o child
    if (!enablePullToRefresh) {
      return child;
    }
    
    return RefreshIndicator(
      // Controla se mostra o indicador ou não
      notificationPredicate: (notification) {
        return notification.depth == 0; // Apenas no scroll principal
      },
      displacement: 40.0,
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      
      // Função chamada ao fazer pull to refresh
      onRefresh: () async {
        await refreshProvider.refreshAll(context);
      },
      
      // Widget filho
      child: Stack(
        children: [
          // Conteúdo principal
          child,
          
          // Overlay de loading (opcional)
          if (refreshProvider.isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
} */