nock = require 'nock'

describe 'newsletter', ->
  describe 'index', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('admin', '/newsletter'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should have a test send form', ->
      btn = browser.query('.testsend button')
      expect(btn).to.exist

    it 'should have an article send form', ->
      btn = browser.query('.articlesend button')
      expect(btn).to.exist

    describe 'when newsletter is sent', ->
      campaignCreate = null
      campaignSend = null
      beforeEach (done) ->
        campaignCreate = nock('https://us4.api.mailchimp.com:443')
          .post('/1.3/?method=campaignCreate')
          .reply(200) # also replies with campaign id, how to take care of this?
        campaignSend = nock('https://us4.api.mailchimp.com:443')
          .post('/1.3/?method=campaignSendNow')
          .reply(200, "true")
        browser.pressButton('.sendNewsletter button', done)
      
      it 'should create new newsletter', ->
        campaignCreate.done()

      it 'should send newsletter', ->
        campaignSend.done()
