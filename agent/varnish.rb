module MCollective
  module Agent
    class Varnish<RPC::Agent
      action "purge" do
        url_to_purge = request[:url] 
        parsed_url = URI.parse(url_to_purge)
        fail "Invalid Url" unless parsed_url.scheme == "http"
        hostname = parsed_url.host
        uri = parsed_url.request_uri
        reply[:urlpurged] = url_to_purge
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
