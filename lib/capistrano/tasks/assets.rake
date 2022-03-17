# frozen_string_literal: true

class PruneAssetsTask
  extend Forwardable

  KEEP_ASSETS = 5

  def_delegators :@ssh, :capture, :execute

  def initialize(ssh)
    @ssh = ssh
  end

  def prune!
    files_to_remove.each do |path|
      puts path
      execute :rm, path
    end
  end

  protected

  def files_to_remove
    all_asset_files
      .values
      .flat_map { _1[KEEP_ASSETS..] }
      .compact
  end

  def all_asset_files
    files = Hash.new { |h, k| h[k] = [] }

    all_asset_directories.each do |section|
      lines = section.split("\n")
      directory = lines.shift[..-2]

      lines.each do |line|
        filename = line.split.last

        files["#{directory}/#{filename.gsub(/-\h{64}/, '')}"] << "#{directory}/#{filename}"
      end
    end

    files
  end

  # `ls -cltR` lists all files recursively, sorted by creation date. Directories are separated by two newlines.
  def all_asset_directories
    capture(:ls, '-cltR', '--time-style=+"%s"')
      .lines
      .reject { _1[/^(?:d|total)/] }
      .join
      .split("\n\n")
  end
end

namespace :assets do
  desc 'Clean old assets'
  task :prune do
    on roles(:app) do
      within current_path.join('public', 'assets') do
        PruneAssetsTask.new(self).prune!
      end
    end
  end
end
