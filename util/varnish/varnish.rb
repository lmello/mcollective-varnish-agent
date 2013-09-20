module MCollective
  module Util
    module Varnish
      class Base
        def initialize
          configure
        end

        def configure
          @stat_cmd = Config.instance.pluginconf.fetch("varnish.varnishstat", `which varnishstat`.chomp)
          @adm_cmd = Config.instance.pluginconf.fetch("varnish.varnishadm", `which varnishadm`.chomp)
          @logger_cmd = Config.instance.pluginconf.fetch("varnish.logger", "/usr/bin/logger")
          @default_vcl = Config.instance.pluginconf.fetch("varnish.vcl_file", "/etc/varnish/default.vcl")
        end
        
        def activate? 
          raise "could not find varnishstat cmd" unless  File.executable?(@stat_cmd) 
          raise "could not find varnishadm command " unless  File.executable?(@adm_cmd) 
          raise "could not find vcl file #{default_vcl} " unless  File.exists?(@default_vcl) 
        end
        
      end
    end
  end
end
