# frozen_string_literal: true

# Overflow extra: Allow for easy handling of overflowing pages [https://ddnexus.github.io/pagy/docs/extras/overflow]
require 'pagy/extras/overflow'

Pagy::DEFAULT[:limit] = 25

Pagy::DEFAULT[:overflow] = :last_page

Pagy::DEFAULT.freeze
