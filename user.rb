require 'active_record'
require 'yaml'

db_config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(db_config['test'])

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :company
    t.string :name
    t.string :surname
    t.string :job_title
    t.string :country
    t.string :city
    t.string :url
  end
end

class User < ActiveRecord::Base
end