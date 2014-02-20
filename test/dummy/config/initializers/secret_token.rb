Rails.application.config.secret_token    = 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef'
Rails.application.config.secret_key_base = 'deadbeef' if Rails.application.config.respond_to?(:secret_key_base)
