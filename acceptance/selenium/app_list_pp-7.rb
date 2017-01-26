require './helper'

driver = Selenium::WebDriver.for :chrome

describe 'List of VA apps and applets PP-7' do

  before(:each) do
    @driver = Selenium::WebDriver.for :chrome
    #Selenium IDE put in a slash at end of base_url which caused bad url's below
    @base_url = "http://localhost/portal"

  end

  after(:each) do
    @driver.quit
    [].should == @verification_errors
  end

  it 'PP-7 | PP-[#]: Confirm list pf apps' do

        
    
  end
  
end  