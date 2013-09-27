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

    versions = {2 => { "purge_method"  => "purge" },
                3 => { "purge_method"  => "ban"}
               }
    versions.each do |version, test_options |
      context "with a valid url on varnish #{version}" do
        it "should be successful " do 
          url_to_purge = "http://example.com/images/image.jpg"
          @agent.expects(:discover_varnish_version).returns(version)
          @agent.expects(:run).returns("")
          result = @agent.call(:purge, :url=> url_to_purge) 
          result.should be_successful
        end
        it "should return purged url" do 
          url_to_purge = "http://example.com/images/image.jpg"
          @agent.expects(:discover_varnish_version).returns(version)
          @agent.expects(:run).returns("")
          result = @agent.call(:purge, :url=> url_to_purge) 
          result.should have_data_items(:urlpurged => url_to_purge)
        end
      end

      context "with debug enabled on varnish #{version}" do 
        it "should return the purge command" do 
           url_to_purge = "http://example.com/images/image.jpg"
           @agent.expects(:discover_varnish_version).returns(version)
           @agent.expects(:run).returns("")
  
           result = @agent.call(:purge, {:url=> url_to_purge, :debug=> true} )
           result.should have_data_items(:purge_cmd => /.*varnishadm.*#{test_options["purge_method"]}\.url.*\/images\/image.jpg.*/ , :urlpurged => url_to_purge)
        end
      end
    end
  end
  
  describe "#discover_varnish_version" do 
    tests = {"with varnish 2"  => { "run_output" => "varnishd (varnish-2.1.5 SVN )\nCopyright (c) 2006-2009 Linpro AS / Verdens Gang AS\n", "should" => 2},
             "with varnish 3"  => { "run_output" => "varnishd (varnish-3.0.3 revision 9e6a70f)\nCopyright (c) 2006 Verdens Gang AS\nCopyright (c) 2006-2011 Varnish Software AS\n", "should" => 3} ,
            }

    tests.each do |context_title, test_value| 
      context "#{context_title}" do 
        it "should detect varnish version" do 
          @agent.expects(:run).with('/usr/sbin/varnishd -V 2>&1').returns(test_value["run_output"]).once
          result = @agent.discover_varnish_version
          result.should == test_value["should"]
        end
      end
    end

    context "without varnish installed" do 
      it "should fail" do 
        @agent.expects(:run).with('/usr/sbin/varnishd -V 2>&1').returns("sh: varnishd: command not found\n").once
        result = @agent.discover_varnish_version
        result.should == "NOTFOUND"
      end
    end
  end


end
