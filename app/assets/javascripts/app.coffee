MULTIPLE_VALUE_ATTRS =
  property_type: ['house', 'townhouse', 'apartment']

SINGLE_VALUE_ATTRS = ['maxPrice', 'minPrice', 'sort', 'page', 'district', 'sleeps', 'beds', 'garden'
                      'balcony', 'parking', 'smoking', 'pets', 'children', 'babies', 'toddlers', 'tv'
                      'temp_control', 'pool', 'jacuzzi', 'washer']

PAGINATE_PER = 5

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
      analytics.identify $scope.user.id,
        name: "#{$scope.user.firstname} #{$scope.user.lastname}"
        email: $scope.user.email
        stripe_recipient: $scope.user.stripe_recipient
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

  $scope.logIn = ->
    $http.post('/signin', { email: $scope.email, password: $scope.password }).success (rsp) ->
      auth_response rsp

  $scope.signUp = ->
    if $scope.firstname && $scope.lastname && $scope.email && $scope.password && $scope.password_confirmation
      $http.post('/signup', {
        user:
          email: $scope.email
          firstname: $scope.firstname
          lastname: $scope.lastname
          password: $scope.password
          password_confirmation: $scope.password_confirmation
      }).success (rsp) -> auth_response rsp

  $scope.signOut = ->
    $http.post('/signout').success (rsp) ->
      $scope.signedIn = false
      $scope.user = null
      $http.defaults.headers.common['X-CSRF-Token'] = rsp.token
      angular.element('meta[name=csrf-token]').attr 'content', rsp.token

  auth_response = (rsp) ->
    if rsp.success
      angular.element('#modal .auth-error').text('')
      angular.element('#modal').bPopup().close()
      $scope.signedIn = true
      $scope.user = rsp.user
      $scope.email = null
      $scope.firstname = null
      $scope.lastname = null
      $scope.password = null
      $scope.password_confirmation = null
    else
      auth_error = angular.element('#modal .auth-error')
      if auth_error.css('display') == 'none'
        auth_error.text rsp.error_message
        auth_error.fadeIn()
      else
        auth_error.fadeOut 400, ->
          auth_error.text rsp.error_message
          auth_error.fadeIn()

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
    #.css('display', 'block')

  image = new Image()
  image.src = '/images/home.jpg'
  image.onload = ->
    angular.element('#home').css('opacity', '1')


