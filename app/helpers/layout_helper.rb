# frozen_string_literal: true

module LayoutHelper
  def title(title) = content_for(:title, title)

  def body_dataset(**body_dataset)
    @data ||= {
      git_revision: GIT_SHA,
      environment: Rails.env
    }

    @data.merge!(body_dataset) if body_dataset.any?

    @data
  end

  def javascript(*packs, **data)
    @javascripts ||= []

    @javascripts.concat(packs) unless packs.empty?

    body_dataset(**data) unless data.empty?
  end

  def stylesheet(*packs)
    @stylesheets ||= []

    @stylesheets.concat(packs)
  end

  def javascripts! = (javascript_include_tag(*@javascripts, defer: true, type: 'module') if @javascripts&.any?)

  def stylesheets! = stylesheet_link_tag(*(%w[legacy application] + (@stylesheets || [])), media: :all)
end
