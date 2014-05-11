describe('Thunderer', function () {
  var doc;
  beforeEach(function () {
    Faye = {};
    doc = {};
  });

  it('adds subscription callback', function () {
    Thunderer.subscribe('Hello', 'WorldCallback');
    expect(Thunderer.subscriptionCallbacks['Hello']).toEqual('WorldCallback')
  });

  it('has fayExtension which add some signature for outgoing message',function () {
    var called = false;
    var message = {channel: "/meta/subscribe", subscription: "hello"}
    Thunderer.subscriptions["hello"] = {signature: "abcd", timestamp: "1234"}
    Thunderer.fayeExtension.outgoing(message, function(message) {
      expect(message.ext.thunderer_signature).toEqual("abcd");
      expect(message.ext.thunderer_timestamp).toEqual("1234");
      called = true;
    });
    expect(called).toBeTruthy();
  });

  it("adds a faye subscription with response handler when signing", function() {
    var faye = {subscribe: jasmine.createSpy()};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = {server: "server", channel: "somechannel"};
    Thunderer.sign(options);
    expect(faye.subscribe).toHaveBeenCalledWith("somechannel", jasmine.any(Function));
    expect(Thunderer.subscriptions.server).toEqual("server");
    expect(Thunderer.subscriptions.somechannel).toEqual(options);
  });

  it("unsubscribes a channel by name", function(){
    var sub = { cancel: jasmine.createSpy() };
    var faye = {subscribe: function(){ return sub; }};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    Thunderer.sign(options);
    expect(Thunderer.subscription("somechannel")).toEqual(sub);
    Thunderer.unsubscribe("somechannel");
    expect(sub.cancel).toHaveBeenCalled();
    expect(Thunderer.subscription("somechannel")).toBeFalsy();
  });

  it("unsubscribes all channels", function(){
    var created = 0;
    var sub = function() {
      created ++;
      var sub = { cancel: function(){ created --; } };
      return sub;
    };
    var faye = { subscribe: function(){ return sub(); }};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    Thunderer.sign({server: "server", channel: "firstchannel"});
    Thunderer.sign({server: "server", channel: "secondchannel"});
    expect(created).toEqual(2);
    expect(Thunderer.subscription("firstchannel")).toBeTruthy();
    expect(Thunderer.subscription("secondchannel")).toBeTruthy();
    Thunderer.unsubscribeAll()
    expect(created).toEqual(0);
    expect(Thunderer.subscription("firstchannel")).toBeFalsy();
    expect(Thunderer.subscription("secondchannel")).toBeFalsy();
  });

  it("returns the subscription object for a subscribed channel", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    Thunderer.sign(options);
    expect(Thunderer.subscription("somechannel")).toEqual("subscription")
  });

  it("triggers callback matching message channel in response", function() {
    var handler, callbackSpy, response, faye;
    callbackSpy = jasmine.createSpy();
    response = {channel: 'test', data: 'abcd'};
    faye = {subscribe: function (channel, handleResponse) {
      handler = handleResponse;
    }};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = {server: "server", channel: "somechannel"};
    Thunderer.sign(options);
    Thunderer.subscribe("test", callbackSpy);
    handler(response);

    expect(callbackSpy).toHaveBeenCalledWith('abcd','test')
  });

   it("takes a callback for subscription object when signing", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(Thunderer, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel" };
    options.subscription = jasmine.createSpy();
    Thunderer.sign(options);
    expect(options.subscription).toHaveBeenCalledWith("subscription");
  });

  it("adds fayeCallback when client and server aren't available", function() {
    Thunderer.faye("callback");
    expect(Thunderer.fayeCallbacks[0]).toEqual("callback");
  });


});
