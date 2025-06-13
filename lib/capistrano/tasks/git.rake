# frozen_string_literal: true

namespace :git do
  task :tag_release do
    on roles(:app) do
      within release_path do
        set(:current_revision, capture(:cat, 'REVISION'))
        set(:release_name, capture(:pwd, '-P').split('/').last)
      end
    end

    run_locally do
      tag_name = "#{fetch(:stage)}-#{fetch(:release_name)}"

      # user = capture(:git, "config --get user.name").strip
      # email = capture(:git, "config --get user.email").strip
      # tag_msg = "Deployed by #{user} <#{email}> to #{fetch :stage} as #{fetch :release_name}"
      # execute :git, %(tag #{tag_name} #{fetch :current_revision} -m "#{tag_msg}")

      execute :git, "tag #{tag_name} #{fetch :current_revision}"
      execute :git, 'push --tags origin'
    end
  end
end
