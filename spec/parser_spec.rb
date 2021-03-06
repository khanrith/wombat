require 'spec_helper'

describe Wombat::Parser do
  before(:each) do
    crawler = Class.new
    crawler.send(:include, Wombat::Parser)
    @parser = crawler.new
    @metadata = Wombat::Metadata.new
  end

  it 'should request page document with correct url' do
    @metadata.base_url "http://www.google.com"
    @metadata.list_page "/search"
    fake_document = double :document
    fake_parser = double :parser
    fake_document.should_receive(:parser).and_return(fake_parser)
    @parser.mechanize.should_receive(:get).with("http://www.google.com/search").and_return fake_document
    
    @parser.parse @metadata
  end

  it 'should send correct data to locate method' do
    fake_document = double :document
    fake_parser = double :parser
    fake_document.should_receive(:parser).and_return(fake_parser)
    @parser.mechanize.stub(:get).and_return fake_document
    @parser.should_not_receive :locate
    @parser.parse @metadata
  end

  it 'should invoke metadata callbacks' do
    fake_document = double :document
    fake_parser = double :parser
    property = double :property
    block_called = false
    block = lambda { |p| block_called = true }
    
    property.stub(:result)
    fake_document.should_receive(:parser).and_return(fake_parser)
    property.should_receive(:callback).twice.and_return(block)
    property.should_receive(:result=).with(true)
    
    @parser.mechanize.stub(:get).and_return fake_document
    @metadata.stub(:all_properties).and_return [property]
    @parser.should_receive(:locate).with(property)

    @parser.parse @metadata

    block_called.should be_true
  end

  it 'should invoke callback with parsed data' do
    fake_document = double :document
    fake_parser = double :parser
    property = double :property
    block_called = false
    block = lambda { |p|
      block_called = true 
      p.should == "blah"
    }
    
    fake_document.should_receive(:parser).and_return(fake_parser)
    property.should_receive(:callback).twice.and_return(block)
    property.should_receive(:result=).with(true)
    
    @parser.mechanize.stub(:get).and_return fake_document
    @metadata.stub(:all_properties).and_return [property]
    @parser.should_receive(:locate).with(property).and_return("blah")

    @parser.parse @metadata

    block_called.should be_true
  end

  it 'should return hash with requested properties' do
    hash = double :results
    fake_parser = double :parser
    fake_document = double :document

    fake_document.should_receive(:parser).and_return fake_parser
    @parser.mechanize.stub(:get).and_return fake_document
    @metadata.should_receive(:flatten).and_return hash

    @parser.parse(@metadata).should == hash
  end

  it 'should not include null results in iterated block' do
    fake_parser = double :parser
    fake_document = double :document
    c1 = double :context
    c2 = double :context
    it = Wombat::Iterator.new "it_selector"
    it.prop_1 "some_selector"
    
    @parser.should_receive(:context=).ordered
    @metadata.should_receive(:iterators).and_return [it]
    @metadata.should_receive(:flatten)
    fake_document.should_receive(:parser).and_return(fake_parser)
    @parser.mechanize.stub(:get).and_return fake_document
    @parser.should_receive(:select_nodes).with("it_selector").and_return [c1, c2]
    @parser.should_receive(:context=).with(c1).ordered
    @parser.should_receive(:context=).with(c2).ordered
    @parser.should_receive(:context=).ordered
    @parser.should_receive(:locate).with(it['prop_1']).and_return(12)
    @parser.should_receive(:locate).with(it['prop_1']).and_return(nil)
    @parser.stub(:locate)

    @parser.parse(@metadata)

    it["prop_1"].result.should == [12]
  end

  it 'should correctly parse xml documents' do
    fake_document = double :xml
    fake_parser = double :parser
    @metadata.format :xml
    @parser.mechanize.should_not_receive(:get)
    RestClient.should_receive(:get).and_return fake_document
    Nokogiri.should_receive(:XML).with(fake_document).and_return fake_parser
    @parser.should_receive(:context=).with(fake_parser)
    @parser.should_receive(:context=)

    @parser.parse @metadata
  end
end