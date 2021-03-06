# Restaurant
Restaurant serves your data via auto-defined RESTful API on your rails application.  
No longer models, controllers, views, routes, and schemas are needed.

## Usage
Here is an example that creates a new rails app with Restaurant to provide RESTful API.

```
$ brew install mongodb
$ mongod --fork

$ rails new example
$ cd example

$ echo 'gem "restaurant"' >> Gemfile
$ bundle install

$ rails g mongoid:config
$ rails c

irb(main):001:0> app.accept = "application/json"
=> "application/json"
irb(main):002:0> app.post "/recipes", recipe: { title: "created" }
=> 201
irb(main):003:0 JSON.parse(app.response.body)
=> {"title"=>"created", "_id"=>"51963fe9f02da4c1f8000001"}
irb(main):004:0> app.get "/recipes/51963fe9f02da4c1f8000001"
=> 200
irb(main):005:0> JSON.parse(app.response.body)
=> {"title"=>"created", "_id"=>"51963fe9f02da4c1f8000001"}
irb(main):006:0> app.put "/recipes/51963fe9f02da4c1f8000001", recipe: { title: "updated" }
=> 204
irb(main):007:0> app.get "/recipes/51963fe9f02da4c1f8000001"
=> 200
irb(main):008:0> JSON.parse(app.response.body)
=> {"title"=>"updated", "_id"=>"51963fe9f02da4c1f8000001"}
irb(main):009:0> app.get "/recipes"
=> 200
irb(main):010:0> JSON.parse(app.response.body)
=> [{"title"=>"updated", "_id"=>"51963fe9f02da4c1f8000001"}]
irb(main):011:0> app.delete "/recipes/51963fe9f02da4c1f8000001"
=> 204
irb(main):012:0> app.get "/recipes"
=> 200
irb(main):013:0> JSON.parse(app.response.body)
=> []
```

## Customize
While Restaurant automagically defines what RESTful API needs, you can do them on your own.

### routes
```ruby
# config/routes.rb
#   1. V1::ResourcesController < ApplicationController are defined if not defined
#   2. The following routes are defined
#     GET    /v1/:resource     -> V1::ReosurcesController#index
#     GET    /v1/:resource/:id -> V1::ResourcesController#show
#     POST   /v1/:resource     -> V1::ResourcesController#create
#     PUT    /v1/:resource/:id -> V1::ResourcesController#update
#     DELETE /v1/:resource/:id -> V1::ResourcesController#destroy
namespace :v1 do
  Restaurant::Router.route(self)
end

# Or customize what you want (e.g. only provides Read API)
#   1. V2::ResourcesController < ApplicationController are defined if not defined
#   2. The following routes are defined
#     GET    /v2/:resource     -> V1::ReosurcesController#index
#     GET    /v2/:resource/:id -> V1::ResourcesController#show
namespace :v2 do
  scope ":resource" do
    controller :resources do
      get "" => :index
      get ":id" => :show
    end
  end
end
```

### controller
```ruby
# Restaurant::Actions provides index, show, create, update, and destroy actions by default.
# Of course you can override them as you like.
module V1
  class ResourcesController < ApplicationController
    include Restaurant::Actions
    respond_to :xml # you can respond to xml requests

    def index
      respond_with { foo: "bar" }
    end
  end
end
```

### authentication
Restaurant does not provide any auth layer, but it's easy to add it to your application.  
Here is a short example to authenticate users with [doorkeeper](https://github.com/applicake/doorkeeper).

```
$ echo 'gem "doorkeeper"' >> Gemfile
$ bundle install

$ rails g doorkeeper:install
$ rails g doorkeeper:migration
$ bundle exec rake db:migrate

$ vi app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  doorkeeper_for :all
end

$ rails c

irb(main):001:0> app.accept = "application/json"
=> "application/json"
irb(main):002:0> app.get "/v2/recipes"
=> 401
irb(main):003:0> application = Doorkeeper::Application.create(name: "example", redirect_uri: "http://example.com")
=> #<Doorkeeper::Application ...>
irb(main):004:0> token = application.access_tokens.create
=> #<Doorkeeper::AccessToken ...>
irb(main):005:0> app.get "/v2/recipes", access_token: token.token
=> 200
```

### authorization
Here is an example of a scope-based authorization system.

```
$ vi app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  doorkeeper_for :all
  before_filter :require_authorization

  private

  def require_authorization
    head 403 unless has_authorization?
  end

  def has_authorization?
    doorkeeper_token.scopes.any? do |scope|
      if role = Mongoid.default_session["roles"].find(:scope => scope).first
        if action_names = role[resources_name]
          action_names.include?(action_name)
        end
      end
    end
  end
end

$ rails c
irb(main):001:0> app.accept = "application/json"
irb(main):002:0> application = Doorkeeper::Application.create(name: "example", redirect_uri: "http://example.com")
=> #<Doorkeeper::Application ...>
irb(main):003:0> token = application.access_tokens.create(scopes: "admin")
=> #<Doorkeeper::AccessToken ...>
irb(main):004:0> app.get "/v2/recipes", access_token: token.token
=> 403
irb(main):005:0> Mongoid.default_session["roles"].insert(scope: "admin", recipes: ["index", "show"])
=> nil
irb(main):006:0> app.get "/v2/recipes", access_token: token.token
=> 200
irb(main):007:0> app.post "/v2/recipes", access_token: token.token, recipe: { title: "created" }
=> 403
```

## More
See [the example application](https://github.com/r7kamura/restaurant/tree/master/spec/dummy).
