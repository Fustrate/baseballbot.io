# frozen_string_literal: true

class WebpackerAssetCleanupTasks
  extend Forwardable

  def_delegators :@ssh, :capture, :execute

  def initialize(ssh)
    @ssh = ssh
  end

  def clean_old_assets!
    files_to_remove.each do |file_to_remove|
      relative_path = file_to_remove[7..]

      # execute :rm, relative_path
      puts relative_path
    end
  end

  protected

  def current_files_from_manifest
    filenames = Set.new

    ['manifest', 'manifest.1', 'manifest.2'].each do |file|
      json = JSON.parse capture(:cat, "#{file}.json")

      json.delete 'entrypoints'

      filenames.merge json.values
    end

    filenames
  end

  def files_to_remove
    current_files = current_files_from_manifest

    all_asset_files.tap do |list|
      list.reject! { |file| current_files.include?(file.gsub(/\.(?:gz|br)$/, '')) }

      list.sort!
    end
  end

  def all_asset_files
    capture(:find, '.', '-type f', '-mindepth 2', '-print').split("\n").map { |file| "/packs/#{file[2..]}" }
  end
end

namespace :webpacker do
  desc 'Back up the last deploy\'s manifest.json'
  task :backup_manifest do
    on roles(:app) do
      within current_path.join('public', 'packs') do
        execute :cp, 'manifest.1.json', 'manifest.2.json'
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
