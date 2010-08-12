require 'socket'
require 'timeout'

class Ident
  KNOWN_ERRORS = ["INVALID-PORT" "NO-USER" "HIDDEN-USER" "UNKNOWN-ERROR"]
  require "ident/response"

  # @return [String]
  attr_accessor :ip

  # @return [Number]
  attr_accessor :outbound

  # @return [Number]
  attr_accessor :inbound

  # @return [Number]
  attr_accessor :timeout

  # @return [Response::USERID, Response::ERROR]
  attr_reader :response

  # @param (see Ident.request)
  # @see Ident.request
  def initialize(ip = nil, outbound = nil, inbound = nil, timeout_after = 10)
    @ip, @outbound, @inbound, @timeout = ip, outbound, inbound, timeout_after
    @response = nil
  end


  # Calls {Ident.request} using the attributes supplied to the
  # constructor. The result can be accessed using {#response}
  #
  # @return [void]
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



