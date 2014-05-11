require 'spec_helper'

describe Thunderer do
  before { Thunderer.reset_config }

  it "defaults server to nil" do
    Thunderer.config[:server].should be_nil
  end

  it "defaults signature_expiration to nil" do
    Thunderer.config[:signature_expiration].should be_nil
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    Time.stub(:now).and_return(time)
    Thunderer.subscription[:timestamp].should eq((time.to_f * 1000).round)
  end

  it "loads a simple configuration file via load_config" do
    Thunderer.load_config("spec/fixtures/thunderer.yml", "production")
    Thunderer.config[:server].should eq("http://example.com/faye")
    Thunderer.config[:secret_token].should eq("PRODUCTION_SECRET_TOKEN")
    Thunderer.config[:signature_expiration].should eq(600)
  end

  it 'also configure Thunderer::Messanger when load config' do
    Thunderer.load_config("spec/fixtures/thunderer.yml", "production")
    # expect(Thunderer.messanger).to be_kind_of(Thunderer::Messanger)
    expect(Thunderer.messanger.config).not_to be_nil
  end

  it "raises an exception if an invalid environment is passed to load_config" do
    expect {
      Thunderer.load_config("spec/fixtures/thunderer.yml", :test)
    }.to raise_error ArgumentError
  end


  it "includes channel, server, and custom time in subscription" do
    Thunderer.config[:server] = "server"
    subscription = Thunderer.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should eq(123)
    subscription[:channel].should eq("hello")
    subscription[:server].should eq("server")
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    Thunderer.config[:secret_token] = "token"
    subscription = Thunderer.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should eq(Digest::SHA1.hexdigest("tokenchannel123"))
  end

  it "formats a message hash given a channel and a hash" do
    Thunderer.config[:secret_token] = "token"
    Thunderer.message("chan", :foo => "bar").should eq(
      :ext => {:thunderer_secret_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :data => {:foo => "bar"}
      }
    )
  end

  it "publish message as json to server using Net::HTTP" do
    message = 'foo'
    Thunderer.load_config("spec/fixtures/thunderer.yml", "production")

    expect(Thunderer::Messanger).to receive(:post)
    Thunderer.publish_message(message)
  end

  
  it "raises an exception if no server is specified when calling publish_message" do
    lambda {
      Thunderer.publish_message("foo")
    }.should raise_error(Thunderer::Error)
  end

  it "publish_to passes message to publish_message call" do
    Thunderer.should_receive(:message).with("chan", "foo").and_return("message")
    Thunderer.should_receive(:publish_message).with("message").and_return(:result)
    Thunderer.publish_to("chan", "foo").should eq(:result)
  end

  it "has a Faye rack app instance" do
    Thunderer.faye_app.should be_kind_of(Faye::RackAdapter)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    Thunderer.config[:signature_expiration] = 30*60
    time = Thunderer.subscription[:timestamp] - 31*60*1000
    Thunderer.signature_expired?(time).should be_true
  end

  it "says signature has not expired when time passed in is less than expiration" do
    Thunderer.config[:signature_expiration] = 30*60
    time = Thunderer.subscription[:timestamp] - 29*60*1000
    Thunderer.signature_expired?(time).should be_false
  end

  it "says signature has not expired when expiration is nil" do
    Thunderer.config[:signature_expiration] = nil
    Thunderer.signature_expired?(0).should be_false
  end

end
