#!/usr/bin/env rake
# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

# `yarn install` is being run twice - once by webpacker:yarn_install and again by yarn:install
Rake::Task['assets:precompile'].instance_variable_get(:@prerequisites).delete('yarn:install')

task default: :spec
