#!/usr/bin/env ruby
require 'open-uri'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'yaml'
require_relative 'group_scraper'
require_relative 'users_scraper'
class LinkedInParser
  include Capybara::DSL
  SITE = 'http://linkedin.com/'

  def initialize
    configure_capybara
    read_config
    visit SITE
  end

  def configure_capybara
    Capybara.default_driver = :webkit
    Capybara::Webkit.configure do |config|
      config.allow_unknown_urls
    end
  end

  def read_config
    config = YAML.load_file('config/general.yml')
    @email = config['general']['email']
    @password = config['general']['password']
  end

  def login
    fill_in('login-email', :with => @email)
    fill_in('login-password', :with => @password)
    click_button('login-submit')
    login_validation
  end

  def login_validation
    url = URI.parse(current_url)
    abort('Wrong login/password') if url.query == 'goback=' || url.path == '/uas/login-submit'
    puts 'Authorized.'
  end

  def routine
    case ARGV[0]
      when 'group'
        users_scraper = GroupScraper.new
        users_scraper.scrape_group
      when 'users'
        users_scraper = UsersScraper.new
        users_scraper.scrape_users
    end
  end
end

linkedin_parser = LinkedInParser.new
linkedin_parser.login
linkedin_parser.routine
