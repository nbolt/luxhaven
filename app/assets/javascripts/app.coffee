MULTIPLE_VALUE_ATTRS = {
  property_type: ['house', 'apartment']
}

SINGLE_VALUE_ATTRS = ['maxPrice', 'minPrice', 'sort', 'page']


AppCtrl = ($scope, $http, $q, $compile) ->
  $scope.signinContent = angular.element('#sign-in').html()
  $scope.signupContent = angular.element('#sign-up').html()
  $scope.forgotContent = angular.element('#forgot').html()
  $scope.auth = $q.defer()

  $http.post('/auth').success (rsp) ->
    if rsp.success
      $scope.signedIn = true
      $scope.user = JSON.parse rsp.user
      $scope.auth.resolve()
    else
      $scope.signedIn = false
      $scope.auth.reject()

  $scope.signInModal = (callback) ->
    angular.element('#modal').bPopup {
      onOpen:  ->
        angular.element('body').css('overflow', 'hidden')
        $scope.toSignin()
      onClose: ->
        angular.element('body').css('overflow', 'auto')
        callback() if callback
      modalColor: 'white'
      opacity: 0.65
    }

  $scope.toSignup = ->
    angular.element('#modal').html $compile($scope.signupContent)($scope)
    angular.element('#modal').removeClass('sign-in').removeClass('forgot').addClass('sign-up')

  $scope.toSignin = ->
    angular.element('#modal').html $compile($scope.signinContent)($scope)
    angular.element('#modal').removeClass('sign-up').removeClass('forgot').addClass('sign-in')

  $scope.toForgot = ->
    angular.element('#modal').html $compile($scope.forgotContent)($scope)
    angular.element('#modal').removeClass('sign-in').removeClass('sign-up').addClass('forgot')

  $scope.signOut = ->
    $http.post('/signout').success (rsp) ->
      $scope.signedIn = false
      $scope.user = null
      $http.defaults.headers.common['X-CSRF-Token'] = rsp.token
      angular.element('meta[name=csrf-token]').attr 'content', rsp.token

  reset_token = $.url().param 'reset_token'
  if reset_token
    $http.get("/check_reset_token?token=#{reset_token}").success (rsp) ->
      if rsp.success
        angular.element('#reset.modal').bPopup {
          onOpen:  ->
            angular.element('body').css('overflow', 'hidden')
          onClose: ->
            angular.element('body').css('overflow', 'auto')
          modalColor: 'white'
          opacity: 0.65
        }


HomeCtrl = ($scope, $http, $window) ->
  angular.element('#content-below-container')
    .css('margin-top', angular.element($window).height())
    .css('display', 'block')


SearchCtrl = ($scope, $http, $cookieStore, $window, $timeout) ->
  $scope.minPrice = null
  $scope.maxPrice = null
  $scope.pages    = null
  $scope.listings = []
  $scope.dates    = {}
  $scope.sort     = 'recommended'
  $scope.page = $.url().param 'page'; $scope.page ||= '1'

  angular.element('footer').css('display', 'none')

  $scope.checkInDate = (date) ->
    if moment() > moment(date)
      [false, '']
    else
      [true, '']

  $scope.checkOutDate = (date) ->
    if $scope.dates.check_in
      if moment($scope.dates.check_in) >= moment(date).subtract('days', 1) || moment() > moment(date).subtract 'days', 2
        [false, '']
      else
        [true, '']
    else
      [false, '']

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

  fetch_listings = (reset_page = true) ->
    $scope.page = 1 if reset_page
    angular.element('#listings .overlay').css 'display', 'block'
    angular.element.scrollTo '#results .right .top', 600, { easing: 'swing' }
    $http.get("/#{$scope.region.slug}#{urlAttrs()}").success (rsp) ->
      angular.element('#results .right').css 'display', 'block'
      angular.element('#listings .overlay').css 'display', 'none'
      $scope.listings = rsp.listings
      $scope.size = rsp.size
      $scope.pages = _.toArray _($scope.listings).groupBy (v,i) -> Math.floor i / 5
      angular.element('footer').css 'display', 'block'

  $scope.next = ->
    $scope.page = parseInt($scope.page) + 1
    fetch_listings false

  $scope.prev = ->
    $scope.page = parseInt($scope.page) - 1
    fetch_listings false

  $scope.nextShow = -> $scope.size > $scope.page * 5

  $scope.prevShow = -> parseInt($scope.page) > 1

  watch = (attrs) -> _(attrs).each (attr) -> $scope.$watch attr, (n, o) -> fetch_listings() unless o == n

  $scope.$watch 'dates', ((n, o) ->
    unless o == n
      check_in  = moment($scope.dates.check_in).format  'X' if $scope.dates.check_in
      check_out = moment($scope.dates.check_out).format 'X' if $scope.dates.check_out
      $cookieStore.put 'dates', { check_in: check_in, check_out: check_out }, { path: "/#{$scope.region.slug}" }
      if $scope.dates.check_out && moment($scope.dates.check_out).subtract('days', 1) <= moment(parseInt(check_in)*1000)
        $scope.dates.check_out = null
    ), true

  $scope.$watch 'sort', (n, o) -> fetch_listings() unless o == n

  $scope.$watch 'listings', ->
    $timeout(
      (-> angular.element('#results .left').css('height', angular.element('#results .right').height())),
      10
    )

  $scope.$watch 'region', -> fetch_listings() if $scope.region
  watch SINGLE_VALUE_ATTRS
  _(MULTIPLE_VALUE_ATTRS).each (attrs) -> watch attrs

  dates = $cookieStore.get 'dates'
  if dates
    $scope.dates.check_in  = new Date(parseInt(dates.check_in) * 1000)  if dates.check_in
    $scope.dates.check_out = new Date(parseInt(dates.check_out) * 1000) if dates.check_out


