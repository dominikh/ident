require "ident/response/basic_response"

class Ident
  module Response
    # This class provides access to information returned about the
    # user belonging to a connection.
    #
    # Note: You should not instantiate this class yourself.
    class USERID < BasicResponse
      # The operating system of the user
      #
      # @return [String]
      attr_reader :os

      # The charset on the system, defaults to US-ASCII
      #
      # @return [String]
      attr_reader :charset

      # The userid
      #
      # @return [String]
      attr_reader :userid

      # @param [String] os The os+charset string
      # @param [String] userid
      def initialize(os, userid)
        parts = os.split('-')
        @os = parts[0]
        @charset = parts[1..-1].join('-')
        @charset = 'US-ASCII' if @charset.empty?
        @userid = userid
      end
    end
  end
end
