import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../factories/repositories_factories.dart';
import '../../../mocks/datasources_mocks.dart';

void main() {
  MockRecentSearchesLocalDataSource stubbedDataSource(List<String> stored) {
    final recentSearchesLocalDataSource = MockRecentSearchesLocalDataSource();
    when(recentSearchesLocalDataSource.getRecentSearches).thenReturn(stored);
    when(() => recentSearchesLocalDataSource.saveRecentSearches(any())).thenAnswer((_) async {});
    return recentSearchesLocalDataSource;
  }

  test('a new search goes to the front', () async {
    final dataSource = stubbedDataSource(['frango', 'aveia']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.addRecentSearch(query: 'banana');

    expect(updatedSearches, ['banana', 'frango', 'aveia']);
    verify(() => dataSource.saveRecentSearches(['banana', 'frango', 'aveia'])).called(1);
  });

  test('searching the same term again moves it to the front instead of duplicating it', () async {
    final dataSource = stubbedDataSource(['frango', 'aveia', 'banana']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.addRecentSearch(query: 'banana');

    expect(updatedSearches, ['banana', 'frango', 'aveia']);
  });

  test('de-duplication ignores case, and the newly typed spelling wins', () async {
    final dataSource = stubbedDataSource(['banana']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.addRecentSearch(query: 'Banana');

    expect(updatedSearches, ['Banana']);
  });

  test('the query is trimmed before it is stored', () async {
    final dataSource = stubbedDataSource([]);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.addRecentSearch(query: '  banana  ');

    expect(updatedSearches, ['banana']);
  });

  test('the oldest search falls off once the cap is reached', () async {
    final dataSource = stubbedDataSource(['s8', 's7', 's6', 's5', 's4', 's3', 's2', 's1']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.addRecentSearch(query: 'novo');

    expect(updatedSearches, hasLength(8));
    expect(updatedSearches.first, 'novo');
    expect(updatedSearches, isNot(contains('s1')));
  });

  test('removing one search leaves the rest in order', () async {
    final dataSource = stubbedDataSource(['banana', 'frango', 'aveia']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.removeRecentSearch(query: 'frango');

    expect(updatedSearches, ['banana', 'aveia']);
  });

  test('clearing wipes the list', () async {
    final dataSource = stubbedDataSource(['banana', 'frango']);
    final repository = RepositoriesFactories.buildDietRepository(recentSearchesLocalDataSource: dataSource);

    final updatedSearches = await repository.clearRecentSearches();

    expect(updatedSearches, isEmpty);
    verify(() => dataSource.saveRecentSearches([])).called(1);
  });
}
