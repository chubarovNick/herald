var Thunderer = (function (doc) {
  var handleResponse, connectToFaye, self;

  self = {
    connecting: false,
    fayeClient: null,
    fayeCallbacks: [],
    subscriptions: {},
    subscriptionObjects: {},
    subscriptionCallbacks: {}
  };

  handleResponse = function(message) {
    if (callback = self.subscriptionCallbacks[message.channel]) {
      callback(message.data, message.channel);
    }
  };

  connectToFaye = function () {
    self.fayeClient = new Faye.Client(self.subscriptions.server);
    self.fayeClient.addExtension(self.fayeExtension);
    for (var i=0; i < self.fayeCallbacks.length; i++) {
      self.fayeCallbacks[i](self.fayeClient);
    };
  };

  self.sign = function(options) {
    if (!self.subscriptions.server) {
      self.subscriptions.server = options.server;
    }
    self.subscriptions[options.channel] = options;
    self.faye(function(faye) {
      var sub = faye.subscribe(options.channel, handleResponse);
      self.subscriptionObjects[options.channel] = sub;
      if (options.subscription) {
        options.subscription(sub);
      }
    });
  };

  self.subscribe = function (channel, callback) {
    self.subscriptionCallbacks[channel] = callback;
  };

  self.faye = function (callback) {
    if (self.fayeClient) {
      callback(self.fayeClient);
    } else {
      self.fayeCallbacks.push(callback);
      if (self.subscriptions.server && !self.connecting) {
        self.connecting = true;
        if (typeof Faye === 'undefined') {
          console.log('Faye is undefined, you should require faye.js before using Thunderer')
        } else {
          connectToFaye();
        }
      }
    }
  };

  self.fayeExtension ={
    outgoing: function(message, callback) {
      if (message.channel == "/meta/subscribe") {
        // Attach the signature and timestamp to subscription messages
        var subscription = self.subscriptions[message.subscription];
        if (!message.ext) message.ext = {};
        message.ext.thunderer_signature = subscription.signature;
        message.ext.thunderer_timestamp = subscription.timestamp;
      }
      callback(message);
    }
  };

  self.subscription = function(channel) {
    return self.subscriptionObjects[channel];
  };
  self.unsubscribe = function (channel) {
    var sub = self.subscription(channel);
    if (sub) {
      sub.cancel();
      delete self.subscriptionObjects[channel];
    }
  };

  self.unsubscribeAll = function () {
    for (var i in self.subscriptionObjects) {
      if ( self.subscriptionObjects.hasOwnProperty(i) ) {
        self.unsubscribe(i);
      }
    }
  };
  return self;
}(document));
