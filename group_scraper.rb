require 'capybara'

class GroupScraper
  include Capybara::DSL
  def initialize
    read_config
    @content = File.readlines(@input_file_path)
    @content.map!(&:chomp).map!(&:downcase)
    visit "https://www.linkedin.com/groups/#{@group_id}/members"
    url = URI.parse(current_url).to_s
    abort ('No such group or you don\'t have permission to view its members') if
        url != "https://www.linkedin.com/groups/#{@group_id}/members"
  end

  def read_config
    config = YAML.load_file('config/general.yml')
    @group_id = config['group_scraper']['group_id']
    @number_of_users = config['group_scraper']['number_of_users']
    @input_file_path = config['group_scraper']['input_file_path']
    @output_file_path = config['group_scraper']['output_file_path']
    @counter = 0
  end

  def scrape_group
    File.open(@output_file_path, 'w')
    find('div.member-block', match: :first) # Ждем загрузки списка пользователей
    loop do
      all('div.member-block').each do |info| # Для каждого пользователя из списка
        check_and_add_user(info)
      end
      next_page
    end
  end

  def next_page
    find('a.next').click
    sleep 2
  rescue
    puts 'End of list reached'
    exit
  end

  def check_and_add_user(info)
    user_info = info.find('p.entity-headline').text.downcase
    if @content.any? { |string| user_info.include?(string)}
      File.open('members', 'a+') { |file| file.puts info.find('a')['href']}
      @counter += 1
      exit if @counter == @number_of_users
    end
  end
end