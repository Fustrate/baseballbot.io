# frozen_string_literal: true

module IconHelper
  def icon(names, style = :regular, **options)
    return options[:text] unless names

    if style.is_a? Hash
      options = style
      style = :regular
    end

    options[:style] = icon_style(options) if options[:color]

    classes = icon_classes(names, style, options.delete(:class))

    tag.i nil, **options.merge(class: classes.compact)
  end

  def loader(size = nil)
    classes = %w[fas fa-loader fa-spin]

    classes << "fa-#{size}" if size

    tag.i class: classes
  end

  protected

  def icon_classes(names, style, class_option)
    ["fa-#{style}", class_option, *(names.to_s.split.map { "fa-#{_1}" })].compact
  end

  def icon_style(options)
    primary, secondary = options.delete :color

    "--fa-primary-color: #{primary}; --fa-secondary-color: #{secondary || primary};"
  end
end
