require 'capybara'
require_relative 'user'

class UsersScraper
  include Capybara::DSL
  def initialize
    config = YAML.load_file('config/general.yml')
    @input_file_path = config['users_scraper']['input_file_path']
    @output_file_path = config['users_scraper']['output_file_path']
  end

  def scrape_users
    urls = File.readlines(@input_file_path)
    urls.map!(&:chomp)
    urls.each do |url|
      @city = ''
      @country = ''
      @company = ''
      @job_title = ''
      @name = ''
      @surname = ''
      visit url
      if user_exists?
        get_name
        if user_currently_working?
          get_location
          get_company
          get_job_title
        end
      end
    save_user_to_db
    end
  end

  def get_name
    find('div.profile-detail')
    fullname = find('h1.pv-top-card-section__name', match: :first).text
    @name, @surname = fullname.split(' ', 2)
  end

  def get_location
    location = all('h4.pv-entity__location span')[1].text
    @city, @country = location.split(', ')
  rescue
    nil
  end

  def get_company
    @company = find('span.pv-entity__secondary-title', match: :first).text
  end

  def get_job_title
    @job_title = find('.pv-entity__summary-info h3', match: :first).text
  end


  def user_exists?
    URI.parse(current_url).path == '/in/unavailable/' ? false : true
  end

  def user_currently_working?
    find('section.experience-section')
    all('h4.pv-entity__date-range span')[1].text.include? 'Present'
  rescue
    false
  end

  def save_user_to_db
    User.create(company: @company,
                name: @name,
                surname: @surname,
                job_title: @job_title,
                country: @country,
                city: @city,
                url: url)
  end
end