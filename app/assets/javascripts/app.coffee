MULTIPLE_VALUE_ATTRS = {
  property_type: ['house', 'apartment']
}

SINGLE_VALUE_ATTRS = ['maxPrice', 'minPrice', 'sort']


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

HomeCtrl = ($scope, $http, $window) ->
  angular.element('#content-below-container')
    .css('margin-top', angular.element($window).height())
    .css('display', 'block')

SearchCtrl = ($scope, $http, $cookieStore, $window, $timeout) ->
  $scope.minPrice = null
  $scope.maxPrice = null
  $scope.pages    = null
  $scope.dates    = {}
  $scope.sort     = 'recommended'

  $scope.checkInDate = (date) ->
    if $scope.dates.check_out
      if moment() > moment(date)
        [false, '']
      else
        [true, '']
    else
      [true, '']

  $scope.checkOutDate = (date) ->
    if $scope.dates.check_in
      if $scope.dates.check_in >= date || moment() > moment(date).subtract 'days', 1
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
    $http.get("/#{$scope.region.slug}#{urlAttrs()}").success (rsp) ->
      $scope.listings = rsp
      $scope.pages = _.toArray _($scope.listings).groupBy (v,i) -> Math.floor i / 1

  watch = (attrs) -> _(attrs).each (attr) -> $scope.$watch attr, (n, o) -> fetch_listings() unless o == n

  $scope.$watch 'dates', ((n, o) ->
    unless o == n
      check_in  = moment($scope.dates.check_in).format  'X' if $scope.dates.check_in
      check_out = moment($scope.dates.check_out).format 'X' if $scope.dates.check_out
      $cookieStore.put 'dates', { check_in: check_in, check_out: check_out }, { path: '/' }
      if $scope.dates.check_out && moment($scope.dates.check_out) <= moment(parseInt(check_in)*1000)
        $scope.dates.check_out = null
    ), true

  $scope.$watch 'sort', (n, o) -> fetch_listings() unless o == n

  $scope.$watch 'listings', ->
    $timeout(
      (-> angular.element('#results .left').css('height', angular.element('#results .right').height())),
      100
    )

  $scope.$watch 'region', -> fetch_listings() if $scope.region
  watch SINGLE_VALUE_ATTRS
  _(MULTIPLE_VALUE_ATTRS).each (attrs) -> watch attrs

  dates = $cookieStore.get 'dates'
  if dates
    $scope.dates.check_in  = new Date(parseInt(dates.check_in) * 1000)  if dates.check_in
    $scope.dates.check_out = new Date(parseInt(dates.check_out) * 1000) if dates.check_out


ListingCtrl = ($scope, $http, $cookieStore) ->
  $scope.region    = null
  $scope.dates     = {}
  dates = $cookieStore.get 'dates'
  if dates
    $scope.dates.check_in  = new Date(parseInt(dates.check_in) * 1000)  if dates.check_in
    $scope.dates.check_out = new Date(parseInt(dates.check_out) * 1000) if dates.check_out

  $http.get('').success (listing) ->
    listing.bookings = _(listing.bookings).reject (booking) ->
      booking.check_in  = moment booking.check_in
      booking.check_out = moment booking.check_out
      booking.check_out < moment Date.today || booking.payment_status != 'charged'
    $scope.listing = listing

  $scope.new_card = -> $scope.card == 'new_card'

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
          check_in: $scope.dates.check_in
          check_out: $scope.dates.check_out
          card: rsp.id
        }).success (rsp) ->
          console.log rsp
          angular.element('#book-modal').bPopup().close()
    false

  $scope.book = ->
    form = angular.element('#book-modal .payment form')

    disable = -> angular.element('#book-modal').find('button').prop('disabled', true)
    enable  = -> angular.element('#book-modal').find('button').prop('disabled', false)

    post = (card) ->
      $http.post("/#{$scope.region.slug}/#{$scope.listing.slug}/book", {
        check_in: $scope.dates.check_in
        check_out: $scope.dates.check_out
        card: card
      }).success (rsp) ->
        console.log rsp
        angular.element('#book-modal').bPopup().close()

    if $scope.card == 'new_card'
      Stripe.createToken form, (_, rsp) ->
        if rsp.error
          console.log rsp.error.message
          enable()
        else
          post rsp.id
    else
      post $scope.card

  $scope.bookModal = ->
    if $scope.dates.check_in && $scope.dates.check_out # && 2 days apart
      if $scope.signedIn
        angular.element('#book-modal').bPopup bPopOpts
      else
        $scope.signInModal -> angular.element('#book-modal').bPopup bPopOpts if $scope.signedIn

  $scope.checkInDate = (date) ->
    if $scope.listing
      valid = (_($scope.listing.bookings).every (booking) ->
          booking.check_out   <= moment(date) ||
          booking.check_in    >  moment(date).add 'days', 2
        ) && moment()         <  moment(date)
      valid && [true, ''] || [false, '']
    else
      [false, '']

  $scope.checkOutDate = (date) ->
    if $scope.listing
      valid = (_($scope.listing.bookings).every (booking) ->
          booking.check_out  < moment(date) ||
          booking.check_in   > moment(date)
        ) && moment()        < moment(date).subtract('days', 1) &&
             ($scope.dates.check_in < date || !$scope.dates.check_in)

      valid && [true, ''] || [false, '']
    else
      [false, '']

  $scope.$watch 'dates', ((n, o) ->
    unless o == n
      check_in  = moment($scope.dates.check_in).format  'X' if $scope.dates.check_in
      check_out = moment($scope.dates.check_out).format 'X' if $scope.dates.check_out
      #$cookieStore.put 'dates', { check_in: check_in, check_out: check_out }
      if $scope.dates.check_out && moment($scope.dates.check_out) <= moment(parseInt(check_in)*1000)
        $scope.dates.check_out = null
    ), true

  bPopOpts =
    onOpen:  ->
      angular.element('body').css('overflow', 'hidden')
    onClose: ->
      angular.element('body').css('overflow', 'auto')
    modalColor: 'white'
    opacity: 0.65


app = angular.module('luxhaven', ['ngCookies', 'ui.select2', 'ui.date'])
  .controller('app',      AppCtrl)
  .controller('home',     HomeCtrl)
  .controller('listings', SearchCtrl)
  .controller('listing',  ListingCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr('content')
  .directive('tab', -> (scope, element, attrs) ->
    element.click ->
      element.parent().children('a').removeClass 'active'
      element.addClass 'active'
      tabContent = element.parent().parent().children('.tab-content')
      tabContent.children('.tab').removeClass 'active'
      tabContent.children(attrs.href).addClass 'active'
      if attrs.href == '#local-area'
        scope.map = L.map('map').setView [attrs.lat, attrs.lng], 15 unless scope.map
        L.tileLayer.provider('OpenStreetMap.Mapnik').addTo scope.map
  )
  .directive('select2city', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').removeClass('sort').addClass 'city'
  )
  .directive('select2sort', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').removeClass('city').addClass 'sort'
  )
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