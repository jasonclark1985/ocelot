setCookies = require '../set-cookies'
refresh = require './refresh'
response = require '../../response'
tokenInfo = require '../token-info'
log = require '../../log'

module.exports =
  accept: (req, route, cookies) ->
    req.url.split('?')[0].endsWith('auth-token-refresh') and refresh.accept(route, cookies)

  complete: (req, res, route, cookies) ->
    thingsAreOk = (auth) ->
      auth.token = auth.access_token
      auth.obtained_on = new Date().getTime()
      req._auth = auth
      setCookies.setAuthCookies res, route, auth
      .then () ->
        tokenInfo.complete req, res

    thingsAreNotOk = (err) ->
      log.error "Refresh error for route #{route.route}", err
      response.send(res, 500)

    refresh.token(req, route, cookies).then thingsAreOk, thingsAreNotOk
