errs = require 'errs'
url = require 'url'

User = require 'app/models/user'

SUCCESS_CODE = 200
# Valid bcrypt hash for password 'pikapass'
PASS_HASH = '$2a$10$bJGLPL19uo0ojAe97jQk5.KeafoWk.MQGFEtXmdneGHjBDPxUU9bi'


describe 'main not logged in', ->
  before (done) ->
    server.run(done)

  describe '/', () ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('/'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal SUCCESS_CODE

    it 'should have links to sign in and register on navbar', ->
      navbar = browser.query('.navbar')
      expect(navbar).to.exist
      navbar.querySelector('a:contains("Sign In")')
        .getAttribute('href').should.equal '/login'
      navbar.querySelector('a:contains("Register")')
        .getAttribute('href').should.equal '/users/new'

  describe '/login', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('/login?redirect=/after/path'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal SUCCESS_CODE

    it 'should have form', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'

    it 'should require username to submit', (done) ->
      browser.pressButton 'Log In', ->
        errors = browser.text('.alert-error')
        expect(errors).to.exist
        errors.should.contain('Please enter username')
        done()

    it 'should require password to submit', (done) ->
      browser.fill('Username', 'pokefan')
        .pressButton 'Log In', ->
          errors = browser.text('.alert-error')
          expect(errors).to.exist
          errors.should.contain 'Please enter password'
          done()

    it 'should fill in username on failure', (done) ->
      browser.fill('Username', 'pokefan')
        .pressButton 'Log In', ->
          browser.query('form input#user').value.should.equal 'pokefan'
          done()

    it 'should keep redirect url on failed login', (done) ->
      browser.pressButton 'Log In', ->
        browser.location.pathname.should.equal '/login'
        browser.location.search.should.equal '?redirect=/after/path'
        done()

    it 'should fail if user doesn\'t exist', (done) ->
      sinon.stub(User, 'findOne')
        .withArgs({username: 'pokefan'})
        .yields()
      browser
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .pressButton 'Log In', ->
          browser.text('.alert-error').should.contain(
                        'User "pokefan" does not exist')
          User.findOne.restore()
          done()

    it 'should fail if password is incorrect', (done) ->
      sinon.stub(User, 'findOne')
        .withArgs({username: 'pokefan'})
        .yields(null, new User({passwdHash: PASS_HASH}))
      browser
        .fill('Username', 'pokefan')
        .fill('Password', 'wrong_pass')
        .pressButton 'Log In', ->
          browser.text('.alert-error').should.contain('Password did not match')
          User.findOne.restore()
          done()

    it 'should redirect to specified url after login', (done) ->
      sinon.stub(User, 'findOne')
        .withArgs({username: 'pokefan'})
        .yields(null, new User({passwdHash: PASS_HASH}))
      browser
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .pressButton 'Log In', ->
          browser.redirected.should.be.true
          browser.location.pathname.should.equal '/after/path'
          User.findOne.restore()
          done()

    it 'should redirect to home page if no redirect', (done) ->
      sinon.stub(User, 'findOne')
        .withArgs({username: 'pokefan'})
        .yields(null, new User({passwdHash: PASS_HASH}))
      Browser.visit fullUrl('/login'), (err, browser) ->
        expect(err).not.to.exist
        browser
          .fill('Username', 'pokefan')
          .fill('Password', 'pikapass')
          .pressButton 'Log In', ->
            browser.redirected.should.be.true
            browser.location.pathname.should.equal '/'
            User.findOne.restore()
            done()

describe 'main logged in', ->
  user =
    username: 'pokefan'
    name: 'Ash Ketchum'
    email: 'ash.ketchum@pallettown.com'
    type: 'User'
    passwdHash: PASS_HASH

  logIn = (path, callback) ->
    sinon.stub(User, 'findOne')
      .withArgs({username: 'pokefan'})
      .yields(null, new User(user))
    Browser.visit fullUrl("/login?redirect=#{path}"), (err, browser) ->
      if err then return callback(err)
      browser
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .pressButton 'Log In', ->
          browser.redirected.should.be.true
          browser.location.pathname.should.equal '/'
          User.findOne.restore()
          callback(null, browser)

  describe '/', ->
    browser = null

    beforeEach (done) ->
      logIn '/', (err, _browser) ->
        browser = _browser
        done(err)

    it 'should welcome user with name', ->
      browser.text('body').should.contain 'Welcome, Ash Ketchum!'

    it 'should have a logout link', ->
      navbar = browser.query('.navbar')
      expect(navbar).to.exist
      navbar.querySelector('a:contains("Log Out")')
        .getAttribute('href').should.equal '/logout'

    describe '/logout', ->
      browser = null

      beforeEach (done) ->
        logIn '/logout', (err, _browser) ->
          browser = _browser
          done(err)

      it 'should redirect to home page on logout', ->
        browser.redirected.should.be.true
        browser.location.pathname.should.equal '/'

      it 'should have links to sign in and register on navbar', ->
        navbar = browser.query('.navbar')
        expect(navbar).to.exist
        navbar.querySelector('a:contains("Sign In")')
          .getAttribute('href').should.equal '/login'
        navbar.querySelector('a:contains("Register")')
          .getAttribute('href').should.equal '/users/new'
