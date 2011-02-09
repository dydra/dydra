##
# Patches for Ruby's built-in XML-RPC client.
#
# @see http://www.ruby-doc.org/stdlib/libdoc/xmlrpc/rdoc/index.html
class XMLRPC::Client
  alias_method :do_rpc_broken, :do_rpc

  ##
  # This patch is a workaround for a REXML bug in Ruby 1.9.2.
  #
  # @see http://www.ruby-forum.com/topic/463233
  def do_rpc(request, async = false)
    data = do_rpc_broken(request, async)
    data.force_encoding(Encoding::UTF_8) if data.respond_to?(:force_encoding)
    data
  end
end # XMLRPC::Client
