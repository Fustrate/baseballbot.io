# frozen_string_literal: true

# Copyright (c) 2020 Valencia Management Group
# All rights reserved.

namespace :puma do
  %w[start restart stop].each do |command|
    desc "#{command} puma"
    task command do
      on roles(:app) do
        execute :sudo, :systemctl, command, 'puma-baseballbot'
      end
    end
  end
end
