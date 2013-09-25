#!/usr/bin/env rspec

require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../", "agent", "varnish.rb")

describe "varnish agent" do
  before do
    agent_file = File.join([File.dirname(__FILE__), "../../agent/varnish.rb"])
    @agent = MCollective::Test::LocalAgentTest.new("varnish", :agent_file => agent_file).plugin
  end

  describe "#purge" do
    context "without url parameter" do
      it "should fail" do
        result = @agent.call(:purge)
        result.should_not be_successful
      end
    end 
    context "without a valid url" do
      it "should fail" do
        result = @agent.call(:purge, :url => "asdase412356/sdkfs")
        result.should_not be_successful
      end
    end
    context "with a valid url" do
      it "should be successful " do 
        url_to_purge = "http://example.com/images/image.jpg"
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should be_successful
      end
      it "should return purged url" do 
        url_to_purge = "http://example.com/images/image.jpg"
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should have_data_items(:urlpurged => url_to_purge)
      end
    end
    #context "with debug enabled" do 
    #  it "should return the command used to purge" do 
    #     url_to_purge = "http://example.com/images/image.jpg"
    #     result = @agent.call(:purge, :url=> url_to_purge)
    #     purge_cmd = "/usr/bin/varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082 " + " purge.url \"^/images/image.jpg$\"".shellescape
    #     result.should have_data_items(:purgecmd => "#{purge_cmd}", :urlpurged => url_to_purge)
    #  end
    #end
  end
end
