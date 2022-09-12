# frozen_string_literal: true

revision_file = Rails.root.join('REVISION')

GIT_SHA = if revision_file.exist?
            revision_file.read.strip
          elsif Rails.root.join('.git').exist?
            `git show --pretty=%H -q`.chomp
          else
            'master'
          end
