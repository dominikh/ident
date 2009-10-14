class Ident
  require 'socket'
  require 'timeout'

  KNOWN_ERRORS = ["INVALID-PORT" "NO-USER" "HIDDEN-USER" "UNKNOWN-ERROR"]
  module Response
    # This is the blankslate response which ensures that both kind of
    # responses respond to all required methods. You should never have
    # to work with this class directly.
    class BasicResponse
      # Is the response the result of an error?
      def error?;  false; end
      def os;      nil;   end
      def charset; nil;   end
      def userid;  nil;   end

      private
      def self.error_to_method_name(error)
        (error.downcase.tr('-', '_') + "?").to_sym
      end

      public
      KNOWN_ERRORS.each do |e|
        define_method(error_to_method_name(e)) do
          false
        end
      end
    end

    class USERID < BasicResponse
      # the operating system of the user
      attr_reader :os
      # the charset on the system, defaults to US-ASCII
      attr_reader :charset
      # the userid
      attr_reader :userid
      def initialize(os, userid)
        parts = os.split('-')
        @os = parts[0]
        @charset = parts[1..-1].join('-')
        @charset = 'US-ASCII' if @charset.empty?
        @userid = userid
      end
    end

    # This class gives access to the error returned by an identd. It
    # defines method for every possible kind of error: invalid_port?
    # no_user? hidden_user? unknown_error?
    class ERROR < BasicResponse
      KNOWN_ERRORS.each do |e|
        define_method(error_to_method_name(e)) do
          @type == e
        end
      end

      attr_reader :type
      def initialize(type)
        @type = type
      end

      # @see BasicResponse#error?
      def error?; true; end
      # Did we specify an invalid port?
      def invalid_port?; @type == "INVALID-PORT"; end
      # Is no user known for the given connection specification?
      def no_user?; @type == "NO-USER"; end
      # Does the identd hide information from us?
      def hidden_user?; @type == "HIDDEN-USER"; end
      # Did an unknown error occur?
      def unknown_error?; @type == "UNKNOWN-ERROR"; end
    end

    # Returns an instance of {USERID} or {ERROR}, depending on the type of
    # reply.
    def self.from(s)
      ports, type, *addinfo = s.split(':')
      klass = self.const_get(type.to_sym)
      klass.new(*addinfo)
    end
  end

  attr_accessor :ip
  attr_accessor :outbound
  attr_accessor :inbound
  attr_accessor :timeout
  attr_reader :response
  # @see Ident.request
  def initialize(ip = nil, outbound = nil, inbound = nil, timeout = 10)
    @ip, @outbound, @inbound, @timeout = ip, outbound, inbound, timeout
    @response = nil
  end

  # @see Ident.request
  def request
    @response = self.class.request(@ip, @outbound, @inbound, @timeout)
  end

  # This method connects to an identd at `ip` and queries information
  # for the connection `outbound`->`inbound` where `outbound` is the
  # port a connection is coming from (usually anything >1024) and
  # `inbound` is the port connected to, the port your service is
  # listening on (e.g. 6667 in the case of an IRCd)
  #
  #
  # @example user A connects to our server on port 23, coming from 123.123.123.123 on port 6789
  #  Ident.request('123.123.123.123', 6789, 23)
  #
  # @param [String]  ip            The IP of the ident server
  # @param [Integer] outbound      The port from which the connection is coming
  # @param [Integer] inbound       The port to which was connected
  # @param [Integer] timeout_after The timeout, defaults to 10 seconds
  #
  # @raise [Timeout::Error] In case of a timeout
  # @raise [Errno::ECONNREFUSED] If no identd was running at the destination host
  #
  # @return [Response::USERID] if we successfully queried the ident server
  # @return [Response::ERROR]  in case of an error
  def self.request(ip, outbound, inbound, timeout_after = 10)
    r = nil
    timeout(timeout_after) do
      t = TCPSocket.new(ip, 113)
      t.puts [outbound, inbound].join(', ')
      r = t.gets
      t.close
    end

    # in case the identd just kills our connection
    r ||= "#{outbound}, #{inbound}:ERROR:UNKNOWN-ERROR"

    r.chomp!
    Response.from(r)
  end
end



