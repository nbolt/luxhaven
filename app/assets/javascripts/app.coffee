MULTIPLE_VALUE_ATTRS =
  property_type: ['house', 'townhouse', 'apartment']

SINGLE_VALUE_ATTRS = ['maxPrice', 'minPrice', 'sort', 'page', 'district', 'sleeps', 'beds', 'garden'
                      'balcony', 'parking', 'smoking', 'pets', 'children', 'babies', 'toddlers', 'tv'
                      'temp_control', 'pool', 'jacuzzi', 'washer']

PAGINATE_PER = 5

String.prototype.hash = ->
  this.split('').reduce(
    ((a,b) -> a=((a<<5)-a)+b.charCodeAt(0);a&a),
    0
  )

AppCtrl = ($scope, $http, $q, $compile, $timeout) ->
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
      Raven.setUser
        email: $scope.user.email
        id: $scope.user.id
    else
      $scope.signedIn = false
      $scope.auth.reject()

  $scope.signInModal = (callback) ->
    angular.element('#modal').bPopup
      onOpen:  ->
        angular.element('body').css('overflow', 'hidden')
        $scope.toSignin()
      onClose: ->
        angular.element('body').css('overflow', 'auto')
        callback() if callback
      modalColor: 'white'
      opacity: 0.65
      position: ['auto', -1]
      transition: 'slideDown'

    null

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
    angular.element('#modal button').addClass('disabled')
    $http.post('/signin', { email: $scope.email, password: $scope.password }).success (rsp) ->
      auth_response rsp

  $scope.signUp = ->
    if $scope.firstname && $scope.lastname && $scope.email && $scope.password && $scope.password_confirmation
      angular.element('#modal button').addClass('disabled')
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
    angular.element('#modal button').removeClass('disabled')
    if rsp.success
      angular.element('#modal .auth-rsp').text('')
      angular.element('#modal').bPopup().close()
      $scope.signedIn = true
      $scope.user = rsp.user
      $scope.email = null
      $scope.firstname = null
      $scope.lastname = null
      $scope.password = null
      $scope.password_confirmation = null
      analytics.identify $scope.user.id,
        name: "#{$scope.user.firstname} #{$scope.user.lastname}"
        email: $scope.user.email
        stripe_recipient: $scope.user.stripe_recipient
      Raven.setUser
        email: $scope.user.email
        id: $scope.user.id
    else
      auth_error = angular.element('#modal .auth-rsp')
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
        $timeout((->
          angular.element('#reset.modal').bPopup
            onOpen:  ->
              angular.element('body').css('overflow', 'hidden')
            onClose: ->
              angular.element('body').css('overflow', 'auto')
            modalColor: 'white'
            opacity: 0.65
            position: ['auto', -1]
            transition: 'slideDown')
        ,600)


HomeCtrl = ($scope, $http, $window) ->
  angular.element('#content-below-container')
    .css('margin-top', angular.element($window).height())
    .css('display', 'block')

  image = new Image()
  image.src = '/images/home.jpg'
  image.onload = ->
    angular.element('#home').css('opacity', '1')

EnquiryCtrl = ($scope, $http) ->
  $scope.enquiry  = { type: 'booking', check_in: '10/19/1990', currency: 'usd', with_children: false }

  $scope.enquire = ->
    angular.element('#enquiry button').addClass 'disabled'
    $http.post('/enquire', { enquiry: $scope.enquiry }).success ->
      angular.element('#enquiry .auth-rsp').text "You're enquiry has been sent! You'll hear from a representative shortly."
      angular.element('#enquiry .auth-rsp').fadeIn()
      setTimeout((->
        angular.element('#enquiry').bPopup().close()
        angular.element('#enquiry button').removeClass 'disabled'
      ),5000)