BookingCtrl = ($scope, $http, $timeout, $q) ->
  $scope.booking =
    guests: '1'
    arrival: { hour: '0', minute: '00' }
    departure: { hour: '0', minute: '00' }
    purpose: 'Leisure'
    where: 'Search engine'

  $scope.auth.promise.then(
    (-> $scope.card = $scope.user.cards[0] && $scope.user.cards[0].stripe_id || 'new_card'),
    (-> $scope.card = 'new_card')
  )

  $scope.new_card = -> $scope.card == 'new_card'

  $scope.step2 = ->
    angular.element('#book-modal .step1').removeClass 'active'
    angular.element('#book-modal .step2').addClass 'active'

  $scope.step3 = ->
    angular.element('#book-modal .step1').removeClass 'active'
    angular.element('#book-modal .step2').addClass 'active'

  $scope.close = ->
    angular.element('#book-modal').bPopup().close()

  error = (message) ->
    loader = angular.element('#book-modal .loader')
    error_element = angular.element('#book-modal .error')
    if loader.css('opacity') == '1'
      loader.css 'opacity', 0
      $timeout(
        (->
          error_element.css 'display', 'inline-block'
          error_element.css 'opacity', 1
          error_element.text message
        ), 500
      )
    else
      error_element.css 'display', 'inline-block'
      error_element.css 'opacity', 1
      error_element.text message

  loading = (promise) ->
    loader = angular.element('#book-modal .loader')
    error_element = angular.element('#book-modal .error')
    if error_element.css('display') == 'inline-block'
      error_element.css 'opacity', 0
      $timeout(
        (->
          error_element.css 'display', 'none'
          loader.css 'opacity', 1
          $timeout (-> promise.resolve()), 600
        ), 500
      )
    else
      loader.css 'opacity', 1
      $timeout (-> promise.resolve()), 600

  $scope.book = ->
    defer = $q.defer()
    
    disable = -> angular.element('#book-modal').find('button').prop('disabled', true)
    enable  = -> angular.element('#book-modal').find('button').prop('disabled', false)

    post = (card) ->
      $http.post("/#{$scope.region.slug}/#{$scope.listing.slug}/book", {
        check_in: $scope.dates.check_in
        check_out: $scope.dates.check_out
        card: card
      }).success (rsp) ->
        if rsp.success
          angular.element('#book-modal .loader').css 'opacity', 0
          angular.element('#book-modal .step2').removeClass 'active'
          angular.element('#book-modal .step3').addClass 'active'
          $scope.stripe_id = rsp.stripe_id
        else
          error rsp.error

    loading defer

    defer.promise.then(
      (->
        if $scope.card == 'new_card'
          Stripe.createToken {
            number: angular.element('#book-modal form input[data-stripe=number]').val()
            cvc: angular.element('#book-modal form input[data-stripe=cvc]').val()
            exp_month: angular.element('#book-modal form input[data-stripe=expiry]').val().split('/')[0]
            exp_year: angular.element('#book-modal form input[data-stripe=expiry]').val().split('/')[1]
          }, (_, rsp) ->
            if rsp.error
              error rsp.error.message
              enable()
            else
              post rsp.id
        else
          post $scope.card
      )
    )

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

  bookModal = ->
    angular.element('#book-modal').bPopup bPopOpts
    $http.get("/#{$scope.region.slug}/#{$scope.listing.slug}/pricing?check_in=#{$scope.dates.check_in}&check_out=#{$scope.dates.check_out}")
      .success (rsp) -> $scope.price_total = rsp.total

  $scope.bookModal = ->
    if $scope.dates.check_in && $scope.dates.check_out # && 2 days apart
      if $scope.signedIn
        bookModal()
      else
        $scope.signInModal -> bookModal() if $scope.signedIn

  $scope.checkInDate = (date) ->
    if $scope.listing && date
      valid = (_($scope.listing.bookings).every (booking) ->
          booking.check_out   <= moment(date) ||
          booking.check_in    >  moment(date).add 'days', 1
        ) && moment()         <  moment(date) &&
             moment(date)     <  moment($scope.dates.check_out).subtract 'days', 1
      valid && [true, ''] || [false, '']
    else
      [false, '']

  $scope.checkOutDate = (date) ->
    if $scope.listing && $scope.dates.check_in && date
      range = moment().range moment($scope.dates.check_in), moment(date).subtract('days', 1)
      valid = (_($scope.listing.bookings).every (booking) ->
          !range.contains(moment booking.check_in)
        ) && moment()     < moment(date).subtract('days', 1) &&
             moment(date) > moment($scope.dates.check_in).add 'days', 1
      valid && [true, ''] || [false, '']
    else
      [false, '']

  $scope.$watch 'dates', ((n, o) ->
    unless o == n
      if $scope.checkInDate($scope.dates.check_in)[0]
        check_in  = moment($scope.dates.check_in).format  'X'
        check_out = moment($scope.dates.check_out).format 'X' if $scope.dates.check_out
      $cookieStore.put 'dates', { check_in: check_in, check_out: check_out }, { path: "/#{$scope.region.slug}" }
      $scope.dates.check_out = null unless $scope.checkOutDate($scope.dates.check_out)[0]
    ), true

  bPopOpts =
    onOpen:  ->
      angular.element('body').css('overflow', 'hidden')
    onClose: ->
      angular.element('body').css('overflow', 'auto')
    modalColor: 'white'
    opacity: 0.65


