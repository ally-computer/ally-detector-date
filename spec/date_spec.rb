require 'spec_helper'
require 'date'

require_relative '../lib/ally/detector/date'

today = Date.today
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
      subject.inquiry('now').detect.should == today
    end

    it 'when no date exists' do
      subject.inquiry('No date here, should be nil')
        .detect.should == nil
    end

    it 'when string is empty' do
      subject.inquiry('')
        .detect.should == nil
    end

    it 'simple sentence referring to today' do
      subject.inquiry('whats the date today?')
        .detect.should == today
    end

    it 'when referencing yesterday' do
      subject.inquiry('yesterday i had a great day')
        .detect.should == today - 1
    end

    it 'when referencing tomorrow' do
      subject.inquiry('there is always another day tomorrow')
        .detect.should == today + 1
    end

    it 'when referencing a week from today' do
      subject.inquiry("I have a doctor's appointment #{Date.today.strftime("%A")}")
        .detect.should == today + 7
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
          subject.inquiry("i had a test last #{weekday}")
            .detect.should == today + x
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
          subject.inquiry("i have a test #{weekday}")
            .detect.should == today + x
          subject.inquiry("i have a test this #{weekday}")
            .detect.should == today + x
        end
      end
    end

    it 'reference a specific date' do
      r = subject.inquiry('i have an appointment on dec 30th')
      if today.month < 12
        year = today.year
        elsif today.day >= 30
        year = today.year + 1
      end
      r.detect.should satisfy { |d| d.day == 30 }
      r.detect.should satisfy { |d| d.month == 12 }
      r.detect.should satisfy { |d| d.year == year }
    end

    it 'the next month by name' do
      r = subject.inquiry('august is going to be a hot one')
      year = today.month >= 8 ? today.year + 1 : today.year
      r.detect.should satisfy { |d| d.month == 8 }
      r.detect.should satisfy { |d| d.year == year }
    end

    it 'the last month by name' do
      r = subject.inquiry('last february was really cold')
      year = today.month < 2 ? today.year - 1 : today.year
      r.detect.should satisfy { |d| d.month == 2 }
      r.detect.should satisfy { |d| d.year == year }
    end
  end
end
