require 'spec_helper'
require 'date'
require 'time'

require_relative '../lib/ally/detector/date'

today = Date.today()
wday = today.wday

weekdays = %w[
  sunday
  monday
  tuesday
  wednesday
  thursday
  friday
  saturday
]

describe Ally::Detector::Date do
  context 'detect date' do
    it 'simple case' do
      r = subject.inquiry('now').detect
      r.day.should == today.day
      r.month.should == today.month
      r.year.should == today.year
    end

    it 'when no date exists' do
      subject.inquiry('No date here, should be nil')
        .detect.should == nil
    end

    it 'simple sentence referring to today' do
      r = subject.inquiry('whats the date today').detect
      r.day.should == today.day
      r.month.should == today.month
      r.year.should == today.year
    end

    it 'when referencing yesterday' do
      r = subject.inquiry('yesterday i had a great day').detect
      d = today - 1
      r.day.should == d.day
      r.month.should == d.month
      r.year.should == d.year
    end

    it 'when referencing tomorrow' do
      r = subject.inquiry('there is always another day tomorrow').detect
      d = today + 1
      r.day.should == d.day
      r.month.should == d.month
      r.year.should == d.year
    end

    it 'when referencing a week from today' do
      r = subject.inquiry("I have a doctor's appointment #{Date.today.strftime("%A")}").detect
      d = today + 7
      r.day.should == d.day
      r.month.should == d.month
      r.year.should == d.year
    end

    context 'past tense day references' do
      weekdays.each_with_index do |weekday,i|
        if wday == i
          x = -7
        elsif wday < i
          x = -(wday + (7 - i))
        elsif wday > i
          x = -(wday - i)
        end
        it "to #{weekday}" do
          r = subject.inquiry("i had a test last #{weekday}").detect
          d = today + x
          r.day.should == d.day
          r.month.should == d.month
          r.year.should == d.year
        end
      end
    end

    context 'future tense day references' do
      weekdays.each_with_index do |weekday,i|
        if wday == i
          x = 7
        elsif wday < i
          x = i - wday
        elsif wday > i
          x = (7 - wday) + i
        end
        it "to #{weekday}" do
          r = subject.inquiry("i have a test #{weekday}").detect
          d = today + x
          r.day.should == d.day
          r.month.should == d.month
          r.year.should == d.year
          r = subject.inquiry("i have a test this #{weekday}").detect
          d = today + x
          r.day.should == d.day
          r.month.should == d.month
          r.year.should == d.year
        end
      end
    end

    it 'reference a specific date' do
      r = subject.inquiry('i have an appointment on dec 30th').detect
      if today.month < 12
        year = today.year
      elsif today.day >= 30
        year = today.year + 1
      end
      r.should satisfy { |d| d.day == 30 }
      r.should satisfy { |d| d.month == 12 }
      r.should satisfy { |d| d.year == year }
    end

    it 'the next month by name' do
      r = subject.inquiry('august is going to be a hot one').detect
      year = today.month >= 8 ? today.year + 1 : today.year
      r.should satisfy { |d| d.month == 8 }
      r.should satisfy { |d| d.year == year }
    end

    it 'the last month by name' do
      r = subject.inquiry('last february was really cold').detect
      year = today.month < 2 ? today.year - 1 : today.year
      r.should satisfy { |d| d.month == 2 }
      r.should satisfy { |d| d.year == year }
    end

    it 'specific date' do
      r = subject.inquiry('2014-10-01').detect
      r.should satisfy { |d| d.day == 1 }
      r.should satisfy { |d| d.month == 10 }
      r.should satisfy { |d| d.year == 2014 }
    end

    it 'unix timestamp' do
      r = subject.inquiry('1412292987').detect
      r.should satisfy { |d| d.day == 2 }
      r.should satisfy { |d| d.month == 10 }
      r.should satisfy { |d| d.year == 2014 }
      r.should satisfy { |d| d.hour == 23 }
      r.should satisfy { |d| d.min == 36 }
    end

    it 'iso8601' do
      r = subject.inquiry('2011-10-19T04:01:52').detect
      r.should satisfy { |d| d.day == 19 }
      r.should satisfy { |d| d.month == 10 }
      r.should satisfy { |d| d.year == 2011 }
      r.should satisfy { |d| d.hour == 4 }
      r.should satisfy { |d| d.min == 1 }
      r.should satisfy { |d| d.sec == 52 }
    end
  end
end
