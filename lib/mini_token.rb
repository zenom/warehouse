class MiniToken
  TOKEN_SIZE = 6
  TOKEN_CHARACTERS = (('A'..'Z').to_a+('a'..'z').to_a+('0'..'9').to_a)

  class << self
    def output(size = nil)
      generate { @token_size = size.nil? ? TOKEN_SIZE : size }
    end

    private

      def generate
        yield if block_given?
        @token = TOKEN_CHARACTERS.sample(@token_size).join
        exist_token?
      end

    protected

      def exist_token?
        Burn.find_by_serial(@token).nil? ? @token : generate
      end
      
  end
end