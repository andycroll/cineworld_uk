# encoding: UTF-8
module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # @note Modified from titleize gem
    #   https://github.com/granth/titleize
    module Titleize
      # List of words not to capitalize unless they lead a phrase
      WORDS = %w(a an and as at but by en for if in of on or the to via vs vs.)

      extend self

      # Capitalizes most words to create a nicer looking title string.
      #
      # The list of "small words" which are not capped comes from
      # the New York Times Manual of Style, plus 'vs'.
      #
      # Also capitalises roman numerals
      #
      #   "notes on a scandal" # => "Notes on a Scandal"
      #   "ghostbusters ii"    # => "Ghostbusters II"
      #
      # @param [String] title a chunk of html
      # @return [String]
      def titleize(title)
        title = title.dup
        title.downcase! unless title[/[[:lower:]]/]  # assume all-caps fixing

        phrases(title).map do |phrase|
          words = phrase.split
          words.map do |word|
            def word.capitalize
              # like String#capitalize, but it starts with the first letter
              sub(/[[:alpha:]].*/) { |subword| subword.capitalize }
            end

            case word
            when /[[:alpha:]]\.[[:alpha:]]/  # words with dots in
              word
            when /[-‑]/  # hyphenated word (regular and non-breaking)
              word.split(/([-‑])/).map do |part|
                WORDS.include?(part) ? part : part.capitalize
              end.join
            when /^[[:alpha:]].*[[:upper:]]/ # non-first letter capitalized
              word
            when /^[[:digit:]]/  # first character is a number
              word
            when /^(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/i
              word.upcase
            when words.first, words.last
              word.capitalize
            when *(WORDS + WORDS.map { |small| small.capitalize })
              word.downcase
            else
              word.capitalize
            end
          end.join(' ')
        end.join(' ')
      end

      # Splits a title into an array based on punctuation.
      # @param [String] title Film title
      # @return [Array<String>]
      #
      #   Titleize.phrases("simple title")
      #     #=> ["simple title"]
      #   Titleize.phrases("more complicated: titling")
      #     #=> ["more complicated:", "titling"]
      #   Titleize.phrases("even more: complicated - titling")
      #     #=> ["even more:", "complicated -", "titling"]
      def phrases(title)
        phrases = title.scan(/.+?(?:[-:.;?!] |$)/).map { |phrase| phrase.strip }

        # rejoin phrases that were split on the '.' from a small word
        if phrases.size > 1
          phrases[0..-2].each_with_index do |phrase, index|
            next unless WORDS.include?(phrase.split.last.downcase)
            phrases[index] << ' ' + phrases.slice!(index + 1)
          end
        end

        phrases
      end
    end
  end
end
