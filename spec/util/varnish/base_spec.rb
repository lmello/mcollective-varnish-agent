#!/usr/bin/env rspec
#
require 'spec_helper'
require File.join(File.dirname(__FILE__), "../../..", "util", "varnish", "base.rb")

module MCollective
  module Util
    module Varnish
      describe Base do
        context "#initialize" do
          it ".initialized? be true" do
            @base = Base.new
            expect(@base.initialized?).to be_true
          end
        end

        context "#run" do 
          it "without cmd it raises error" do
            @base = Base.new
            expect{@base.run}.to raise_error ArgumentError
          end 

          it "accept cmd to run" do 
            Base.any_instance.expects(:`).with("foo").returns("foo_output") 
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            @base.run("foo")
          end
          it "raise when cmd fails" do 
            Base.any_instance.expects(:`).with("foo").returns("foo: command not found") 
            $?.expects(:success?).once.returns(false)
            @base = Base.new
            expect{@base.run("foo")}.to raise_error RuntimeError, "Could not run command: foo."
          end
          it "return command output" do 
            Base.any_instance.expects(:`).with("foo").returns("foo_output") 
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            result = @base.run("foo")
            result.should == "foo_output"
          end
        end 
        context "#discover_varnish_version" do 
          it "raises error when not found" do 
            Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd: command not found")
            $?.expects(:success?).once.returns(false)
            @base = Base.new
            expect{@base.discover_varnish_version}.to raise_error RuntimeError, "Could not run command: /usr/sbin/varnishd -V 2>&1."
          end

          it "raises error when version not 2 or 3" do 
            Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-1.0.0 )")
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            expect{@base.discover_varnish_version}.to raise_error RuntimeError, "Could not detect valid varnish version."
          end


          it "return varnish version 2" do 
            Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-2.1.5 )")
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            @base.discover_varnish_version.should == 2

          end

          it "return varnish version 3" do 
            Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-3.0.4 )")
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            @base.discover_varnish_version.should == 3
          
          end

          it "creates @varnish_version" do 
            Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-2.1.5 )")
            $?.expects(:success?).once.returns(true)
            @base = Base.new
            @base.discover_varnish_version
            @base.varnish_version.should == 2

          end
        end
        context "#parse_url" do 
          context "without any parameter" do 
            it "raises error" do 
              @base = Base.new 
              expect{@base.parse_url}.to raise_error ArgumentError
            end
          end 
          context "with full url" do 
            it "parses http" do
              @base = Base.new
              hostname, uri = @base.parse_url("http://example.com/images/image.jpg") 
              hostname.should == "example.com"
              uri.should == "/images/image.jpg"
            end
            it "raises error when it isn't http" do 
              @base = Base.new
              expect{hostname, uri = @base.parse_url("https://example.com/images/image.jpg")}.to raise_error ArgumentError, "#parse_url require full http url as parameter"
            end           
          end
          context "without a full url" do
            it "raises error" do 
              @base = Base.new
              expect{hostname, uri = @base.parse_url("example.com/images/image.jpg")}.to raise_error ArgumentError, "#parse_url require full http url as parameter"
            end
          end
        end
      end
    end
  end
end
