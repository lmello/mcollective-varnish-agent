module MCollective
  module Agent
    class Varnish<RPC::Agent
      action "purge" do
        url_to_purge = request[:url] 
        File.open("/tmp/teste","w") do |file|
          file.write(url_to_purge)
        end
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