SearchCtrl = ($scope, $http, $cookieStore, $window, $timeout) ->
  $scope.minPrice = null
  $scope.maxPrice = null
  $scope.pages    = null
  $scope.listings = []
  $scope.dates    = {}
  $scope.sort     = 'recommended'
  $scope.tab      = 'list'
  $scope.district = '0'
  $scope.page     = $.url().param 'page'; $scope.page ||= '1'
  $scope.region   = { slug: $.url().attr('directory').split('/')[1] }

  angular.element('footer').css('display', 'none')

  $http.get("/region/#{$scope.region.slug}").success (region) ->
    $scope.region = region
    image = new Image()
    image.src = region.image.url
    image.onload = ->
      angular.element('#city').css('background', "url(#{region.image.url}) no-repeat center").css('opacity', '1')

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

  $scope.syncDates = (date) ->
    check_in = moment(date).format  'X'
    if !$scope.dates.check_out || (moment($scope.dates.check_out).subtract('days', 1) <= moment(parseInt(check_in)*1000))
      check_in = new Date(Date.parse date)
      check_out = new Date(check_in.setDate check_in.getDate() + 2)
      $scope.dates.check_out = moment(check_out).format 'MM/DD/YYYY'

  $scope.nav = -> console.log 'sup'

  urlAttrs = ->
    str = '?'
    if $scope.dates.check_out
      str += "check_in=#{moment($scope.dates.check_in).format('X')}&check_out=#{moment($scope.dates.check_out).format('X')}&"

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
    angular.element('#results .right .overlay').css 'display', 'block'
    $http.get("/#{$scope.region.slug}#{urlAttrs()}").success (rsp) ->
      angular.element('#results .right').css 'display', 'inline-block'
      angular.element('#results .right .overlay').css 'display', 'none'
      $scope.listings = rsp.listings
      $scope.size = rsp.size
      #$scope.pages = _.toArray _($scope.listings).groupBy (v,i) -> Math.floor i / 5
      angular.element('footer').css 'display', 'block'

  $scope.nav = (n) ->
    $scope.page = n
    fetch_listings false
    angular.element.scrollTo '#results .right .top', 400, { easing: 'swing' }

  $scope.next = -> $scope.nav parseInt($scope.page) + 1
  $scope.prev = -> $scope.nav parseInt($scope.page) - 1

  $scope.nextShow = -> $scope.size > $scope.page * PAGINATE_PER && 'active'

  $scope.prevShow = -> parseInt($scope.page) > 1 && 'active'

  watch = (attrs) -> _(attrs).each (attr) -> $scope.$watch attr, (n, o) -> fetch_listings() unless o == n || attr == 'page'

  $scope.$watch 'dates', ((n, o) ->
    unless o == n
      check_in  = moment($scope.dates.check_in).format  'X' if $scope.dates.check_in
      check_out = moment($scope.dates.check_out).format 'X' if $scope.dates.check_out
      $cookieStore.put 'dates', { check_in: check_in, check_out: check_out }, { path: "/#{$scope.region.slug}" }
      if $scope.dates.check_out && moment($scope.dates.check_out).subtract('days', 1) <= moment(parseInt(check_in)*1000)
        $scope.dates.check_out = null
      fetch_listings() unless !n.check_out && !o.check_out
    ), true

  $scope.$watch 'sort', (n, o) -> fetch_listings() unless o == n

  $scope.$watch 'listings', ->
    $timeout(->
      left = angular.element('#results .left')
      right = angular.element('#results .right')
      height = parseInt left.css('height')
      left.css('height', right.height()) if right.height() > height
    )

  $scope.$watch 'region.slug', (n, o) -> window.location.href = "/#{$scope.region.slug}" unless o == n

  watch SINGLE_VALUE_ATTRS
  _(MULTIPLE_VALUE_ATTRS).each (attrs) -> watch attrs

  dates = $cookieStore.get 'dates'
  if dates
    $scope.dates.check_in  = moment(new Date(parseInt(dates.check_in) * 1000)).format 'MM/DD/YYYY'  if dates.check_in
    $scope.dates.check_out = moment(new Date(parseInt(dates.check_out) * 1000)).format 'MM/DD/YYYY' if dates.check_out

  fetch_listings()


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

  $scope.step = (step) ->
    angular.element('#book-modal .step').removeClass 'active'
    angular.element("#book-modal .step#{step}").addClass 'active'

  $scope.close = ->
    angular.element('#book-modal').bPopup().close()

  $scope.logIn = ->
    $http.post('/signin', { email: $scope.email, password: $scope.password }).success (rsp) ->
      auth_response rsp

  $scope.signUp = ->
    if $scope.firstname && $scope.lastname && $scope.email && $scope.password && $scope.password_confirmation
      $http.post('/signup', {
        user:
          email: $scope.email
          firstname: $scope.firstname
          lastname: $scope.lastname
          password: $scope.password
          password_confirmation: $scope.password_confirmation
      }).success (rsp) -> auth_response rsp

  $scope.toSignin = ->
    angular.element('.right .content .step2').scope().user = {}

  $scope.toSignup = ->
    angular.element('.right .content .step2').scope().user = null

  auth_response = (rsp) ->
    if rsp.success
      $scope.step(3)
      $scope.email = null
      $scope.firstname = null
      $scope.lastname = null
      $scope.password = null
      $scope.password_confirmation = null
    else
      auth_error = angular.element('#book-modal .auth-error')
      if auth_error.css('display') == 'none'
        auth_error.text rsp.error_message
        auth_error.fadeIn()
      else
        auth_error.fadeOut 400, ->
          auth_error.text rsp.error_message
          auth_error.fadeIn()

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
          angular.element('#book-modal .step').removeClass 'active'
          angular.element('#book-modal .step4').addClass 'active'
          $scope.stripe_id = rsp.charge.id
          analytics.track 'booking:booked',
            note: rsp.charge.id
            revenue: rsp.amount
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

