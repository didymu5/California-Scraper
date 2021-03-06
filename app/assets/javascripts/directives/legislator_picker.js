app = angular.module('reportcard');
app.directive('legislatorNameSearchbar', ['LegislatorDataService', function(LegislatorDataService) {
  return {
    transclude: true,
    templateUrl: '/templates/legislator_search.html',
    scope: {
      selectedLegislator: '=',
      searchAttribute: '@'
    },
    link: function(scope, elem, attrs) {
      LegislatorDataService.getLegislators().then(function(legislators) {
        scope.legislators = legislators.sort(function(legislator1, legislator2) {
          return legislator1.name.localeCompare(legislator2.name);
        });
        scope.legislatorsToSearch = scope.legislators;
      });
      scope.selectLegislator = function($index) {
        scope.selectedLegislatorIndex = $index;
        scope.selectedLegislator = scope.legislatorsToSearch[$index];
      }
      scope.shouldHighlight = function($index) {
        return scope.selectedLegislatorIndex === $index;
      }
      scope.searchForLegislators = function() {
        scope.legislatorsToSearch = scope.legislators.filter(function(legislator) {
          var legislatorAttributeToSearchBy = legislator[scope.searchAttribute];
          return legislatorAttributeToSearchBy.toLowerCase().includes(scope.legislatorSearch.toLowerCase());
        });
      }
    }

  }
}]);