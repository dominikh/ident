require 'ident'

# Note: none of this examples will work when executed directly, they
# are rather meant for giving an overview how you would use the
# library in your own server applications.

# using the class method Ident.request
begin
  response = Ident.request("127.0.0.1", 12345, 12345)
  # if Ident.request returned an error, userid will be nil. If you want
  # to know what the error was, check Response::ERROR#type or use the
  # methods like `no_user?`
  username = response.userid || "fallback username"
rescue Timeout::Error, Errno::ECONNREFUSED
  # we couldn't connect to an identd, use a fallback username
  username = "fallback username"
end

# using an instance of Ident. basically the same as above, but you can
# set the arguments before invoking the request
begin
  i = Ident.new
  i.ip = "127.0.0.1"
  i.outbound = 12345
  i.inbound  = 12345
  i.timeout  = 5

  response = i.request
  username = response.userid || "fallback username"
rescue Timeout::Error, Errno::ECONNREFUSED
  username = "fallback username"
end

# you can ask for the userid, the os and the charset.
