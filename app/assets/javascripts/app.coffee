MULTIPLE_VALUE_ATTRS = {
  property_type: ['house', 'apartment']
}

SINGLE_VALUE_ATTRS = ['maxPrice', 'minPrice', 'check_in', 'check_out']

AppCtrl = ($scope, $http, $compile) ->

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
  $scope.minPrice = null
  $scope.maxPrice = null

  urlAttrs = ->
    str = '?'
    for attr in SINGLE_VALUE_ATTRS
      str += "#{attr}=#{$scope[attr]}&" if $scope[attr]

    for attrType, attrs of MULTIPLE_VALUE_ATTRS
      activeAttrs = _.compact _(attrs).map((attr) -> $scope[attr] && attr || false)
      if activeAttrs.length > 0
        str += "#{attrType}="
        for attr in attrs
          str += "#{attr}," if $scope[attr]
        str += '&'
    str

  fetch_listings = ->
    $http.get("/city/#{$scope.region.name.replace(' ', '_')}#{urlAttrs()}").success (rsp) -> $scope.listings = rsp

  watch = (attrs) -> _(attrs).each (attr) -> $scope.$watch attr, (o, n) ->
    unless o == n
      if      attr == 'check_in'  && $scope.check_out
        check_in  = Date.parse $scope.check_in
        check_out = Date.parse $scope.check_out
        $scope.check_out = new Date(check_in) if check_in >= check_out
      else if attr == 'check_out' && $scope.check_in
        check_in  = Date.parse $scope.check_in
        check_out = Date.parse $scope.check_out
        $scope.check_in = new Date(check_out - 86400) if check_out <= check_in
      fetch_listings()

  $scope.$watch 'region', -> fetch_listings() if $scope.region
  watch SINGLE_VALUE_ATTRS
  _(MULTIPLE_VALUE_ATTRS).each (attrs) -> watch attrs

ListingCtrl = ($scope, $http) ->


app = angular.module('luxhaven', ['ui.select2', 'ui.date'])
  .controller('app',      AppCtrl)
  .controller('listings', ListingsCtrl)
  .controller('listing',  ListingCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr('content')
  .directive('unslider', -> (scope, element) ->
    element.unslider {
      speed: 600
      delay: 7500
      dots: true
      keys: true
      fluid: true
    })
  .directive('slider', -> (scope, element, attrs) ->
    minPrice = scope.minPrice
    maxPrice = scope.maxPrice

    price = (n) ->
        if      n >= 0   && n < 25  then 0
        else if n >= 25  && n < 50  then 150
        else if n >= 50  && n < 75  then 300
        else if n >= 75  && n < 100 then 500
        else if n >= 100 && n < 125 then 800
        else if n >= 125 && n < 150 then 1200
        else if n >= 150 && n < 175 then 1600
        else if n >= 175 && n < 200 then 2000
        else if n >= 200 && n < 225 then 3500
        else if n >= 225            then 5000

    knobOne = element.find('.knob.one')
    knobTwo = element.find('.knob.two')

    element.find('.knob').each (_, element) ->
      element.addEventListener 'mousedown', (e) ->
        angular.element('html').addClass('dragging')
        e.preventDefault()

    element.find('.one').each (_, element) ->
      element.addEventListener 'mousedown', ->
        scope.knobOne = true
    element.find('.two').each (_, element) ->
      element.addEventListener 'mousedown', ->
        scope.knobTwo = true

    addEventListener 'mouseup', ->
      scope.$apply ->
        scope.minPrice = minPrice
        scope.maxPrice = maxPrice
        scope.knobOne = false
        scope.knobTwo = false
      angular.element('html').removeClass('dragging')

    addEventListener 'mousemove', (e) ->
      if scope.knobOne
        if e.x >= 158 && e.x <= knobTwo.offset().left - 7
          knobOne.css 'left', e.x - 158 + 'px'
        else if e.x < 158
          knobOne.css 'left', 0
        else if e.x > knobTwo.offset().left - 7
          knobOne.css 'left', knobTwo.offset().left - 165
        newPrice = price(parseInt knobOne.css('left'))
        element.find('.knob-one').text('$' + newPrice)
        minPrice = newPrice
      else if scope.knobTwo
        if e.x <= 394 && e.x >= knobOne.offset().left + 20
          knobTwo.css 'right', 394 - e.x + 'px'
        else if e.x > 394
          knobTwo.css 'right', 0
        else if e.x < knobOne.offset().left + 20
          knobTwo.css 'right', 374 - knobOne.offset().left
        newPrice = price(250 - parseInt(knobTwo.css('right')))
        element.find('.knob-two').text('$' + newPrice)
        maxPrice = newPrice

  )

angular.element(document).on 'ready page:load', -> angular.bootstrap(document, ['luxhaven'])