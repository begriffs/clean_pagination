## Clean Pagination

[![Build Status](https://travis-ci.org/begriffs/clean_pagination.png?branch=master)](https://travis-ci.org/begriffs/clean_pagination)

The simplest, most flexible, most standards-compliant
pagination gem there is. Pairs nicely with
[begriffs/angular-paginate-anything](https://github.com/begriffs/angular-paginate-anything).

### Usage

```ruby
class ApplicationController < ActionController::Base
  include CleanPagination

  # Using activemodel
  def index
    max_per_page = 100

    paginate Bla.count, max_per_page do |limit, offset|
      render json: Bla.limit(limit).offset(offset)
    end
  end

  # Using some custom data
  def numbers
    paginate Float::INFINITY, 100 do |limit, offset|
      render json: (offset...offset+limit).to_a
    end
  end
  
  # Using optional settings
  def options
    begin
      paginate Foo.scope.count, max_per_page, allow_render: false, raise_errors: true do |limit, offset|
        respond_with Foo.scope.limit(limit).offset(offset)
      end
    rescue RangeError
      render json: { error: { message: "invalid pagination range" } }
    end
  end
end
```

### Benefits

* **HTTP Content-Type agnoticism.** Information about total items,
  selected ranges, and next- previous-links are sent through headers.
  It works without modifying your API payload in any way.
* **Graceful degredation.** Both client and server specify the maximum
  page size they accept and communication gracefully degrades to
  accomodate the lesser.
* **Expressive retrieval.** This approach, unlike the use of `per_page` and
  `page` parameters, allows the client to request any (possibly unbounded)
  interval of items.
* **Semantic HTTP.** Built in strict conformance to RFCs 2616 and 5988.

### Under the hood

To prevent this gem from rendering while still allowing it to set
headers and response codes, pass `allow_render: false` to `paginate`.
This may be used to avoid `DoubleRenderError` situations.

To handle the invalid request range condition in your app, pass the
`raise_errors: true` option.  This will raise a `RangeError` which you can
rescue (and thus control what is rendered).  Headers will still be set.

[TODO: explain what the headers mean.] Until this is written you can consult
the tests for an idea how it works, or use a client that is compatible, such as
[begriffs/angular-paginate-anything](https://github.com/begriffs/angular-paginate-anything).
