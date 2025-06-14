# frozen_string_literal: true

Jbuilder.key_format camelize: :lower
Jbuilder.deep_format_keys true

class Jbuilder
  def pagination!(pagination)
    _set_value(
      :pagination,
      pagination.is_a?(::Pagy) ? pagy_pagination(pagination) : pagination.pagination
    )
  end

  protected

  def pagy_pagination(pagy)
    {
      page: pagy.page,
      perPage: pagy.limit,
      total: pagy.count,
      pages: pagy.last
    }
  end
end
