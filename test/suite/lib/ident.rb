require 'baretest'

BareTest.suite("ident") do
  suite "::Response" do
    suite ".from" do
      assert "A response should be built from a string" do
        Ident::Response.from(
                             "0, 0:USERID:SYSTEM:YOURID"
                             ).is_a? Ident::Response::BasicResponse
      end

      assert "A string containing an userid should result in a positive response" do
        Ident::Response.from(
                             "0, 0:USERID:SYSTEM:YOURID"
                             ).is_a? Ident::Response::USERID
      end

      assert "A string containing an error should result in a errornous response" do
        Ident::Response.from(
                             "0, 0:ERROR:NO-USER"
                             ).is_a? Ident::Response::ERROR
      end
    end # .from

    suite "An USERID response" do
      setup do
        @response1 = Ident::Response.from("0, 0:USERID:SYSTEM:YOURID")
        @response2 = Ident::Response.from("0, 0:USERID:SYSTEM-UTF-8:YOURID")
        @response3 = Ident::Response.from("0, 0 : USERID : SYSTEM-UTF-8 : YOURID")
      end

      assert "should contain the userid" do
        equal("YOURID", @response1.userid)
      end

      assert "should contain the operating system" do
        equal("SYSTEM", @response1.os)
      end

      assert "should contain the charset on the machine" do
        equal("UTF-8", @response2.charset)
      end

      assert "should have a default charset" do
        equal("US-ASCII", @response1.charset)
      end

      assert "should not be an error" do
        not @response1.error?
      end

      assert "should strip spaces" do
        equal("YOURID", @response3.userid)
        equal("UTF-8",  @response3.charset)
        equal("SYSTEM", @response3.os)
      end
    end # An USERID response

    suite "An ERROR response" do
      setup do
        @response1 = Ident::Response.from("0, 0:ERROR:INVALID-PORT")
        @response2 = Ident::Response.from("0, 0:ERROR:NO-USER")
        @response3 = Ident::Response.from("0, 0:ERROR:HIDDEN-USER")
        @response4 = Ident::Response.from("0, 0:ERROR:UNKNOWN-ERROR")
        @response5 = Ident::Response.from("0, 0 : ERROR : NO-USER")
      end

      assert "is an error" do
        @response1.error?
      end

      assert "has a type" do
        equal("INVALID-PORT", @response1.type)
      end

      assert "knows what kind of error it is" do
        @response1.invalid_port?
        not @response1.no_user?
        not @response1.hidden_user?
        not @response1.unknown_error?

        not @response2.invalid_port?
        @response2.no_user?
        not @response2.hidden_user?
        not @response2.unknown_error?

        not @response3.invalid_port?
        not @response3.no_user?
        @response3.hidden_user?
        not @response3.unknown_error?

        not @response4.invalid_port?
        not @response4.no_user?
        not@response4.hidden_user?
        @response4.unknown_error?
      end

      assert "should strip spaces" do
        @response5.no_user?
      end
    end # An ERROR response

    suite "A BasicResponse" do
      setup do
        @response = Ident::Response::BasicResponse.new
      end

      assert "is not an error" do
        not @response.error?
      end

      assert "has empty default values" do
        @response.os.nil? and @response.charset.nil? and @response.userid.nil?
      end
    end # A BasicResponse
  end # ::Response

  suite ".request" do
    assert "should connect to a server" do
      TCPSocket.expects(:new).with("127.0.0.1", 113).returns(StringIO.new)

      Ident.request("127.0.0.1", 12345, 12345)
    end

    assert "should return a new response" do
      io = StringIO.new("0,0:ERROR:UNKNOWN-ERROR")
      io.expects(:puts)
      TCPSocket.expects(:new).with("127.0.0.1", 113). returns(io).at_least_once

      Ident.request("127.0.0.1", 12345, 12345).is_a? Ident::Response::BasicResponse
    end

    assert "should return a new response if the server terminates the connection" do
      TCPSocket.expects(:new).with("127.0.0.1", 113).returns(StringIO.new).at_least_once
      Ident.request("127.0.0.1", 12345, 12345).is_a? Ident::Response::ERROR
    end
  end

  suite "as an instance" do
    assert "should act as a proxy to Ident.request" do
      Ident.expects(:request).with("127.0.0.1", 12345, 6789, 20).returns(true).once

      i = Ident.new
      i.ip       = "127.0.0.1"
      i.outbound = 12345
      i.inbound  = 6789
      i.timeout  = 20

      i.request
    end
  end
end
