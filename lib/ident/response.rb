require "ident/response/basic_response"
require "ident/response/user_id"
require "ident/response/error"

class Ident
  module Response
    # Returns an instance of {USERID} or {ERROR}, depending on the type of
    # reply.
    #
    # @param [String] s An ident reply as per RFC 1413
    # @return [USERID, ERROR]
    def self.from(s)
      ports, type, *addinfo = s.split(':').map {|o| o.strip}
      klass = self.const_get(type.to_sym)
      klass.new(*addinfo)
    end
  end
end
