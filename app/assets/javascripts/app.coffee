AppCtrl = ($scope, $http, $compile) ->
  window.s = $scope
  $scope.signinContent = angular.element('#sign-in').html()
  $scope.signupContent = angular.element('#sign-up').html()

  $http.post('/auth').success (rsp) ->
    if rsp.success
      $scope.signedIn = true
    else
      $scope.signedIn = false

  $scope.signInModal = ->
    angular.element('#sign-in').bPopup bPopOpts

  $scope.toSignup = ->
    angular.element('#sign-in').attr('id', 'signup')
    angular.element('#sign-up').attr('id', 'sign-in')
    angular.element('#signup').attr('id', 'sign-up')
    angular.element('#sign-up').html $compile($scope.signupContent)($scope)

  $scope.toSignin = ->
    angular.element('#sign-up').attr('id', 'signin')
    angular.element('#sign-in').attr('id', 'sign-up')
    angular.element('#signin').attr('id', 'sign-in')
    angular.element('#sign-in').html $compile($scope.signinContent)($scope)

  $scope.signOut = ->
    $http.post('/signout').success -> $scope.signedIn = false

  bPopOpts =
    onOpen:  ->
      angular.element('body').css('overflow', 'hidden')
    onClose: ->
      angular.element('body').css('overflow', 'auto')
      angular.element('#sign-in').html $compile($scope.signinContent)($scope)
      angular.element('#sign-up').html $compile($scope.signupContent)($scope)
    modalColor: 'white'
    opacity: 0.65


ListingsCtrl = ($scope, $http) ->


ListingCtrl = ($scope, $http) ->


angular.module('luxhaven', [])
  .controller('app',      AppCtrl)
  .controller('listing',  ListingCtrl)
  .controller('listings', ListingsCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr('content')
