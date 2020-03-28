# frozen_string_literal: true

# Copyright (c) 2020 Valencia Management Group
# All rights reserved.

class WebpackerAssetCleanupTasks
  extend Forwardable

  def_delegators :@ssh, :capture, :execute

  def initialize(ssh)
    @ssh = ssh
  end

  def clean_old_assets!
    files_to_remove.each do |file_to_remove|
      relative_path = file_to_remove[7..-1]

      execute :rm, relative_path
      # puts relative_path
    end
  end

  protected

  def current_files_from_manifest
    first = JSON.parse capture(:cat, 'manifest.json')
    second = JSON.parse capture(:cat, 'manifest.1.json')

    first.delete 'entrypoints'
    second.delete 'entrypoints'

    (first.values + second.values).uniq
  end

  def files_to_remove
    current_files = current_files_from_manifest

    capture(:find, '.', '-type f', '-mindepth 2', '-print')
      .split("\n")
      .map { |file| "/packs/#{file[2..-1]}" }
      .reject { |file| current_files.include?(file.gsub(/\.(?:gz|br)$/, '')) }
      .sort
  end
end

namespace :webpacker do
  desc 'Back up the last deploy\'s manifest.json'
  task :backup_manifest do
    on roles(:app) do
      within current_path.join('public', 'packs') do
        execute :cp, 'manifest.json', 'manifest.1.json'
      end
    end
  end

  desc 'Clean old assets'
  task :clean_old_assets do
    on roles(:app) do
      within current_path.join('public', 'packs') do
        WebpackerAssetCleanupTasks.new(self).clean_old_assets!
      end
    end
  end
end
