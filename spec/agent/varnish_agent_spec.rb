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
    context "with a valid url on varnish 2" do
      it "should be successful " do 
        url_to_purge = "http://example.com/images/image.jpg"
        @agent.expects(:discover_varnish_version).returns(2)
        @agent.expects(:run).returns("")
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should be_successful
      end
      it "should return purged url" do 
        url_to_purge = "http://example.com/images/image.jpg"
        @agent.expects(:discover_varnish_version).returns(2)
        @agent.expects(:run).returns("")
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should have_data_items(:urlpurged => url_to_purge)
      end
    end
 
    context "with a valid url on varnish 3" do
      it "should be successful " do 
        url_to_purge = "http://example.com/images/image.jpg"
        @agent.expects(:discover_varnish_version).returns(3)
        @agent.expects(:run).returns("")
 
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should be_successful
      end
      it "should return purged url" do 
        url_to_purge = "http://example.com/images/image.jpg"
        @agent.expects(:discover_varnish_version).returns(3)
        @agent.expects(:run).returns("")
 
        result = @agent.call(:purge, :url=> url_to_purge) 
        result.should have_data_items(:urlpurged => url_to_purge)
      end
    end
    context "with debug enabled on varnish 2" do 
      it "should return the purge command" do 
         url_to_purge = "http://example.com/images/image.jpg"
         @agent.expects(:discover_varnish_version).returns(2)
         @agent.expects(:run).returns("")

         result = @agent.call(:purge, {:url=> url_to_purge, :debug=> true} )
         result.should have_data_items(:purge_cmd => /.*varnishadm.*purge\.url.*\/images\/image.jpg.*/ , :urlpurged => url_to_purge)
      end
    end
    context "with debug enabled on varnish 3" do 
      it "should return purge command" do 
         url_to_purge = "http://example.com/images/image.jpg"
         @agent.expects(:discover_varnish_version).returns(3)
         @agent.expects(:run).returns("")
 
         result = @agent.call(:purge, {:url=> url_to_purge, :debug=> true} )
         result.should have_data_items(:purge_cmd => /.*varnishadm.*ban\.url.*\/images\/image.jpg.*/ , :urlpurged => url_to_purge)
          
      end
    end
  end
  
  describe "#discover_varnish_version" do 
    @varnish_version_cmd="/usr/sbin/varnishd -V 2>&1"
    context "with varnish 2" do 
      it "should detect varnish version" do 
        @agent.expects(:run).returns("varnishd (varnish-2.1.5 SVN )\nCopyright (c) 2006-2009 Linpro AS / Verdens Gang AS\n").once
        result = @agent.discover_varnish_version
        result.should == 2
      end
    end
    context "with varnish 3" do 
      it "should detect varnish version" do 
        @agent.expects(:run).returns("varnishd (varnish-3.0.3 revision 9e6a70f)\nCopyright (c) 2006 Verdens Gang AS\nCopyright (c) 2006-2011 Varnish Software AS\n").once
        result = @agent.discover_varnish_version
        result.should == 3
      end
    end

    context "without varnish installed" do 
      it "should fail" do 
        @agent.expects(:run).returns("sh: varnishd: command not found\n").once
        result = @agent.discover_varnish_version
        result.should == "NOTFOUND"
      end
    end
     
  end


end
