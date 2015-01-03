module CineworldUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer
      # strings and regex to be removed
      REMOVE = [
        /\s+[23]d/i,                          # dimension
        /\(Hindi\)/i,                         # Indian Language
        /\(Malayalam\)/i,                     # Indian Language
        /\(Punjabi\)/i,                       # Indian Language
        /\(Tamil\)/i,                         # Indian Language
        /\(Turkish\)/i,                       # Foreign Language
        %r(-? \d{1,2}/\d{1,2}/\d{2,4}),       # date
        /\n/,                                 # newlines
        /\- Encore/,                          # encore
        'Autism Friendly Screening:',         # autism screening
        '- Unlimited Screening',              # unlimited screening
        /LFF Opening Night Live/,             # london film festival
        '- Special Performance',              # special performance
        /\ATake 2 -/,                         # take 2
        / - (Subtitled) Movies for Juniors/i, # movies for juniors
        '(IMAX)',                             # IMAX
        'SciScreen: ',                        # SciScreen
        ' - Live Q and A',                    # Live Q&A
        /(\s+\-\s+)?MOVIES FOR JUNIORS/i,     # movies for juniors
        /\bsing\-?a\-?long\b/i,               # singalong
      ]

      # regexes and their replacements
      REPLACE = {
        /Bolshoi Ballet: (.*)/         => 'Bolshoi: ',
        /ENO: (.*)/i                   => 'English National Opera: ',
        /Guardian Live - (.*)/         => 'The Guardian: ',
        /Met Opera - (.*)/i            => 'Met Opera: ',
        /NT Live: (.*)/                => 'National Theatre: ',
        /NT Live Encore: (.*)/         => 'National Theatre: ',
        /ROH - (.*)/                   => 'Royal Opera House: ',
        /RSC Live: (.*)/               => 'Royal Shakespeare Company: ',
        /The Royal Ballet - (.*)/      => 'The Royal Ballet: '
      }

      # @param [String] title a film title
      def initialize(title)
        @title = title
      end

      # sanitized and standardized title
      # @return [String] title
      def sanitized
        @sanitzed ||= begin
          sanitized = @title
          REMOVE.each do |pattern|
            sanitized.gsub! pattern, ''
          end
          REPLACE.each do |pattern, prefix|
            sanitized.gsub!(pattern) { |_| prefix + $1 }
          end
          sanitized.squeeze(' ').strip
        end
      end
    end
  end
end
