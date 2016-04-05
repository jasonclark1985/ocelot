assert = require('assert')
sinon = require('sinon')
postman = require('../../src/auth/postman')
redirect = require('../../src/auth/redirect')
headers = require('../../src/auth/headers')
refresh = require('../../src/auth/refresh/auth-code-refresh')
crypt = require('../../src/auth/crypt')
postmanMock = undefined
headersMock = undefined
redirectMock = undefined

restore = (mockFunc) ->
    if mockFunc and mockFunc.restore
        mockFunc.restore()

describe 'refresh', ->
    it 'refreshes if post is successful', (done) ->
        secret = 'secret'
        unencrypted_refresh = 'abc'
        req = {}
        res = id: 'res'
        route = id: 'route'
        auth = id: 'auth'
        route['cookie-name'] = 'something'
        route['client-secret'] = secret
        postmanMock = sinon.stub(postman, 'post')

        postData =
            grant_type: 'refresh_token'
            refresh_token: unencrypted_refresh

        postmanMock.withArgs(postData, route).returns then: (s, f) ->
            s auth

        headerMock = sinon.stub(headers, 'setAuthCookies')
        headerMock.withArgs(res, route, auth).returns then: (s, f) ->
            s res

        redirectMock = sinon.stub(redirect, 'refreshPage');
        redirectMock.withArgs(req, res);

        cookies = {'something_rt': crypt.encrypt(unencrypted_refresh, secret)}

        refresh.complete req, res, route, cookies
        .then ->
          assert postmanMock.calledOnce == true
          assert redirectMock.calledOnce == true
          done()
        .catch done

    it 'redirects if post is unsuccessful', (done) ->
        secret = 'secret'
        unencrypted_refresh = 'abc'
        req = {}
        res = id: 'res'
        route = id: 'route'
        auth = id: 'auth'
        route['cookie-name'] = 'something'
        route['client-secret'] = secret
        postmanMock = sinon.stub(postman, 'post')

        postData =
            grant_type: 'refresh_token'
            refresh_token: unencrypted_refresh

        postmanMock.withArgs(postData, route).returns then: (s, f) ->
            f auth

        cookies = {'something_rt': crypt.encrypt(unencrypted_refresh, secret)}

        redirectMock = sinon.stub(redirect, 'startAuthCode')
        redirectMock.withArgs req, res, route, cookies
        refresh.complete req, res, route, cookies
        .then ->
          assert postmanMock.calledOnce == true
          assert redirectMock.calledOnce == true
          done()
        .catch done

    afterEach ->
        restore postmanMock
        restore headersMock
        restore redirectMock
