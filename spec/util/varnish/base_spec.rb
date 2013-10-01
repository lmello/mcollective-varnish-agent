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
          context "without parameter" do  
            it "raises error" do
              @base = Base.new
              expect{@base.run}.to raise_error ArgumentError
            end 
          end 
          context "with parameter" do 
            context "when cmd fails" do
              it "raises error" do 
                Base.any_instance.expects(:`).with("foo").returns("foo: command not found") 
                $?.expects(:success?).once.returns(false)
                @base = Base.new
                expect{@base.run("foo")}.to raise_error RuntimeError, "Could not run command: foo."
              end
            end
            context "when cmd succeed" do 
              it "return cmd output" do 
                Base.any_instance.expects(:`).with("foo").returns("foo_output") 
                $?.expects(:success?).once.returns(true)
                @base = Base.new
                result = @base.run("foo")
                result.should == "foo_output"
              end
            end
          end
        end 
        context "#discover_varnish_version" do 
          context "when can't find varnishd" do
            it "raises error" do 
              Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd: command not found")
              $?.expects(:success?).once.returns(false)
              @base = Base.new
              expect{@base.discover_varnish_version}.to raise_error RuntimeError, "Could not run command: /usr/sbin/varnishd -V 2>&1."
            end
          end
          context "when version is not 2 or 3" do 
            it "raises error" do 
              Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-1.0.0 )")
              $?.expects(:success?).once.returns(true)
              @base = Base.new
              expect{@base.discover_varnish_version}.to raise_error RuntimeError, "Could not detect valid varnish version."
            end
          end
          context "when version is 2" do
            it "return 2" do 
              Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-2.1.5 )")
              $?.expects(:success?).once.returns(true)
              @base = Base.new
              @base.discover_varnish_version.should == 2
            end
          end

          context "when version is 3" do
            it "return 3" do 
              Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-3.0.4 )")
              $?.expects(:success?).once.returns(true)
              @base = Base.new
              @base.discover_varnish_version.should == 3
            end
          end
          context "when successful" do
            it "creates @varnish_version" do 
              Base.any_instance.expects(:`).with("/usr/sbin/varnishd -V 2>&1").returns("varnishd (varnish-2.1.5 )")
              $?.expects(:success?).once.returns(true)
              @base = Base.new
              @base.discover_varnish_version
              expect{@base.responds_to?(:varnish_version)}.to be_true
              @base.varnish_version.should == 2
            end
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
        context "#configure" do
          context "without any parameter" do
            it "raises error" do
              @base = Base.new
              expect{@base.configure}.to raise_error ArgumentError
            end
          end
          context "without hash parameter" do 
            parameters = {"nil"=> nil, "array" => [1,2], "string" => "test", "number" => 3, "undefined" => :undef}
            parameters.each do |type,parameter|
              it "#{type} raises error" do
                @base = Base.new
                expect{@base.configure(parameter)}.to raise_error ArgumentError, "#configure argument must be hash"
              end
            end
          end
          context "with hash parameter" do 
            context "Correct hash cmd keys" do 
              it "return default value" do 
                @base = Base.new 
                parameter = {"stat_cmd" => "/usr/bin/varnishstat", "daemon_cmd" => "/usr/sbin/varnishd"} 
                @base.configure(parameter) 
                @base.cmd_and_files.should == parameter
              end
              #it "return config value" do 
              #  
              #end
            end

            context "Correct hash file keys" do
              it "return default value" do 
                @base = Base.new 
                parameter = {"default_vcl_file" => "/usr/bin/varnishstat", "secret_file" => "/usr/sbin/varnishd"} 
                @base.configure(parameter) 
                @base.cmd_and_files.should == parameter
              end
              #it "return config value" do 
              #
              #end
            end
            context "Correct hash cmd and file keys" do 
              it "return default value" do 
                @base = Base.new 
                parameter = {"stat_cmd" => "/usr/bin/varnishstat", "daemon_cmd" => "/usr/sbin/varnishd", "default_vcl_file" => "/usr/bin/varnishstat", "secret_file" => "/usr/sbin/varnishd"} 
                @base.configure(parameter) 
                @base.cmd_and_files.should == parameter
              end
             # it "return config value" do 
             # 
             # end
            end
            context "invalid hash keys" do 
              it "raises error" do 
                @base = Base.new 
                parameter = {"stat_cmd" => "/usr/bin/varnishstat", "secret_file" => "/usr/sbin/varnishd", "invalid_hash_key" => "/usr/varnish/invalid.txt"} 
                expect{@base.configure(parameter)}.to raise_error ArgumentError, "#configure does not support hash key: invalid_hash_key"
              end
            end
          end
        end

      end
    end
  end
end
