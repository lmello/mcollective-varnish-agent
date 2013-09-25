module MCollective
  module Agent
    class Varnish<RPC::Agent
      action "purge" do
        url_to_purge = request[:url] 
        parsed_url = URI.parse(url_to_purge)
        fail "Invalid Url" unless parsed_url.scheme == "http"
        hostname = parsed_url.host
        uri = parsed_url.request_uri
        v_version = discover_varnish_version
        purge_cmd = create_purge_command(v_version, uri, hostname)
        self.run(purge_cmd)
        reply[:purge_cmd] = purge_cmd
        reply[:urlpurged] = url_to_purge
      end
      def self.run(cmd) 
        command_output = `#{cmd}`
        command_status = $?
        unless command_status == 0
          fail "Error while running command: #{cmd}"
        end
        command_output
      end
      def discover_varnish_version
        varnish_version = run("/usr/sbin/varnishd -V 2>&1")
        if varnish_version =~ /varnish-(\d)/
          $1.to_i
        else 
          "NOTFOUND"
        end
      end
      
      def create_purge_command(varnish_version, uri, hostname)
        if varnish_version == 2
          purge_method = "purge.url"
        elsif varnish_version == 3
          purge_method = "ban.url" 
        else 
          fail "Varnish version isn't supported or was not found"
        end
        purge_cmd = "/usr/bin/varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082 #{purge_method} \"^#{uri}$\""
        return purge_cmd
      end
#      action "vcl" do
#      end
#
#      action "stats" do
#      end
#

    end
  end
end