ListingCtrl = ($scope, $http, $cookieStore, $timeout, $q) ->
  $scope.region   = { slug: $.url().attr('directory').split('/')[1] }
  $scope.dates    = {}
  $scope.listingQ = $q.defer()
  dates = $cookieStore.get 'dates'
  if dates
    $scope.dates.check_in  = moment(new Date(parseInt(dates.check_in) * 1000)).format 'MM/DD/YYYY'  if dates.check_in
    $scope.dates.check_out = moment(new Date(parseInt(dates.check_out) * 1000)).format 'MM/DD/YYYY' if dates.check_out

  $http.get("/region/#{$scope.region.slug}").success (region) -> $scope.region = region

  $http.get('').success (listing) ->
    listing.bookings = _(listing.bookings).reject (booking) ->
      booking.check_in  = moment booking.check_in
      booking.check_out = moment booking.check_out
      booking.check_out < moment Date.today || booking.payment_status != 'charged'
    $scope.auth.promise.then ->
      if $scope.user
        analytics.track 'listing:viewed',
          note: "#{$scope.region.slug}/#{listing.slug}"
    $scope.listing = listing
    $scope.listingQ.resolve()

  bookModal = ->
    angular.element('#book-modal').bPopup bPopOpts
    angular.element('#book-modal .step').removeClass 'active'
    angular.element('#book-modal .step1').addClass 'active'
    $http.get("/#{$scope.region.slug}/#{$scope.listing.slug}/pricing?check_in=#{moment($scope.dates.check_in).format('X')}&check_out=#{moment($scope.dates.check_out).format('X')}")
      .success (rsp) -> $scope.price_total = rsp.total

  $scope.bookModal = -> bookModal() if $scope.dates.check_out

  $scope.checkInDate = (date) ->
    if $scope.listing && date
      valid = (_($scope.listing.bookings).every (booking) ->
          booking.check_out   <= moment(date) ||
          booking.check_in    >  moment(date).add 'days', 1
        ) && moment()         <  moment(date)
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

  $scope.syncDates = (date) ->
    check_in = moment(date).format  'X'
    if !$scope.dates.check_out || (moment($scope.dates.check_out).subtract('days', 1) <= moment(parseInt(check_in)*1000))
      check_in = new Date(Date.parse date)
      check_out = new Date(check_in.setDate check_in.getDate() + 2)
      $scope.dates.check_out = moment(check_out).format 'MM/DD/YYYY'

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
      angular.element('.auth-error').hide()
    modalColor: 'white'
    opacity: 0.65

AccountCtrl = ($scope, $http, $timeout) ->

  $scope.update = ->
    $http.post('/account/update', { ssn: $scope.ssn, routing: $scope.routing, account: $scope.account })

