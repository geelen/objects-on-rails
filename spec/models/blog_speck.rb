# encoding: UTF-8

require 'minitest/autorun'
require 'ostruct'
require_relative '../spec_helper_lite'

require_relative '../../app/models/blog'

describe Blog do
  subject { Blog.new }
  it "has no entries" do
    subject.entries.must_be_empty
  end

  describe "#new_post" do
    before do
      @new_post = OpenStruct.new
      subject.post_source = -> { @new_post }
    end
    it "returns a new post" do
      subject.new_post.must_equal @new_post
    end
    it "sets the post’s blog reference to itself" do
      subject.new_post.blog.must_equal(subject)
    end
    it "accepts an attribute hash on behalf of the post maker" do
      post_source = MiniTest::Mock.new
      post_source.expect(:call, @new_post, [{x: 42, y: 'z'}])
      subject.post_source = post_source
      subject.new_post(x: 42, y: 'z')
      post_source.verify
    end
  end

  describe "#add_entry" do
    it "adds the entry to the blog" do
      entry = stub!
      subject.add_entry(entry)
      subject.entries.must_include(entry)
    end
  end
  describe "#entries" do
    def stub_entry_with_date(date)
      OpenStruct.new(pubdate: DateTime.parse(date))
    end
    it "is sorted in reverse-chronological order" do
      oldest = stub_entry_with_date("2011-09-09")
      newest = stub_entry_with_date("2011-09-11")
      middle = stub_entry_with_date("2011-09-10")
      subject.add_entry(oldest)
      subject.add_entry(newest)
      subject.add_entry(middle)
      subject.entries.must_equal([newest, middle, oldest])
    end
    it "is limited to 10 items" do
      10.times do |i|
        subject.add_entry(stub_entry_with_date("2011-09-#{i+1}"))
      end
      oldest = stub_entry_with_date("2011-08-30")
      subject.add_entry(oldest)
      subject.entries.size.must_equal(10)
      subject.entries.wont_include(oldest)
    end
  end
end

