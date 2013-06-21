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
      $scope.user = JSON.parse rsp.user
    else
      $scope.signedIn = false

  $scope.signInModal = (callback) ->
    angular.element('#sign-in').bPopup {
      onOpen:  ->
        angular.element('body').css('overflow', 'hidden')
      onClose: ->
        angular.element('body').css('overflow', 'auto')
        angular.element('#sign-in').html $compile($scope.signinContent)($scope)
        angular.element('#sign-up').html $compile($scope.signupContent)($scope)
        callback() if callback
      modalColor: 'white'
      opacity: 0.65
    }

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
    $http.post('/signout').success (rsp) ->
      $scope.signedIn = false
      $scope.user = null
      $http.defaults.headers.common['X-CSRF-Token'] = rsp.token
      angular.element('meta[name=csrf-token]').attr 'content', rsp.token


ListingsCtrl = ($scope, $http, $cookies) ->
  $scope.minPrice = null
  $scope.maxPrice = null

  $scope.checkInDate = (date) ->
    if $scope.check_out
      if $scope.check_out <= date || moment() > moment(date)
        [false, '']
      else
        [true, '']
    else
      [true, '']

  $scope.checkOutDate = (date) ->
    if $scope.check_in
      if $scope.check_in >= date || moment() > moment(date).subtract 'days', 1
        [false, '']
      else
        [true, '']
    else
      [true, '']

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
    $http.get("/#{$scope.region.slug}#{urlAttrs()}").success (rsp) -> $scope.listings = rsp

  watch = (attrs) -> _(attrs).each (attr) -> $scope.$watch attr, (n, o) ->
    unless o == n
      timestamp = moment(n).format('X')
      if attr == 'check_in'
        $cookies.check_in = timestamp
      else if attr == 'check_out'
        $cookies.check_out = timestamp
      fetch_listings()

  $scope.$watch 'region', -> fetch_listings() if $scope.region
  watch SINGLE_VALUE_ATTRS
  _(MULTIPLE_VALUE_ATTRS).each (attrs) -> watch attrs
  $scope.check_in  = new Date(parseInt($cookies.check_in) * 1000)
  $scope.check_out = new Date(parseInt($cookies.check_out) * 1000)


ListingCtrl = ($scope, $http, $cookies) ->
  $scope.check_in  = new Date(parseInt($cookies.check_in) * 1000)
  $scope.check_out = new Date(parseInt($cookies.check_out) * 1000)

  $http.get('').success (listing) ->
    listing.bookings = _(listing.bookings).reject (booking) ->
      booking.check_in  = moment booking.check_in
      booking.check_out = moment booking.check_out
      booking.check_out < moment Date.today
    $scope.listing = listing

  angular.element('#book-modal .payment form').submit ->
    disable = -> angular.element(@).find('button').prop('disabled', true)
    enable  = -> angular.element(@).find('button').prop('disabled', false)

    disable()
    Stripe.createToken @, (_, rsp) ->
      if rsp.error
        console.log rsp.error.message
        enable()
      else
        $http.post("/#{$scope.region.slug}/#{$scope.listing.slug}/book", {
          check_in: $scope.check_in
          check_out: $scope.check_out
          card: rsp.id
        }).success (rsp) ->
          console.log rsp
          angular.element('#book-modal').bPopup().close()
    false

  $scope.book = ->
    if $scope.signedIn
      angular.element('#book-modal').bPopup bPopOpts
    else
      $scope.signInModal -> angular.element('#book-modal').bPopup bPopOpts

  $scope.checkInDate = (date) ->
    if $scope.listing
      valid = ->
        (_($scope.listing.bookings).every (booking) ->
          booking.check_out   <= moment(date) ||
          booking.check_in    >  moment(date).add 'days', 1
        ) && moment()         <  moment(date) &&
             $scope.check_out > date

      valid() && [true, ''] || [false, '']
    else
      [false, '']

  $scope.checkOutDate = (date) ->
    if $scope.listing
      valid = ->
        (_($scope.listing.bookings).every (booking) ->
          booking.check_out  < moment(date) ||
          booking.check_in   > moment(date)
        ) && moment()        < moment(date).subtract('days', 1) &&
             $scope.check_in < date

      valid() && [true, ''] || [false, '']
    else
      [false, '']

  $scope.$watch 'check_in', (n, o) ->
    unless o == n
      timestamp = moment(n).format('X')
      $cookies.check_in = timestamp

  $scope.$watch 'check_out', (n, o) ->
    unless o == n
      timestamp = moment(n).format('X')
      $cookies.check_out = timestamp

  bPopOpts =
    onOpen:  ->
      angular.element('body').css('overflow', 'hidden')
    onClose: ->
      angular.element('body').css('overflow', 'auto')
    modalColor: 'white'
    opacity: 0.65


app = angular.module('luxhaven', ['ngCookies', 'ui.select2', 'ui.date'])
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