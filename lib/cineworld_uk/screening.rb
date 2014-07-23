module CineworldUk
  # The object representing a single screening on the Cineworld UK website
  class Screening
    # @return [String] the booking URL on the cinema website
    attr_reader :booking_url
    # @return [String] 2d or 3d
    attr_reader :dimension
    # @return [String] the cinema name
    attr_reader :cinema_name
    # @return [String] the film name
    attr_reader :film_name

    # @param [String] film_name the film name
    # @param [String] cinema_name the cinema name
    # @param [Time] time datetime of the screening (UTC preferred)
    # @param [String] booking_url direct link to the booking page for screening
    # @param [String] variant the type of showing (e.g. 3d/baby/live)
    def initialize(options)
      @booking_url = options.fetch(:booking_url, nil)
      @cinema_name = options.fetch(:cinema_name)
      @cinema_id   = options.fetch(:cinema_id)
      @dimension   = options.fetch(:dimension, '2d')
      @film_name   = options.fetch(:film_name)
      @time        = options.fetch(:time)
      @variant     = options.fetch(:variant, '')
    end

    def self.at(cinema_id)
      whatson_parser(cinema_id).films_with_screenings.map do |html|
        create_for_single_film(html, cinema_id)
      end.flatten
    end

    # The date of the screening
    # @return [Date]
    def showing_on
      showing_at.to_date
    end

    # The UTC time of the screening
    # @return [Time]
    def showing_at
      @when ||= begin
        if @time.utc?
          @time
        else
          TZInfo::Timezone.get('Europe/London').local_to_utc(@time)
        end
      end
    end

    # The kinds of screening
    # @return <Array[String]>
    def variant
      @variant.split(' ').map(&:downcase).sort
    end

    private

    def self.cinema_name_hash(cinema_id)
      { cinema_name: CineworldUk::Cinema.find(cinema_id).name }
    end

    def self.create_for_single_film(html, cinema_id)
      screenings_parser(html).to_a.map do |attributes|
        new cinema_name_hash(cinema_id).merge(attributes)
      end
    end

    def self.screenings_parser(html)
      CineworldUk::Internal::FilmWithScreeningsParser.new(html)
    end

    def self.whatson_parser(id)
      CineworldUk::Internal::WhatsonParser.new(id)
    end
  end
end
