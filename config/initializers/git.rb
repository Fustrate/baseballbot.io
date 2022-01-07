# frozen_string_literal: true

revision_file = Rails.root.join('REVISION')

GIT_SHA = if File.exist?(revision_file)
            File.read(revision_file)
          elsif Dir.exist?(Rails.root.join('.git'))
            `git show --pretty=%H -q`.chomp
          else
            'master'
          end
