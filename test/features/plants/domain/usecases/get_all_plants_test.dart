import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:report_plant/features/plants/domain/entities/plant.dart';
import 'package:report_plant/features/plants/domain/repositories/plant_repository.dart';
import 'package:report_plant/features/plants/domain/usecases/get_all_plants.dart';

import 'get_all_plants_test.mocks.dart';

@GenerateMocks([PlantRepository])
void main() {
  late GetAllPlants usecase;
  late MockPlantRepository mockRepository;

  setUp(() {
    mockRepository = MockPlantRepository();
    usecase = GetAllPlants(mockRepository);
  });

  group('GetAllPlants', () {
    final tPlants = [
      const Plant(id: '1', name: 'Planta 1'),
      const Plant(id: '2', name: 'Planta 2'),
    ];

    test('debe obtener lista de plantas del repositorio', () async {
      // Arrange
      when(mockRepository.getAllPlants())
          .thenAnswer((_) async => Right(tPlants));

      // Act
      final result = await usecase();

      // Assert
      // ignore: inference_failure_on_instance_creation
      expect(result, Right(tPlants));
      verify(mockRepository.getAllPlants());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
