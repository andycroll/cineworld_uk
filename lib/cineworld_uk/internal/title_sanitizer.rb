module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer

      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [CineworldUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # Strings and regex to be removed
      def remove
        [
          /\s+[23]d/i,                          # dimension
          /\(Hindi\)/i,                         # Indian Language
          /\(Malayalam\)/i,                     # Indian Language
          /\(Punjabi\)/i,                       # Indian Language
          /\(Tamil\)/i,                         # Indian Language
          /\(Cantonese\)/i,                     # Chinese
          /\(Turkish\)/i,                       # Foreign Language
          %r(-? \d{1,2}/\d{1,2}/\d{2,4}),       # date
          /\n/,                                 # newlines
          /\- Encore/,                          # encore
          /Autism Friendly Screening\s*[:-] /,  # autism screening
          '- Unlimited Screening',              # unlimited screening
          /LFF Opening Night Live/,             # london film festival
          '- Special Performance',              # special performance
          /\ATake 2 -/,                         # take 2
          / - (Subtitled) Movies for Juniors/i, # movies for juniors
          '(IMAX)',                             # IMAX
          'SciScreen: ',                        # SciScreen
          /\s(-\s)*(With)*\sLive Q And A/i,     # Live Q&A
          /(\s+\-\s+)?MOVIES FOR JUNIORS/i,     # movies for juniors
          /\bsing\-?a\-?long\b/i,               # singalong
          %r{\s20\d{2}[\/-]20\d{2} Season\b}
        ]
      end

      # Regexes and their replacements
      def replace
        {
          /Bolshoi Ballet\s*[:-] (.*)/       => 'Bolshoi Ballet: ',
          /ENO\s*[:-] (.*)/i                 => 'English National Opera: ',
          /Guardian Live\s*[:-] (.*)/        => 'The Guardian: ',
          /Glyndebourne 20\d{2}\s*[:-] (.*)/ => 'Glyndebourne: ',
          /Met Opera\s*[:-] (.*)/i           => 'Met Opera: ',
          /NT Live\s*[:-] (.*)/              => 'National Theatre: ',
          /NT Live Encore\s*[:-] (.*)/       => 'National Theatre: ',
          /ROH\s*[:-] (.*)/                  => 'Royal Opera House: ',
          /ROH Royal Opera\s*[:-] (.*)/      => 'Royal Opera House: ',
          /RSC Live\s*[:-] (.*)/             => 'Royal Shakespeare Company: ',
          /The Royal Ballet\s*[:-] (.*)/     => 'The Royal Ballet: ',
          /Royal Ballet\s*[:-] (.*)/         => 'The Royal Ballet: ',
          /ROH The Royal Ballet\s*[:-] (.*)/ => 'The Royal Ballet: ',
          /Royal Ballet Live\s*[:-] (.*)/    => 'The Royal Ballet: ',
          /San Francisco Ballets (.*)/       => 'San Francisco Ballet: '
        }
      end

    end
  end
end
