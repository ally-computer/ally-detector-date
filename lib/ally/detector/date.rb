require 'ally/detector'
require 'ally/detector/date/version'

module Ally
  module Detector
    class Date
      include Ally::Detector
      require 'chronic'

      attr_accessor :date

      DAYS_OF_THE_MONTH = %w[
        1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th 11th 12th
        13th 14th 15th 16th 17th 18th 19th 20th 21st 22nd
        23rd 24th 25th 26th 27th 28th 29th 30th 31st
      ]

      DAYS_OF_THE_WEEK = %w[
        sunday monday tuesday wednesday thursday
        friday saturday
      ]

      MONTHS = %w[
        january february march april may june july
        august september october november december
      ]

      MONTHS_ABBR = %w[
        jan feb mar apr may jun jul aug sep oct nov dec
      ]

      RELATIVE_DATES = %w[
        now today tomorrow yesterday
      ]

      DATE_RELAVANT_WORDS = %w[
        this next past previous last month months year years
        day days hour hours minute minutes am pm a.m. p.m.
        ad a.d. bc b.c.
      ]

      def detect
        words = @inquiry.words_chomp_punc.map(&:downcase).select do |w|
          DAYS_OF_THE_MONTH.include?(w) ||
          DAYS_OF_THE_WEEK.include?(w) ||
          MONTHS.include?(w) ||
          MONTHS_ABBR.include?(w) ||
          RELATIVE_DATES.include?(w) ||
          DATE_RELAVANT_WORDS.include?(w) ||
          w =~ /^[0-9]+(:|\/|-)[0-9]+(:|\/|-)[0-9]+$/ || # various date formats
          w =~ /^([0-9]+(:|-)|)[0-9]+(:|-)[0-9]+$/ # various time formats
        end
        date_string = words.join(' ')
        date = Chronic.parse(date_string)
        date = date.to_date unless date.nil?
        date
      end
    end
  end
end