ManageCtrl = ($scope, $http, $timeout) ->
  $scope.listing_updates = {}

  $scope.update = ->
    $http(
      method: 'PATCH'
      url:    $scope.url
      data:   { listing_updates: $scope.listing_updates }
    ).success ->
      angular.element('.rsp').css 'opacity', 1
      $timeout(
        (-> angular.element('.rsp').css 'opacity', 0),
        5000
      )

  $scope.$watch 'url', (n, o) ->
    if o != n && $scope.url
      $http.get($scope.url).success (listing) ->
        $scope.listing = listing
        for attr, value of listing
          if typeof(value) == 'object'
            for a, v of value
              el = angular.element("#listing-form [name=#{a}]")
              if el.is 'select'
                el.select2 'val', v
              else
                el.val v
          else
            angular.element("#listing-form input[name=#{attr}]").val value
    else
      $scope.listing = null


app = angular.module('luxhaven', ['ngCookies', 'ui.select2', 'ui.date', 'ui.mask'])
  .controller('app',      AppCtrl)
  .controller('home',     HomeCtrl)
  .controller('listings', SearchCtrl)
  .controller('listing',  ListingCtrl)
  .controller('booking',  BookingCtrl)
  .controller('manage',   ManageCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr('content')
  .service('$cookieStore', ->
    @get = (name) -> $.cookie name
    @put = (name, value, options) -> $.cookie name, value, options
    @remove = (name) -> $.removeCookie name
  )
  .directive('date', -> {
    scope: { date: '@date' }
    link: (scope, element, attrs) ->
      element.text moment(scope.date).format('ddd, Do MMM YYYY')
  })
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
  .directive('select2continuous', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').addClass 'continuous'
  )
  .directive('select2bordered', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').removeClass 'continuous'
  )
  .directive('unslider', -> (scope, element) ->
    element.unslider {
      speed: 800
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