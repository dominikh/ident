require File.absolute_path "#{__FILE__}/../../lib/ident"
require 'mocha'

BareTest.extend Mocha::API

BareTest.toplevel_suite.teardown do
  begin
    BareTest.mocha_verify
  rescue Mocha::ExpectationError => e
    @failure_reason = e.message
    @status = :failure
  ensure
    BareTest.mocha_teardown
  end
end
