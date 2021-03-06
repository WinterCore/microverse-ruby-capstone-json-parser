require_relative './token'
require_relative './helpers'

module Jsonerino
  class Lexer
    SIMPLE_TOKENS_MATCHER = [
      ['{', Token::TOKEN_LCURLY],
      ['}', Token::TOKEN_RCURLY],
      ['[', Token::TOKEN_LBRACKET],
      [']', Token::TOKEN_RBRACKET],
      [':', Token::TOKEN_COLON],
      [',', Token::TOKEN_COMMA]
    ].freeze

    SIMPLE_ESCAPE_SEQUENCES_MATCHER = [
      ['"', '"'],
      ['b', "\b"],
      ['f', "\f"],
      ['r', "\r"],
      %W[n \n],
      %W[t \t]
    ].freeze

    attr_reader :i

    def initialize(contents)
      @contents = contents
      @i = 0
      @l = 1 # Line number (row)
      @li = 1 # Character in current line (column)
      @c = contents[@i]
    end

    def next_token
      skip_whitespace

      while more_content?

        v = collect_simple_token
        return v if v

        # Numbers in JSON are only allowed to start with a minus sign
        return collect_number if number?

        return collect_string if @c == '"'

        return collect_id if Helpers.alphanumeric?(@c)

        raise "Unexpected character '#{@c}'"
      end
      nil
    end

    private

    def number?
      Helpers.numeric?(@c) || @c == '-'
    end

    def skip_whitespace
      while [' ', "\n", "\t"].include?(@c)
        c = advance
        if c == "\n"
          @li = 1
          @l += 1
        end
      end
    end

    def advance
      return unless more_content?

      @i += 1
      @li += 1
      c = @c
      @c = @contents[@i]
      c
    end

    def collect_id
      start_i = @li
      str = ''
      while @c && Helpers.alphanumeric?(@c)
        str += @c
        advance
      end
      Token.new Token::TOKEN_ID, str, start_i, @li, @l
    end

    def collect_simple_token
      start_i = @li
      token = Lexer::SIMPLE_TOKENS_MATCHER.find { |x| x[0] == @c }
      return nil unless token

      Token.new token[1], advance, start_i, @li, @l
    end

    def collect_string
      start_i = @li
      advance
      str = ''

      while @c && @c != '"'
        str += @c == '\\' ? collect_escape_sequence : @c
        advance
      end
      advance

      Token.new Token::TOKEN_STRING, str, start_i, @li, @l
    end

    def collect_escape_sequence
      advance

      if (escape = Lexer::SIMPLE_ESCAPE_SEQUENCES_MATCHER.find { |x| x[0] == @c })
        escape[1]
      elsif @c == 'u'
        collect_unicode_escape
      else
        @c
      end
    end

    def collect_unicode_escape
      str_number = 4.times.inject('0x') do |str|
        advance
        raise "Invalid unicode escape sequence #{@c}" unless Helpers.hex?(@c)

        str + @c
      end
      str_number.to_i.chr
    end

    def collect_number
      start_i = @li
      str_number = ''
      loop do
        str_number += @c
        advance
        break unless @c && (Helpers.numeric?(@c) || ['.', '-', '+', 'e', 'E'].include?(@c))
      end
      number = str_number.match?(/[\.e]/i) ? str_number.to_f : str_number.to_i
      Token.new Token::TOKEN_NUMBER, number, start_i, @li, @l
    end

    def more_content?
      @i < @contents.length
    end
  end
end
