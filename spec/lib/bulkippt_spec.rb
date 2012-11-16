require_relative '../spec_helper'

describe "Bulkippt" do

  context "when asked to verify credentials" do

    it "should detect that a given set of credentials is incorrect" do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('invalid', 'invalid'), Logger.new('/dev/null')).credentials_valid?.should be_false
    end

    it "should detect that a given set of credentials is correct" do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('valid', 'valid'), Logger.new('/dev/null')).credentials_valid?.should be_true
    end

  end

  context "when parsing an invalid CSV" do

    let :bad_csv do
      File.expand_path './spec/data/empty.csv'
    end

    let :loader do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('valid','valid'), Logger.new('/dev/null'))
    end

    it "should fail to extract bookmarks when CSV's not found" do
      result = loader.extract_bookmarks('/does/not/exist.csv')
      result.should be_an_instance_of Array
      result.size.should == 0
    end

    it "should raise an error when missing the require url and title columns" do
      result = loader.extract_bookmarks(bad_csv)
      result.should be_an_instance_of Array
      result.size.should == 0
    end

  end

  context "when parsing a valid CSV" do

    let :good_csv do
      File.expand_path './spec/data/good.csv'
    end

    let :non_utf8_csv do
      File.expand_path './spec/data/non-utf8.csv'
    end

    let :loader do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('valid','valid'), Logger.new('/dev/null'))
    end

    it "should find all the bookmarks" do
      clips = loader.extract_bookmarks good_csv
      clips.class.should == Array
      clips.size.should >= 3
    end

    it "should handle non-UTF-8 CSVs and still find all the bookmarks" do
      clips = loader.extract_bookmarks non_utf8_csv
      clips.class.should == Array
      clips.size.should >= 2
    end

    it "should use the service to submit the bookmarks" do
      bookmarks = loader.extract_bookmarks good_csv
      saved = loader.submit_bookmarks bookmarks
      saved.class.should == Array
      saved.first.url.should == 'http://www.kippt.com'
      saved.first.title.should == 'Kippt'
    end

  end

end
