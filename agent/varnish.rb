module MCollective
  module Agent
    class Varnish<RPC::Agent
      action "purge" do
        #This action will purge the url from
        #varnish cache using varnishadm. 
        #It receives :url as full url
        #ex: url=http://example.com/images/image.jpg
        #And return success if it could purge the url.
        #Leonardo Rodrigues de Mello <l@lmello.eu.org>
        url_to_purge = request[:url] 
        #1 - Parse Received url
        parsed_url = URI.parse(url_to_purge)
        fail "Invalid Url" unless parsed_url.scheme == "http"
        hostname = parsed_url.host
        uri = parsed_url.request_uri
        Log.debug("URL parsed: #{hostname} ,  #{uri}")
        #2 - Discover Varnish Version
        v_version = discover_varnish_version
        Log.debug("Varnish version discovered: #{v_version}")
        #3 - Create purge command for the current varnish version
        purge_cmd = create_purge_command(v_version, uri, hostname)
        Log.debug("Purge cmd: #{purge_cmd}")
        #4 - Run the purge command.
        purge_output = run(purge_cmd)
        Log.debug("purge command run.... #{purge_output}")
        if request.include?(:debug) 
          #If we received debug=true log the purge command.
          reply[:purge_cmd] = purge_cmd
        end
        #5 - Add the purged url to response data_bag
        reply[:urlpurged] = url_to_purge
      end
      
      def run(cmd) 
        #This method run commands 
        #and returns command_output.
        #It fails if command exit code is not 0.
        Log.debug("Running command: #{cmd}")
        command_output = `#{cmd}`
        command_status = $?
        unless command_status == 0
          fail "Error while running command: #{cmd}"
        end
        Log.debug("Command output: #{command_output}")
        return command_output
      end

      def discover_varnish_version
        #This method Discover the varnish version
        #as one integer.
        varnishd_output = run("/usr/sbin/varnishd -V 2>&1")
        Log.debug("Varnishd -V output: #{varnishd_output}")
        if varnishd_output =~ /varnish-(\d)/
          Log.debug("Varnishd detected version #{$1}")
          version=$1.to_i
          return version
        else 
          return "NOTFOUND"
        end
      end
      
      def create_purge_command(varnish_version, uri, hostname)
        #This method returns the correct purge command for the
        #current varnish version.
        Log.debug("Varnish Version: #{varnish_version}, uri: #{uri}, hostname: #{hostname}")
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
    end
  end
end
