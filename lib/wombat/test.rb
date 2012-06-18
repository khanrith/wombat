$:.unshift File.dirname(__FILE__)
require 'crawler'

class MyCrawler
  include Wombat::Crawler

  base_url "http://ipp2.bland/timesaver.aspx"
  
  some_data "css=div.formLabelLeft", :list
  another_info "xpath=//my/xpath[@style='selector']"
end

my_cool_crawler = MyCrawler.new
my_cool_crawler.crawl
