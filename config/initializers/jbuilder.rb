# frozen_string_literal: true

class Jbuilder
  def collection!(collection, *options)
    if ::Kernel.block_given?
      _set_value :data, (_scope { array! collection, &::Proc.new })
    else
      _set_value :data, (_scope { array! collection, *options })
    end
  end

  def paginated_collection!(collection, *options)
    if ::Kernel.block_given?
      _set_value :data, (_scope { array! collection, &::Proc.new })
    else
      _set_value :data, (_scope { array! collection, *options })
    end

    _set_value :current_page,  collection.current_page
    _set_value :total_pages,   collection.total_pages
    _set_value :total_entries, collection.total_entries
    _set_value :per_page,      collection.per_page
  end
end
