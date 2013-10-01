module MCollective
  module Util
    module Varnish
      class Base
        attr_reader :initialized, :varnish_version, :cmd_and_files
        alias initialized? initialized
        def initialize(*args)
          @varnish_version = discover_varnish_version
          @initialized = true
        end


        def run(cmd)
          command_output = `#{cmd}`
          fail "Could not run command: #{cmd}." unless $?.success? 
          return command_output
        end
        
        def discover_varnish_version
          version_output = run("/usr/sbin/varnishd -V 2>&1")
          if version_output =~ /varnish-(\d)/ and [2,3].include?($1.to_i)
            $1.to_i
          else 
            raise "Could not detect valid varnish version."
          end
        end

        def parse_url(url)
          parsed = URI.parse(url)
          unless parsed.scheme == "http"
            raise ArgumentError, "#parse_url require full http url as parameter"
          end 
          [parsed.host, parsed.request_uri]
        end
        
        def configure(config_hash)
          raise ArgumentError, "#configure argument must be hash" unless config_hash.is_a?(Hash)
          output_hash = Hash.new
          config_hash.each do |key, value| 
            if key =~ /_cmd$/ 
              output_hash[key] = value
            elsif key =~ /_file$/ 
              output_hash[key] = value
            else
              raise ArgumentError, "#configure does not support hash key: #{key}"
            end
          end
          @cmd_and_files = output_hash
        end
      end
    end
  end
end
