errs = require 'errs'
url = require 'url'

User = require 'app/models/user'

SUCCESS_CODE = 200;


describe 'user', ->
  before (done) ->
    server.run(done)

  describe '/new', ->
    browser = null
    ash =
      name: 'Ash Ketchum'
      email: 'ash.ketchum@pallettown.com'
      username: 'pokefan'
      passwdHash: 'pikahash'

    beforeEach (done) ->
      Browser.visit fullUrl('/users/new'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal(SUCCESS_CODE)

    it 'should have form posting to /users', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal('POST')
      form.getAttribute('action').should.equal('/users')

    it 'should create new user when form is submitted', (done) ->
      sinon.stub(User.prototype, 'save').yields()
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'ash.ketchum@pallettown.com')
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .fill('Confirm password', 'pikapass')
        .pressButton 'Submit', ->
          User.prototype.save.should.have.been.called
          user = User.prototype.save.thisValues[0]
          user.name.should.deep.equal('Ash Ketchum')
          user.username.should.deep.equal('pokefan')
          user.email.should.deep.equal('ash.ketchum@pallettown.com')
          user.should.have.property('passwdHash')
          User.prototype.save.restore()
          done()

    it 'should redirect to home page after user is created', (done) ->
      sinon.stub(User.prototype, 'save').yields()
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'ash.ketchum@pallettown.com')
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .fill('Confirm password', 'pikapass')
        .pressButton 'Submit', ->
          browser.redirected.should.be.true
          browser.location.pathname.should.equal('/')
          User.prototype.save.restore()
          done()

    it 'should log user in after creation', (done) ->
      sinon.stub(User.prototype, 'save').yields()
      sinon.stub(User, 'findOne')
        .withArgs({username: 'pokefan'})
        .yields(null, new User(ash))
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'ash.ketchum@pallettown.com')
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .fill('Confirm password', 'pikapass')
        .pressButton 'Submit', ->
          browser.text('body').should.contain 'Welcome, Ash Ketchum!'
          User.prototype.save.restore()
          User.findOne.restore()
          done()

    it 'should not create new user when model is invalid', (done) ->
      sinon.stub(User.prototype, 'save').yields()
      browser.fill('Name', 'Ash Ketchum')
        .pressButton 'Submit', ->
          User.prototype.save.should.not.have.been.called
          User.prototype.save.restore()
          done()

    it 'should display errors when model is invalid', (done) ->
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'not an email')
        .fill('Password', 'pikapass')
        .fill('Confirm password', 'pikapass')
        .pressButton 'Submit', ->
          errors = browser.text('.alert-error')
          expect(errors).to.exist
          errors.should.contain 'Validator "regexp" failed for path email'
          errors.should.contain 'Validator "required" failed for path username'
          done()

    it 'should fill fields with values when model is invalid', (done) ->
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'not an email')
        .fill('Username', 'pokefan')
        .pressButton 'Submit', ->
          form = browser.query('form')
          expect(form).to.exist
          form.querySelector('input#name').value
            .should.equal('Ash Ketchum')
          form.querySelector('input#username').value
            .should.equal('pokefan')
          done()

    it 'should fail registration if username exists', (done) ->
      sinon.stub(User.prototype, 'save')
        .yields(errs.create('MongoError', {code: 11000}))
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Email', 'ash.ketchum@pallettown.com')
        .fill('Username', 'pokefan')
        .fill('Password', 'pikapass')
        .fill('Confirm password', 'pikapass')
        .pressButton 'Submit', ->
          browser.statusCode.should.equal(SUCCESS_CODE)
          errors = browser.text('.alert-error')
          expect(errors).to.exist
          errors.should.contain 'Username "pokefan" already exists'
          done()
