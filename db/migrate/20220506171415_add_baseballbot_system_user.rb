class AddBaseballbotSystemUser < ActiveRecord::Migration[7.0]
  def up
    SystemUser.create! username: 'BaseballBot'
  end
end
