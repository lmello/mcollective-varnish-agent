#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "agent", "varnish.rb")

describe "varnish agent" do
  before do
    agent_file = File.join([File.dirname(__FILE__), "../../agent/varnish.rb"])
    @agent = MCollective::Test::LocalAgentTest.new("varnish", :agent_file => agent_file).plugin
  end

  describe "purge" do
    it "should fail if didn't received url as parameter " do
      result = @agent.call(:purge)
      result.should_not be_successful
    end

    it "should fail if received invalid url as parameter" do
      result = @agent.call(:purge, :url => "asdase412356/sdkfs")
      result.should_not be_successful
    end

    it "should return the url that was purged" do 
      url_to_purge = "http://example.com/images/image.jpg"
      result = @agent.call(:purge, :url=> url_to_purge) 
      raise result.inspect
      result.should have_data_items(:urlpurged => url_to_purge)
    end
   
  end
end
