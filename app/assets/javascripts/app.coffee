ListingCtrl = ($scope, $http) ->




angular.module('nutricount', ['ui'])
  .provider('authService', ->
    buffer = []
    @pushToBuffer = (config, deferred) ->
      buffer.push
        config: config
        deferred: deferred

    @$get = ['$rootScope', '$injector', ($rootScope, $injector) ->
      retry = (config, deferred) ->
        $http = $http or $injector.get '$http'
        $http(config).then (rsp) -> deferred.resolve rsp

      retryAll = ->
        i = 0
        while i < buffer.length
          retry buffer[i].config, buffer[i].deferred
          ++i
        buffer = []
      $http = undefined
      loginConfirmed: (user) ->
        $rootScope.$broadcast 'auth:loginConfirmed', user
        retryAll()
    ]
    '' # to combat coffeescript's implicit return
  )
  .controller('listings', ListingCtrl)