SearchCtrl = ($scope, $http, $cookieStore, $window, $timeout) ->
  $scope.minPrice = null
  $scope.maxPrice = null
  $scope.pages    = null
  $scope.listings = []
  $scope.dates    = {}
  $scope.sort     = 'recommended'
  $scope.tab      = 'list'
  $scope.ptab     = 'list'
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

  $scope.enquiry = ->
    angular.element.scrollTo 1775, 400, { easing: 'swing' }
    angular.element('#enquiry').bPopup bPopOpts; null

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
    check_in = moment(date).format 'X'
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
      $scope.all_listings = rsp.all_listings
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

  bPopOpts =
    modalColor: 'white'
    opacity: 0.65
    follow: [true, false]
    position: ['auto', 1800]


BookingCtrl = ($scope, $http, $timeout, $q) ->
  $scope.tab = 'debit'
  $scope.booking =
    guests: '1'
    arrival: { hour: '0', minute: '00' }
    departure: { hour: '0', minute: '00' }
    purpose: 'Leisure'
    where: 'Search engine'

  $scope.existing_cards = -> $scope.user && !!$scope.user.cards[0]

  $scope.choose_card = (card) -> $scope.card = card.stripe_id

  $scope.card_active = (card) -> card.stripe_id == $scope.card && 'chosen' || ''

  $scope.tab_active = (tab) -> $scope.tab == tab && 'active' || ''

  $scope.step = (step) ->
    angular.element('#book-modal .step').removeClass 'active'
    angular.element("#book-modal .step#{step}").addClass 'active'
    null

  $scope.close = ->
    angular.element('#book-modal').bPopup().close()
    null

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
    null

  $scope.toSignup = ->
    angular.element('.right .content .step2').scope().user = null
    null

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

  disable = -> angular.element('#book-modal').find('button').prop('disabled', true).addClass 'disabled'
  enable  = -> angular.element('#book-modal').find('button').prop('disabled', false).removeClass 'disabled'

  error = (message) ->
    enable()
    error_element = angular.element('#book-modal .error')
    if error_element.css('opacity') == '1'
      error_element.css 'opacity', 0
      $timeout(
        (->
          error_element.text message
          error_element.css 'opacity', 1
        ), 600
      )
    else
      error_element.text message
      error_element.css 'opacity', 1

  $scope.book = (existing) ->
    defer = $q.defer()

    post = (card) ->
      $http.post("/#{$scope.region.slug}/#{$scope.listing.slug}/book", {
        check_in: $scope.dates.check_in
        check_out: $scope.dates.check_out
        card: card
      }).success (rsp) ->
        if rsp.success
          enable()
          angular.element('#book-modal .loader').css 'opacity', 0
          angular.element('#book-modal .step').removeClass 'active'
          angular.element('#book-modal .step4').addClass 'active'
          $scope.stripe_id = rsp.charge.id
          analytics.track 'booking:booked',
            note: rsp.charge.id
            revenue: rsp.amount
        else
          error rsp.error

    disable()

    if existing
      if $scope.card
        post $scope.card
      else
        if $scope.user.cards.length == 1
          post $scope.user.cards[0].stripe_id
        else
          enable()
    else
      Stripe.createToken {
        number: angular.element('#book-modal form input[data-stripe=number]').val()
        cvc: angular.element('#book-modal form input[data-stripe=cvc]').val()
        exp_month: angular.element('#book-modal form input[data-stripe=expiry]').val().split('/')[0]
        exp_year: angular.element('#book-modal form input[data-stripe=expiry]').val().split('/')[1]
      }, (_, rsp) ->
        if rsp.error
          error rsp.error.message
        else
          post rsp.id

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
    angular.element('span.ui-state')
    if $scope.listing && date
      valid = (date) ->
        (_($scope.listing.bookings).every (booking) ->
          booking.check_out   <= moment(date) ||
          booking.check_in    >  moment(date).add 'days', 1
        ) && moment()         <  moment(date)
      if valid(date)
        [true, '']
      else
        d1 = new Date(date.getTime())
        d1.setDate(d1.getDate()-1)
        d2 = new Date(date.getTime())
        d2.setDate(d2.getDate()-2)
        if valid(d1) || valid(d2)
          tFunc = (date) ->
            $timeout(->
              angular.element('#ui-datepicker-div span.ui-state-default').filter(
                (-> angular.element(@).text() is date.getDate().toString())
              ).each -> angular.element(@).parent().removeClass 'ui-state-disabled'
            )
          tFunc(new Date(date.getTime()))
        [false, '']
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
    unless $scope.checkOutDate($scope.dates.check_out)[0]
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
      price = angular.element('#listing-content .right .price-container')
      if $scope.dates.check_in && $scope.dates.check_out
        new_price = null
        $http.get("/#{$scope.region.slug}/#{$scope.listing.slug}/pricing?check_in=#{moment($scope.dates.check_in).format('X')}&check_out=#{moment($scope.dates.check_out).format('X')}")
          .success (rsp) -> new_price = rsp.total
        price.animate {opacity:0}, 400
        int = setInterval((->
          if price.css('opacity') == '0' && new_price
            price.animate {opacity:1}, 400
            price.children('.from').text 'Subtotal'
            price.children('.price').text '$' + new_price
            clearInterval int
        ),50)
      else
        price.animate {opacity:0}, 400
        int = setInterval((->
          if price.css('opacity') == '0'
            price.animate {opacity:1}, 400
            price.children('.from').text 'From'
            price.children('.price').text('$' + $scope.listing.price_per_night / 100)
            clearInterval int
        ),50)
    ), true

  bPopOpts =
    modalColor: 'white'
    opacity: 0.65
    follow: [true, false]

