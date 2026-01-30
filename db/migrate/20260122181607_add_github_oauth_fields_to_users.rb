class AddGithubOauthFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :github_id, :string
    add_column :users, :github_username, :string
    add_index :users, :github_id, unique: true
  end
end