ManageCtrl = ($scope, $http, $timeout) ->
  $scope.listing_updates = {}

  $http.get('/features').success (features) ->$scope.features = features
  $scope.update_info = ->
    $http(
      method: 'PATCH'
      url:    $scope.url
      data:   { listing_updates: $scope.listing_updates }
    ).success (rsp) -> $scope.url = rsp.url
     # angular.element('.rsp').css 'opacity', 1
     # $timeout(
     #   (-> angular.element('.rsp').css 'opacity', 0),
     #   5000
     # )

  $scope.$watch 'url', (n, o) ->
    if o != n && $scope.url
      $http.get($scope.url).success (listing) ->
        for attr, value of listing
          if typeof(value) == 'object'
            for a, v of value
              el = angular.element("#listing-form [name=#{a}]")
              if el.is 'select'
                el.select2 'val', v
              else
                el.val v
          else
            el = angular.element("#listing-form [name=#{attr}]")
            if el.is 'select'
              el.select2 'val', value
            else
              el.val value
        update_listing listing
    else
      $scope.listing = null

  $scope.new_listing = ->
    $http.post('/listings/create').success (rsp) ->
      $scope.url = rsp.url
      update_listing()

  $scope.update_paragraph = (paragraph) ->
    $http.post "/listing_management/#{paragraph.id}/update_paragraph", { content: paragraph.content, order: paragraph.order }

  $scope.remove_paragraph = (paragraph) ->
    paragraph.unbind_align()
    paragraph.unbind_version()
    $http.post("/listing_management/#{paragraph.id}/remove_paragraph").success -> update_listing()

  $scope.remove_image = (image) ->
    $http.post("/listing_management/#{image.id}/remove_image").success -> update_listing()

  $scope.remove_paragraph_image = (paragraph) ->
    $http.post("/listing_management/#{paragraph.id}/remove_paragraph_image").success -> update_listing()

  $scope.remove_header_image = (listing) ->
    $http.post("/listing_management/#{listing.id}/remove_header_image").success -> update_listing()

  $scope.remove_search_image = (listing) ->
    $http.post("/listing_management/#{listing.id}/remove_search_image").success -> update_listing()

  $scope.new_paragraph = ->
    $http.post("/listing_management/#{$scope.listing.id}/new_paragraph").success (paragraph) ->
      $scope.listing.paragraphs.push paragraph

  $scope.new_room = ->
    $http.post("/listing_management/#{$scope.listing.id}/new_room", { name: $scope.new_room_name })
      .success -> update_listing()

  $scope.update_room = (el, room) ->
    features = angular.element(el).parent().children('.features').select2 'val'
    $http.post("/listing_management/#{room.id}/update_room", { features: features, images: room.new_images })
      .success -> update_listing()

  $scope.update_features = (el) ->
    features = angular.element(el).parent().children('.features').select2 'val'
    $http.post("/listing_management/#{$scope.listing.id}/update_features", { features: features })
      .success -> update_listing()

  $scope.new_image = (el, scope) ->
    xhr = new XMLHttpRequest()
    xhr.overrideMimeType 'text/plain; charset=x-user-defined-binary'
    xhr.open 'POST', "/listing_management/#{scope.listing.id}/new_image"

    reader = new FileReader()
    reader.onload = (e) -> xhr.sendAsBinary e.target.result

    xhr.upload.addEventListener 'load', (-> update_listing();angular.element('.images input').val('')), false

    reader.readAsBinaryString el.files[0]

  $scope.new_header_image = (el, scope) ->
    xhr = new XMLHttpRequest()
    xhr.overrideMimeType 'text/plain; charset=x-user-defined-binary'
    xhr.open 'POST', "/listing_management/#{scope.listing.id}/new_header_image"

    reader = new FileReader()
    reader.onload = (e) -> xhr.sendAsBinary e.target.result

    xhr.upload.addEventListener 'load', (-> update_listing()), false

    reader.readAsBinaryString el.files[0]

  $scope.new_search_image = (el, scope) ->
    xhr = new XMLHttpRequest()
    xhr.overrideMimeType 'text/plain; charset=x-user-defined-binary'
    xhr.open 'POST', "/listing_management/#{scope.listing.id}/new_search_image"

    reader = new FileReader()
    reader.onload = (e) -> xhr.sendAsBinary e.target.result

    xhr.upload.addEventListener 'load', (-> update_listing()), false

    reader.readAsBinaryString el.files[0]

  $scope.new_paragraph_image = (el, scope) ->
    xhr = new XMLHttpRequest()
    xhr.overrideMimeType 'text/plain; charset=x-user-defined-binary'
    xhr.open 'POST', "/listing_management/#{scope.paragraph.id}/new_paragraph_image"

    reader = new FileReader()
    reader.onload = (e) -> xhr.sendAsBinary e.target.result

    xhr.upload.addEventListener 'load', (-> update_listing()), false

    reader.readAsBinaryString el.files[0]

  update_listing = (listing) ->
    if listing
      $scope.listing = listing
      post_listing_update()
    else
      $http.get($scope.url).success (listing) ->
        $scope.listing = listing
        post_listing_update()

  post_listing_update = ->
    set_feature_list()
    set_new_room_attrs()
    bind_paragraph_images()

  set_feature_list = ->
    feature_list = _($scope.listing.features).map((f) -> f.name).join ','
    angular.element('.section.features input').val(feature_list).trigger 'change'

  set_new_room_attrs = ->
    _($scope.listing.rooms).each (room) ->
      room.new_features = _(room.features).map((f) -> f.name).join ','
      room.new_images = _(_(_($scope.listing.images).sortBy((i) -> i.created_at)).map(
        (img, index) -> if _(room.images).any((i) -> img.id is i.id) then index+1
      )).compact().join ' '

  bind_paragraph_images = (paragraphs) ->
    _($scope.listing.paragraphs).each (paragraph) ->
      if paragraph.image
        paragraph.unbind_align =
          $scope.$watch (->paragraph.image.align), (n, o) -> update_alignment(paragraph) unless o == n
        paragraph.unbind_version =
          $scope.$watch (->paragraph.image.version), (n, o) -> update_version(paragraph) unless o == n

  update_alignment = (paragraph) ->
    $http.post "/listing_management/#{paragraph.id}/update_alignment", { alignment: paragraph.image.align }

  update_version = (paragraph) ->
    $http.post "/listing_management/#{paragraph.id}/update_version", { version: paragraph.image.version }