AccountCtrl = ($scope, $http, $timeout) ->

  $scope.update = ->
    $http.post('/account/update', { ssn: $scope.ssn, routing: $scope.routing, account: $scope.account })

ManageCtrl = ($scope, $http, $timeout) ->
  $scope.listing_updates = {}

  $http.get('/features').success (features) -> $scope.features = features
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
        angular.element('.section.search textarea').val listing.search_description
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

    xhr.upload.addEventListener 'load', (->
      $timeout((-> update_listing()),2000)
      angular.element('.images input').val('')
    ), false

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
  .controller('enquiry',  EnquiryCtrl)
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element('meta[name=csrf-token]').attr 'content'
  .factory('$cookieStore', ->
    get: -> (name) -> $.cookie name
    put: -> (name, value, options) -> $.cookie name, value, options
    remove: -> (name) -> $.removeCookie name
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
  .directive('paymentTab', -> (scope, element, attrs) ->
    element.click -> scope.$apply -> scope.tab = attrs.paymentTab
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
        unless pages == 0
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
    scope.overlays = {}
    element.click ->
      angular.element('.tabs .tab').removeClass 'active'
      element.addClass 'active'
      if attrs.searchTab != 'map' && scope.ptab == 'map'
        angular.element('#map').hide()
        angular.element('#results').css('width', '976px')
        angular.element('#results .left').css('height', 'inherit').css('overflow', 'auto')
        angular.element('#results .left').css('margin-left', 'inherit')
        angular.element('#results').animate({'margin-top': '325'},400,'linear') if scope.ptab is 'map'
        angular.element('#city').fadeIn(400, ->
          angular.element('#city').css('position', 'relative')
          angular.element('#results').css('margin', 'auto')
          scope.$apply -> scope.tab = attrs.searchTab
        )
      if attrs.searchTab == 'map'
        scope.$apply -> scope.tab = attrs.searchTab
        $timeout(
          (->
            angular.element('#results').css('width', '100%').css('background-color', 'white')
            angular.element('#results').css('margin-top', '245px')
            angular.element('#results').animate({'margin-top': '80'},400,'linear')
            angular.element('#results .left').animate({'margin-left': '25'},400,'linear')
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
                  _(scope.all_listings).each (listing) ->
                    if listing.address.latitude
                      scope.map.addMarker
                        lat: listing.address.latitude
                        lng: listing.address.longitude
                        title: listing.title
                        icon: '/images/house-marker.png'
                        mouseover: (e) ->
                          hash = e.latLng.toUrlValue().hash()
                          o = scope.map.drawOverlay
                            lat: e.latLng.lat()
                            lng: e.latLng.lng()
                            layer: 'floatPane'
                            content: "
                              <div class='map-overlay hash#{hash}'>
                                <div class='content'>
                                  <div class='padding'>
                                    <div class='fotorama' data-width='230' data-height='130' data-keyboard='false' data-swipe='false' data-arrows='true' data-nav='false'>
                                      #{_(listing.images).map((i) -> "<a href='#{i.image.map.url}.jpg'></a>").join('')}
                                    </div>
                                    <div class='name-price'>
                                      <div class='name'>
                                        <div class='title'>#{listing.title}</div>
                                        <div class='neighborhood'>#{listing.address.neighborhood}, #{listing.address.city}</div>
                                      </div>
                                      <div class='price'>
                                        <div class='from'>From</div>
                                        <div class='amount'>$#{listing.price_per_night / 100}</div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class='info'>
                                    <div class='people room' ng:switch='listing.accomodates_to'>
                                      <div class='icon'></div>
                                      <div class='text'>#{listing.accomodates_to}</div>
                                    </div>
                                    <div class='bedrooms room'>
                                      <div class='icon'></div>
                                      <div class='text'>#{listing.bedrooms}</div>
                                    </div>
                                    <div class='baths room' ng:switch='listing.baths'>
                                      <div class='icon'></div>
                                      <div class='text'>#{listing.baths}</div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            "
                          setTimeout(
                            (->
                              angular.element(".map-overlay.hash#{hash}").fadeIn()
                              angular.element(".map-overlay.hash#{hash}").mouseleave -> angular.element(@).fadeOut 400, -> scope.map.removeOverlay o
                              angular.element(".map-overlay.hash#{hash} .fotorama").fotorama()
                            ),
                            50
                          )
              ), 500)
          )
        )
      else if attrs.searchTab == 'list'
        scope.$apply -> scope.tab = attrs.searchTab if scope.ptab == 'guide'
        interval = setInterval((->
          if angular.element('.pages').scope()
            clearInterval interval
            angular.element('.pages').scope().update_pagination(0,1)
            left = angular.element('#results .left')
            right = angular.element('#results .right')
            height = parseInt left.css('height')
            left.css('height', right.height()) if right.height() > height
          ),50
        )
        angular.element('footer').css('display', 'block')
        scope.map = null
      else if attrs.searchTab == 'guide'
        scope.$apply -> scope.tab = attrs.searchTab if scope.ptab == 'list'
      scope.ptab = attrs.searchTab
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
  .directive('localArea', ($timeout) -> (scope, element, attrs) ->
    scope.listingQ.promise.then ->
      address = scope.listing.address
      GMaps.geocode
        address: "#{address.street1} #{address.city} #{address.state} #{address.zip}"
        callback: (results, status) ->
          latLng = results[0].geometry.location

          u = Math.random(); v = Math.random()
          w = 0.0035 * Math.sqrt(u)
          t = 2 * Math.PI * v
          x = (w * Math.cos(t)) / Math.cos(latLng.lat())
          y = w * Math.sin(t)

          lng = x + latLng.lng()
          lat = y + latLng.lat()
          latlng = new google.maps.LatLng lat, lng

          webService = new google.maps.StreetViewService()
          webService.getPanoramaByLocation latlng, 1000, (pano) -> scope.latLng = pano.location.latLng

      scope.toMap = (e) ->
        angular.element('#local-area .links span').removeClass 'active'
        angular.element('#local-area .links span:first').addClass 'active'
        scope.mapType = 'map'
        $timeout(->
          map = new GMaps
            div: 'map'
            lat: scope.latLng.lat()
            lng: scope.latLng.lng()
            zoom: 15
          map.drawCircle
            center: scope.latLng
            radius: 400
            fillColor: 'hsl(159, 69%, 44%)'
            strokeColor: 'hsl(159, 69%, 44%)'
            strokeWeight: 1
        )

      scope.toStreet = ->
        angular.element('#local-area .links span').removeClass 'active'
        angular.element('#local-area .links span:last').addClass 'active'
        scope.mapType = 'pano'
        $timeout(->
          GMaps.createPanorama
            el: '#pano'
            lat: scope.latLng.lat()
            lng: scope.latLng.lng()
        )
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
  .directive 'calendar', ->
    link: (scope, element) ->
      days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      _month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      booked = []
      
      gen_cal = (cal, month, year) ->
        calendar = $('#availability table').eq(cal)
        calendar.find('thead th.month').attr('month', month)
        calendar.find('thead th.month').attr('year', year)
        first_day = new Date(year, month, 1).getDay()
        month_name = months[month]
        month_days = _month_days[month]
        month_days = if month == 1 && (year % 4 == 0 && year % 100 != 0 || year % 400 == 0) then 29 else month_days
        prev_month_days = if month == 0 then _month_days[11] else _month_days[month-1]
        prev_month_days = if month == 2 && (year % 4 == 0 && year % 100 != 0 || year % 400 == 0) then 29 else prev_month_days
        num_rows = if month_days + first_day > 35 then 6 else if first_day == 0 && month_days == 28 then 4 else 5

        calendar.find('tbody').remove()
        calendar.find('thead').after('<tbody></tbody>')
        calendar.find('.month_header th.month').text(month_name + ' ' + year)

        current_day = 0
        for row in [1..6]
          calendar.find('tbody').append('<tr class="week">')
          for day, i in days
            day = (current_day + 1) + '-' + month + '-' + year
            html = '<td ' +
              (if row == 1 && i < first_day
                'class="inactive day">' + (prev_month_days - ((first_day-1) - i))
               else if current_day >= month_days
                ++current_day
                'class="inactive day">' + (current_day - month_days)
               else
                 ++current_day
                 'class="active day day' + current_day + ' month' + month + '">' + current_day) + '</td>'
            calendar.find('tbody').append html
          calendar.find('tbody').append '</tr>'

        disable_bookings = ->
          _(scope.listing.bookings).each (booking) ->
            range = moment().range(new Date(booking.check_in.year(),booking.check_in.month(),booking.check_in.date()+1), new Date(booking.check_out.year(),booking.check_out.month(),booking.check_out.date()-1))
            iterator = moment().range(new Date(booking.check_in.year(),booking.check_in.month(),booking.check_in.date()), new Date(booking.check_in.year(),booking.check_in.month(),booking.check_in.date()+1))
            range.by iterator, (m) ->
              if m.month() == month && m.year() == year
                booked.push [m.month(), m.date(), m.year()]
                angular.element('calendar table:eq(' + cal + ') .day' + m.date()).addClass('booked')
                prev1 = moment new Date(m.year(),m.month(),m.date()-1)
                prev2 = moment new Date(m.year(),m.month(),m.date()-2)
                if m.date() != 1 && _(booked).find((b) -> JSON.stringify(b) == JSON.stringify([prev2.month(), prev2.date(), prev2.year()]))
                  angular.element('calendar table:eq(' + cal + ') .day' + prev1.date()).addClass('booked')

        scope.listingQ.promise.then -> disable_bookings()

      gen_cals = (dir) ->
        booked = []
        if dir is 'prev'
          scope.month = scope.month == 0 && 11 || scope.month-1
          scope.year = scope.month == 11 && scope.year-1 || scope.year
        else if dir is 'next'
          scope.month = if scope.month == 11 then 0 else scope.month+1
          scope.year = scope.month == 0 && scope.year+1 || scope.year
        else
          scope.month = moment().month()
          scope.year = moment().year()
        angular.element('#availability .title .month:first').text "#{months[scope.month]} #{scope.year}"
        gen_cal(0, scope.month, scope.year)
        next_month = scope.month < 11 && scope.month+1 || 0
        next_year = next_month == 0 && scope.year+1 || scope.year
        gen_cal(1, next_month, next_year)
        next_month = next_month < 11 && next_month+1 || 0
        next_year = next_month == 0 && next_year+1 || next_year
        gen_cal(2, next_month, next_year)
        next_month = next_month < 11 && next_month+1 || 0
        next_year = next_month == 0 && next_year+1 || next_year
        gen_cal(3, next_month, next_year)
        angular.element('#availability .title .month:last').text "#{months[next_month]} #{next_year}"
        element.find('td.day').bind 'click.selecting', selecting
        
      selecting = ->
        element.find('td.day').unbind 'click.selecting'
        cal = angular.element(@).parent().parent()
        month1 = cal.find('.month_header').children('.month')
        scope.check_in = [parseInt(month1.attr('month')), parseInt(angular.element(@).text()), parseInt(month1.attr('year'))]
        element.find('td.day').bind 'click.selected', ->
          angular.element('td.day').removeClass 'booking'
          element.find('td.day').unbind 'click.selected'
          element.find('td.day').unbind 'mouseenter.selecting'
          element.find('td.day').bind 'click.selecting', selecting
          if valid(scope.check_in, scope.check_out)
            check_in  = scope.check_in
            check_out = scope.check_out
            check_in_date  = new Date(check_in[2], check_in[0], check_in[1])
            check_out_date = new Date(check_out[2], check_out[0], check_out[1])
            check_in[0] = check_in[0] + 1
            check_out[0] = check_out[0] + 1
            if check_in_date > check_out_date then tmp = check_in; check_in = check_out; check_out = tmp
            scope.$apply ->
              scope.dates.check_in  = check_in.join '/'
              scope.dates.check_out = check_out.join '/'
            scope.check_in  = null
            scope.check_out = null
            scope.bookModal()
        element.find('td.day').bind 'mouseenter.selecting', ->
          month2 = angular.element(@).parent().parent().find('.month_header').children('.month')
          scope.check_out = [parseInt(month2.attr('month')), parseInt(angular.element(@).text()), parseInt(month2.attr('year'))]
          angular.element('td.day').removeClass 'booking'
          if valid(scope.check_in, scope.check_out)
            check_in_date  = new Date(scope.check_in[2], scope.check_in[0], scope.check_in[1])
            check_out_date = new Date(scope.check_out[2], scope.check_out[0], scope.check_out[1])
            idate = new Date(scope.check_in[2], scope.check_in[0], scope.check_in[1]); idate.setDate(idate.getDate()+1)
            range = moment().range check_in_date, check_out_date
            iterator = moment().range check_in_date, idate
            range.by iterator, (moment) ->
              angular.element('calendar td.day' + moment.date() + '.month' + moment.month()).addClass 'booking'
          else
            cal.find('td.day' + scope.check_in[1]).addClass 'booking'

      gen_cals()

      element.parent().find('.arrow.prev').click -> gen_cals 'prev'
      element.parent().find('.arrow.next').click -> gen_cals 'next'

      valid = (check_in, check_out) ->
        check_in_date  = new Date(check_in[2], check_in[0], check_in[1])
        check_out_date = new Date(check_out[2], check_out[0], check_out[1])
        if check_in_date > check_out_date
          tmp = check_in; check_in = check_out; check_out = tmp
          tmp = check_in_date; check_in_date = check_out_date; check_out_date = tmp
        _valid = true
        _valid = false if check_out[1] - check_in[1] == 1 && check_out[0] == check_in[0] || check_out[1] - check_in[1] == 0 && check_out[0] == check_in[0]
        _valid = false if check_in[1] == _month_days[check_in[0]] && check_out[1] == 1 && (check_out[0] == check_in[0] + 1 || check_in[0] == 11 && check_out[0] == 0)
        range = moment().range check_in_date, check_out_date
        for d in booked
          date = new Date(d[2], d[0], d[1])
          _valid = false if range.contains date
        return _valid

    restrict: 'E'
    template: "
      <div class='table'>
        <table>
          <thead>
            <tr class='month_header'>
              <th class='month' colspan='7'></th>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div class='table'>
        <table>
          <thead>
            <tr class='month_header'>
              <th class='month' colspan='7'></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div class='table'>
        <table>
          <thead>
            <tr class='month_header'>
              <th class='month' colspan='7'></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div class='table'>
        <table>
          <thead>
            <tr class='month_header'>
              <th class='month' colspan='7'></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
    "

angular.element(document).on 'ready page:load', -> angular.bootstrap('body', ['luxhaven'])