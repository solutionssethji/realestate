import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:customer_app/models/plot_status.dart';
import 'package:customer_app/pages/plot_availability/plot_availability.logic.dart';
import 'package:customer_app/utils/price_formatter.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/models/plot.dart';

void main() {
  group('PriceFormatter Tests', () {
    test('Formats Indian Rupees correctly', () {
      expect(PriceFormatter.format(4550000.0), '₹45,50,000');
      expect(PriceFormatter.format(3200000.0), '₹32,00,000');
    });
  });

  group('PlotAvailabilityLogic Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      ApiService.mockGetPlots = (projectId) async {
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // simulate network
        final plots = <Plot>[];
        for (int i = 1; i <= 15; i++) {
          plots.add(
            Plot(
              id: '${projectId}_plot_$i',
              projectId: projectId,
              plotNumber: 'EP-${100 + i}',
              sizeInSqFt: 1200.0,
              dimensions: '30 x 40',
              facing: 'East',
              roadWidth: '30 ft',
              status: i % 5 == 0
                  ? PlotStatus.bookedSold
                  : (i % 7 == 0 ? PlotStatus.hold : PlotStatus.available),
              price: 4500000.0,
            ),
          );
        }
        return plots;
      };
    });

    tearDown(() {
      container.dispose();
      ApiService.mockGetPlots = null;
    });

    test('Initial state loads plots for p1', () async {
      final logicProvider = plotAvailabilityLogicProvider('p1');
      container.listen(logicProvider, (_, __) {});
      final state = container.read(logicProvider);

      expect(state.isLoading, true);
      expect(state.projectId, 'p1');
      expect(state.allPlots.isEmpty, true);

      // Wait for mock data load
      await Future.delayed(const Duration(milliseconds: 600));

      final loadedState = container.read(logicProvider);
      expect(loadedState.isLoading, false);
      expect(loadedState.allPlots.length, 15);
      expect(loadedState.filteredPlots.length, 15);
    });

    test('Filter by status updates filteredPlots', () async {
      final logicProvider = plotAvailabilityLogicProvider('p1');
      container.listen(logicProvider, (_, __) {});

      // Wait for mock data load
      await Future.delayed(const Duration(milliseconds: 600));

      final logic = container.read(logicProvider.notifier);

      logic.setStatusFilter(PlotStatus.available);
      var state = container.read(logicProvider);
      expect(
        state.filteredPlots.every((p) => p.status == PlotStatus.available),
        true,
      );

      logic.setStatusFilter(PlotStatus.hold);
      state = container.read(logicProvider);
      expect(
        state.filteredPlots.every((p) => p.status == PlotStatus.hold),
        true,
      );
    });

    test('Search query updates filteredPlots', () async {
      final logicProvider = plotAvailabilityLogicProvider('p1');
      container.listen(logicProvider, (_, __) {});

      // Wait for mock data load
      await Future.delayed(const Duration(milliseconds: 600));

      final logic = container.read(logicProvider.notifier);

      logic.updateSearch('EP-101');
      final state = container.read(logicProvider);

      expect(state.filteredPlots.length, 1);
      expect(state.filteredPlots.first.plotNumber, 'EP-101');
    });
  });
}
