class Ident
  module Response
    # This is the blankslate response which ensures that both kind of
    # responses respond to all required methods. You should never have
    # to work with this class directly.
    #
    # @api private
    class BasicResponse
      # Is the response the result of an error?
      #
      # @return [Boolean]
      def error?;  false; end

      # @return [nil]
      def os;      nil;   end
      # @return [nil]
      def charset; nil;   end
      # @return [nil]
      def userid;  nil;   end

      class << self
        # @return [String]
        def error_to_method_name(error)
          (error.downcase.tr('-', '_') + "?").to_sym
        end
        private :error_to_method_name
      end

      public
      KNOWN_ERRORS.each do |e|
        define_method(error_to_method_name(e)) do
          false
        end
      end
    end
  end
end
