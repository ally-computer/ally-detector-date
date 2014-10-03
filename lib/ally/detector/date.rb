require 'ally/detector'
require 'ally/detector/date/version'

module Ally
  module Detector
    class Date
      include Ally::Detector
      require 'chronic'
      require 'time'
      require 'date'

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
        words = @inquiry.words_chomp_punc.select do |w|
          DAYS_OF_THE_MONTH.include?(w.downcase) ||
          DAYS_OF_THE_WEEK.include?(w.downcase) ||
          MONTHS.include?(w.downcase) ||
          MONTHS_ABBR.include?(w.downcase) ||
          RELATIVE_DATES.include?(w.downcase) ||
          DATE_RELAVANT_WORDS.include?(w.downcase) ||
          w =~ /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/  # various date formats
        end
        date_string = words.join(' ')
        date = Chronic.parse(date_string)
        if date.nil?
          # find unix epoch timestamp
          @inquiry.type_of('numbers').each do |num|
            date = Time.at(num).utc if num.to_s =~ /^\d{10}$/
          end
        end
        date
      end
    end
  end
end
