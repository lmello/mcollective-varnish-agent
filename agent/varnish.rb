module MCollective
  module Agent
    class Varnish<RPC::Agent
      action "purge" do
        url_to_purge = request[:url] 
        parsed_url = URI.parse(url_to_purge)
        fail "Invalid Url" unless parsed_url.scheme == "http"
        hostname = parsed_url.host
        uri = parsed_url.request_uri
        Log.warn("URL parsed: #{hostname} ,  #{uri}")
        v_version = discover_varnish_version
        Log.warn("Varnish version discovered: #{v_version}")
        purge_cmd = create_purge_command(v_version, uri, hostname)
        Log.warn("Purge cmd: #{purge_cmd}")
        purge_output = run(purge_cmd)
        Log.warn("purge command run.... #{purge_output}")
        if request.include?(:debug) 
          reply[:purge_cmd] = purge_cmd
        end
        reply[:urlpurged] = url_to_purge
      end
      def run(cmd) 
        Log.warn("Running command: #{cmd}")
        command_output = `#{cmd}`
        command_status = $?
        unless command_status == 0
          fail "Error while running command: #{cmd}"
        end
        Log.warn("Command output: #{command_output}")
        return command_output
      end
      def discover_varnish_version
        varnishd_output = run("/usr/sbin/varnishd -V 2>&1")
        Log.warn("Varnishd -V output: #{varnishd_output}")
        if varnishd_output =~ /varnish-(\d)/
          Log.warn("Varnishd detected version #{$1}")
          version=$1.to_i
          return version
        else 
          return "NOTFOUND"
        end
      end
      
      def create_purge_command(varnish_version, uri, hostname)
        Log.warn("Varnish Version: #{varnish_version}, uri: #{uri}, hostname: #{hostname}")
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
