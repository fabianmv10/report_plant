import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:report_plant/core/errors/failures.dart';
import 'package:report_plant/features/plants/domain/entities/plant.dart';
import 'package:report_plant/features/plants/domain/usecases/get_all_plants.dart';
import 'package:report_plant/features/plants/presentation/bloc/plants_bloc.dart';

import 'plants_bloc_test.mocks.dart';

@GenerateMocks([GetAllPlants])
void main() {
  late PlantsBloc bloc;
  late MockGetAllPlants mockGetAllPlants;

  setUp(() {
    mockGetAllPlants = MockGetAllPlants();
    bloc = PlantsBloc(getAllPlants: mockGetAllPlants);
  });

  tearDown(() {
    bloc.close();
  });

  group('PlantsBloc', () {
    const tPlants = [
      Plant(id: '1', name: 'Planta 1'),
      Plant(id: '2', name: 'Planta 2'),
    ];

    test('estado inicial debe ser PlantsState.initial()', () {
      expect(bloc.state, const PlantsState.initial());
    });

    blocTest<PlantsBloc, PlantsState>(
      'debe emitir [Loading, Loaded] cuando las plantas se cargan correctamente',
      build: () {
        when(mockGetAllPlants())
            .thenAnswer((_) async => const Right(tPlants));
        return bloc;
      },
      act: (bloc) => bloc.add(const PlantsEvent.loadPlants()),
      expect: () => [
        const PlantsState.loading(),
        const PlantsState.loaded(tPlants),
      ],
      verify: (_) {
        verify(mockGetAllPlants());
      },
    );

    blocTest<PlantsBloc, PlantsState>(
      'debe emitir [Loading, Error] cuando falla la carga',
      build: () {
        when(mockGetAllPlants())
            .thenAnswer((_) async => const Left(ServerFailure('Error de servidor')));
        return bloc;
      },
      act: (bloc) => bloc.add(const PlantsEvent.loadPlants()),
      expect: () => [
        const PlantsState.loading(),
        const PlantsState.error('Error de servidor'),
      ],
    );
  });
}
