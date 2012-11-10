require_relative '../spec_helper'

describe "Bulkippt" do

  context "when asked to verify credentials" do

    it "should detect that a given set of credentials is incorrect" do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('invalid', 'invalid')).credentials_valid?.should be_false
    end

    it "should detect that a given set of credentials is correct" do
      Bulkippt::Loader.new(Bulkippt::FakeService.new('valid', 'valid')).credentials_valid?.should be_true
    end

  end

  context "when parsing an invalid CSV" do

    let :bad_csv do
      File.expand_path './spec/data/empty.csv'
    end

    it "should raise an error when it can't find the file specified" do
      loader = Bulkippt::Loader.new(Bulkippt::FakeService.new('valid','valid'))
      expect {loader.extract_bookmarks('/does/not/exist.csv')}.to raise_error
    end

    it "should raise an error when missing the require url and title columns" do
      loader = Bulkippt::Loader.new(Bulkippt::FakeService.new('valid', 'valid'))
      expect { loader.extract_bookmarks bad_csv }.to raise_error
    end

  end

  context "when parsing a valid CSV" do

    let :good_csv do
      File.expand_path './spec/data/good.csv'
    end

    it "should find all the bookmarks" do
      loader = Bulkippt::Loader.new(Bulkippt::FakeService.new('valid', 'valid'))
      clips = loader.extract_bookmarks good_csv
      clips.class.should == Array
      clips.size.should >= 3
    end

    it "should use the service to submit the bookmarks" do
      loader = Bulkippt::Loader.new(Bulkippt::FakeService.new('valid', 'valid'))
      bookmarks = loader.extract_bookmarks good_csv
      saved = loader.submit_bookmarks bookmarks
      saved.class.should == Array
      saved.first.url.should == 'http://www.kippt.com'
      saved.first.title.should == 'Kippt'
    end

  end

end
