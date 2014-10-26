[![Build Status](https://travis-ci.org/chubarovNick/thunderer.svg?branch=master)](https://travis-ci.org/chubarovNick/thunderer)
[![Code Climate](https://codeclimate.com/github/chubarovNick/thunderer/badges/gpa.svg)](https://codeclimate.com/github/chubarovNick/thunderer)
[![Dependency Status](https://gemnasium.com/chubarovNick/thunderer.svg)](https://gemnasium.com/chubarovNick/thunderer)
[![Test Coverage](https://codeclimate.com/github/chubarovNick/thunderer/badges/coverage.svg)](https://codeclimate.com/github/chubarovNick/thunderer)
# Thunderer

Thunderer is gem for publishing messages through [Faye](http://faye.jcoglan.com/). It allows you to easily provide real-time updates through an open socket without tying

## Installation

Add this line to your application's Gemfile:

    gem 'thunderer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install thunderer

## Setup
Run generator:

      rails g thunderer:install

It will generate thunderer.ru and thunderer.yml files. Check it and setup domain for production

Next add the JavaScript file to your application.js file manifest.

    //= require thunderer

## Usage with typical rails app

Use the `subscribe_to` helper method on any page to subscribe to a channel.

```rhtml
<%= subscribe_to "/comments" %>
```

Then setup active record models:

```
class Comment < ActiveRecord::Base
  include Thunderer::PublishChanges
  notify_client_to_channels '/comments/new'
end
```

## Usage with Angular single page application

Before start using with Angular add response interceptor (ThundererInterceptor) and service ($thunderer):

    //= require thunderer_angular

Inject `'Thunderer'` module to your app, and setup `$http` service

```
...
provider.interceptors.push('ThundererInterceptor');
...
```

The main deference of usage is adding special headers to json responses:

```
    class CommentsController < ApplicationController
      include Thunderer::ControllerAdditions

    end
```

After that you can subscribe in your angular controllers and directives to Faye callbacks

```
  commentAddOrChangedCallback = function(data) {
    alert(data);
  }
  $thunderer.addListener("/comments", commentAddOrChangedCallback);
```
## Contributing

1. Fork it ( http://github.com/<my-github-username>/thunderer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