app = angular.module('luxhaven', ['ngCookies', 'ui.select2', 'ui.date', 'ui.mask'])
  .controller('app',      AppCtrl)
  .controller('home',     HomeCtrl)
  .controller('listings', SearchCtrl)
  .controller('listing',  ListingCtrl)
  .controller('booking',  BookingCtrl)
  .controller('manage',   ManageCtrl)
  .controller('account',  AccountCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr('content')
  .service('$cookieStore', ->
    @get = (name) -> $.cookie name
    @put = (name, value, options) -> $.cookie name, value, options
    @remove = (name) -> $.removeCookie name
  )
  .directive('date', -> (scope, element, attrs) ->
    scope.$watch (-> scope.dates[attrs.date]), (n, o) ->
      element.text moment(n).format('ddd, Do MMM YYYY')
  )
  .directive('bgImage', ($timeout) -> (scope, element, attrs) ->
    $timeout(
      (->
        image = new Image()
        image.src = attrs.bgImage
        image.onload = ->
          element.css('background-image', "url(#{attrs.bgImage})").css('opacity', '1')
      )
    )
  )
  .directive('view', -> (scope, element) ->
    new View element.find 'a.view'
  )
  .directive('viewRoom', -> (scope, element, attrs) ->
    scope.views = {}
    scope.listingQ.promise.then ->
      images = scope.listing.rooms[parseInt attrs.viewRoom].images
      if images
        images = _(images).map (i) -> i.image.url
        scope.views[attrs.viewRoom] =
          images: images
          view: new View images
  )
  .directive('paginate', ($compile) -> (scope, element) ->
    scope.update_pagination = (n, o) ->
      unless o == n
        element.html ''
        pages = Math.ceil scope.size / PAGINATE_PER
        for i in [1..pages]
          active = i < 4 || i > (pages - 3) || (i >= scope.page && i < scope.page + 3) || (i <= scope.page && i > scope.page - 3)
          if active
            element.append $compile("<span class='num' ng:click='nav(#{i})'>#{i}</span>")(scope)
            element.children().last().addClass 'current' if i == scope.page
          else
            element.append "<span>...</span>" unless element.children().last().text() == '...'

    scope.$watch 'page', scope.update_pagination
    scope.$watch 'size', scope.update_pagination
  )
  .directive('searchTab', ($timeout) -> (scope, element, attrs) ->
    element.click -> scope.$apply ->
      angular.element('.tabs .tab').removeClass 'active'
      element.addClass 'active'
      if attrs.searchTab == 'map' && !scope.map
        scope.tab = attrs.searchTab
        $timeout(
          (->
            angular.element('#results').css('width', '95%').css('background-color', 'white')
            angular.element('#results').css('margin-top', '245px')
            angular.element('#results').animate({'margin-top': '80'},400,'linear')
            angular.element('#results .left')
              .css('height', angular.element(window).height() - 80).css('overflow-y', 'scroll')
            angular.element('#city')
              .css('position', 'absolute').css('right', '0').css('left', '0')
              .fadeOut 400
            angular.element('footer').css('display', 'none')
            angular.element.scrollTo 0, 400, { easing: 'swing' }
            $timeout(
              (-> 
                  scope.map = new GMaps
                    div: 'map'
                    lat: scope.region.latitude
                    lng: scope.region.longitude
                    zoom: 12
                  _(scope.listings).each (listing) ->
                    if listing.address.latitude
                      scope.map.addMarker
                        lat: listing.address.latitude
                        lng: listing.address.longitude
                        title: listing.title
              ), 500)
          )
        )
      else if attrs.searchTab == 'list'
        angular.element('#map').hide()
        angular.element('#results').css('width', '976px')
        angular.element('#results .left').css('height', 'inherit').css('overflow', 'auto')
        angular.element('#results').animate({'margin-top': '325'},400,'linear')
        angular.element('#city').fadeIn(400, ->
          angular.element('#city').css('position', 'relative')
          angular.element('#results').css('margin', 'auto')
          scope.$apply ->
            scope.tab = attrs.searchTab
            $timeout(->
              angular.element('.pages').scope().update_pagination(0,1)
              left = angular.element('#results .left')
              right = angular.element('#results .right')
              height = parseInt left.css('height')
              left.css('height', right.height()) if right.height() > height
            )
          )
        angular.element('footer').css('display', 'block')
        scope.map = null
  )
  .directive('tab', ($timeout) -> (scope, element, attrs) ->
    element.click ->
      element.parent().children('a').removeClass 'active'
      element.addClass 'active'
      tabContent = element.parent().parent().children('.tab-content')
      tabContent.children('.tab').removeClass 'active'
      tabContent.children(attrs.href).addClass 'active'
      if attrs.href == '#local-area'
        $timeout(-> angular.element(attrs.href).scope().toMap())
  )
  .directive('localArea', -> (scope, element, attrs) ->
    scope.toMap = (e) ->
      angular.element('#local-area .links span').removeClass 'active'
      angular.element('#local-area .links span:first').addClass 'active'
      scope.mapType = 'map'
      address = scope.listing.address
      GMaps.geocode
        address: "#{address.neighborhood}, #{address.city}"
        callback: (results, status) ->
          latlng = results[0].geometry.location
          new GMaps
            div: 'map'
            lat: latlng.lat()
            lng: latlng.lng()
            zoom: 15
    scope.toStreet = ->
      angular.element('#local-area .links span').removeClass 'active'
      angular.element('#local-area .links span:last').addClass 'active'
      scope.mapType = 'pano'
      address = scope.listing.address
      GMaps.geocode
        address: "#{address.neighborhood}, #{address.city}"
        callback: (results, status) ->
          latlng = results[0].geometry.location
          GMaps.createPanorama
            el: '#pano'
            lat: latlng.lat()
            lng: latlng.lng()
  )
  .directive('select2continuous', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').addClass 'continuous'
  )
  .directive('select2bordered', -> (scope, element) ->
    element.on 'select2-opening', ->
      angular.element('.select2-drop').removeClass 'continuous'
  )
  .directive('select2FeatureTags', ($timeout) -> (scope, element) ->
    $timeout ->
      element.select2
        tags: _(scope.features).map (f) -> f.name
        initSelection: (e,c) -> c _(e.val().split(',')).map (f) -> { text: f, id: f }
  )
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