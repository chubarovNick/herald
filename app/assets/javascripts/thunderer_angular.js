(function () {
  'use strict';

   angular.module('Thunderer', [])

     .factory('ThundererInterceptor', function ($q) {
       var self = {
         response: function (response) {
           var rawChanels = response.headers().channels;
           if (rawChanels) {
             var channels = JSON.parse(rawChanels);
             for (var i = 0; i < channels.length; i++) {
               Thunderer.sign(channels[i]);
             }
           }
           return response;
         },
         responseError: function (rejection) {
           $q.reject(rejection);
         }
       };

       return self;

     })

     .service('$thunderer', function () {

       var self = {
         addListener: function (channel, callback) {
           Thunderer.subscribe(channel, callback);
         },
         removeListener: function (channel) {
           Thunderer.unsubscribe(channel)
         },
         removeAllListners: function () {
           Thunderer.unsubscribeAll()
         }
       }
       return self;
     })

}());
