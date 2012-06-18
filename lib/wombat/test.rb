$:.unshift File.dirname(__FILE__)
require 'crawler'

class MyCrawler
  include Wombat::Crawler

  base_url "http://ipp2.bland/timesaver.aspx"
  
  #some_data "css=div.formLabelLeft", :list
  some_data "css=div#ctl00_ContentPlaceHolder1_repeaterQuestion_ctl00_theQuestion_optionList_panelQuestion .. div", :list
  
  #another_info "xpath=//my/xpath[@style='selector']"
end

my_cool_crawler = MyCrawler.new
puts my_cool_crawler.crawl
