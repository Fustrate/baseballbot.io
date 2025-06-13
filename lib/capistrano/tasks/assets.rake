# frozen_string_literal: true

class PruneAssetsTask
  KEEP_ASSETS = 5

  def initialize(ssh)
    @ssh = ssh
  end

  def prune!
    files_to_remove.each do |path|
      puts path
      @ssh.execute :rm, path
    end
  end

  protected

  def files_to_remove
    grouped_assets
      .values
      .flat_map { it[KEEP_ASSETS..] }
      .compact
  end

  # Creates a list of all versions of a particular asset, from newest to oldest.
  def grouped_assets
    files = Hash.new { |h, k| h[k] = [] }

    asset_sections.each do |section|
      lines = section.split("\n")
      directory = lines.shift[..-2]

      lines.each do |line|
        filename = line.split.last

        files["#{directory}/#{filename.gsub(/-\h{40,64}/, '')}"] << "#{directory}/#{filename}"
      end
    end

    files
  end

  # `ls -cltR` lists all files recursively, sorted by creation descending. Directories are separated by two newlines.
  def asset_sections
    @ssh.capture(:ls, '-cltR', '--time-style=+"%s"')
      .lines
      .reject { it[/^(?:d|total)/] }
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
