User = require 'app/models/user'


describe 'User', ->
  user = null

  beforeEach ->
    user = new User(
      username: 'pikachu'
      name: 'Pikachu'
      email: 'pikachu@pika.com'
      passwdHash: 'pikahash'
    )

  describe 'constructor', ->
    it 'should be valid', (done) ->
      user.validate(done)

    it 'should be invalid without username', (done) ->
      user.username = undefined
      user.validate (err) ->
        err.should.be.an.instanceOf(Error)
        err.name.should.equal('ValidationError')
        err.errors.should.have.property('username')
        done()

    it 'should be invalid without name', (done) ->
      user.name = undefined
      user.validate (err) ->
        err.should.be.an.instanceOf(Error)
        err.name.should.equal 'ValidationError'
        err.errors.should.have.property 'name'
        done()

    it 'should be invalid with bad email format', (done) ->
      user.email = 'not an email'
      user.validate (err) ->
        err.should.be.an.instanceOf(Error)
        err.name.should.equal('ValidationError')
        err.errors.should.have.property('email')
        done()

    describe '#setPassword()', ->
      it "should set 'passwdHash' attribute", (done) ->
        user.passwdHash = undefined
        user.setPassword 'pikapass', (err) ->
          expect(user.passwdHash).to.exist
          done(err)

    describe '#matchesPassword()', ->
      beforeEach (done) ->
        user.setPassword('pikapass', done)

      it 'should match correct password', (done) ->
        user.matchesPassword 'pikapass', (err, match) ->
          match.should.be.ok
          done(err)

      it 'should not match incorrect password', (done) ->
        user.matchesPassword 'wrong_pass', (err, match) ->
          match.should.not.be.ok
          done(err)
