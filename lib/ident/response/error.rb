require "ident/response/basic_response"

class Ident
  module Response
    # This class gives access to the error returned by an identd. It
    # defines methods for every possible kind of error:
    # {invalid_port?}, {no_user?}, {hidden_user?}, {unknown_error?}
    #
    # Note: You should not instantiate this class yourself.
    class ERROR < BasicResponse
      KNOWN_ERRORS.each do |e|
        define_method(error_to_method_name(e)) do
          @type == e
        end
      end

      # @return [String]
      attr_reader :type
      def initialize(type)
        @type = type
      end

      # @see BasicResponse#error?
      def error?; true; end

      # @return [Boolean] Did we specify an invalid port?
      def invalid_port?; @type == "INVALID-PORT"; end

      # @return [Boolean]  Is no user known for the given connection specification?
      def no_user?; @type == "NO-USER"; end

      # @return [Boolean] Does the identd hide information from us?
      def hidden_user?; @type == "HIDDEN-USER"; end

      # @return [Boolean] Did an unknown error occur?
      def unknown_error?; @type == "UNKNOWN-ERROR"; end
    end
  end
end
