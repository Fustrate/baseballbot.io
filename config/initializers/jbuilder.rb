# frozen_string_literal: true

Jbuilder.key_format camelize: :lower
Jbuilder.deep_format_keys true

class Jbuilder
  def pagination!(pagination)
    _set_value(
      :pagination,
      page: pagination.page,
      perPage: pagination.limit,
      total: pagination.count,
      pages: pagination.last
    )
  end
end
