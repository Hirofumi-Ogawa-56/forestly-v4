source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"

# 認証・セキュリティ
gem "devise"
gem "bcrypt", "~> 3.1.7"

# 画像処理 (重複を削除し1つにまとめました)
gem "image_processing", "~> 1.2"

# ユーティリティ
gem "enum_help"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "sqlite3", ">= 1.4"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0"
end

group :production do
  gem "pg"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "factory_bot_rails"
  gem "faker"
end
