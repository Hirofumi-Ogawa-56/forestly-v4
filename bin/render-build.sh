#!/usr/bin/env bash
# エラーが発生したら即停止
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate