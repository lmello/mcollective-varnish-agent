module MCollective
  module Util
    module Varnish
      class Base
        def initialize
          @commands = Hash.new
          @files = Hash.new 
          command_hash = {"stat_cmd" => "varnishstat", "adm_cmd" => "varnishadm", 
            "top_cmd" => "varnishtop", "log_cmd" => "logger" }
          file_hash = {"default_vcl_file" => "/etc/varnish/default.vcl", "secret_file" => "/etc/varnish/secret" }
          @commands = configure(command_hash)
          @files = configure(file_hash)
        end

        def configure(config_hash)
          output = Hash.new
          config_hash.each do |key, value| 
            output[key] = Config.instance.pluginconf.fetch("varnish.#{key}", `which #{value}`.chomp)
            if key =~ /cmd/  #commands must have cmd in key name
              raise "Could not find #{value} command" unless File.executable?(@commands[key])
            elsif key =~ /file/ #files must have file in key name 
              raise "Could not find #{value} file" unless File.exists?(@files[key])
            else 
              raise "Config hash have key #{key}, but it only support key name with cmd or file." 
            end
            output
          end 
        end
      end
    end
  end
end
