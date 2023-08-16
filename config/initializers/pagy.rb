# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

# Overflow extra: Allow for easy handling of overflowing pages [https://ddnexus.github.io/pagy/docs/extras/overflow]
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 25

Pagy::DEFAULT[:overflow] = :last_page

Pagy::DEFAULT.freeze
