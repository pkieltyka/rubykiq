require "spec_helper"

describe Rubykiq::Client do

  describe :defaults do
    subject { Rubykiq::Client.new }
    its(:namespace) { should be_nil }
    its(:driver) { should be :ruby }
    its(:retry) { should be_true }
    its(:queue) { should eq "default" }
  end

  describe :push do
    let (:client) { Rubykiq::Client.new }

    context :validations do

      context "with an incorrect message type" do
        it "raises an ArgumentError" do
          expect{ client.push([]) }.to raise_error(ArgumentError, /Message must be a Hash/)
          expect{ client.push("{}") }.to raise_error(ArgumentError, /Message must be a Hash/)
          expect{ client.push(DummyClass.new) }.to raise_error(ArgumentError, /Message must be a Hash/)
        end
      end

      context "without a class" do
        it "raises an ArgumentError" do
          expect{ client.push(:args => ['foo', 1, { :bat => "bar" }]) }.to raise_error(ArgumentError, /Message must include a class/)
        end
      end

      context "with an incorrect args type" do
        it "raises an ArgumentError" do
          expect{ client.push(:class => "MyWorker", :args => { :bat => "bar" }) }.to raise_error(ArgumentError, /Message args must be an Array/)
        end
      end

      context "with an incorrect class type" do
        it "raises an ArgumentError" do
          expect{ client.push(:class => DummyClass, :args => ["foo", 1, { :bat => "bar" }]) }.to raise_error(ArgumentError, /Message class must be a String representation of the class name/)
        end
      end

    end

    context :singular do

      before(:each) do
        Rubykiq.connection.flushdb
      end

      it "should work" do

        expect {
          client.push(:class => "MyWorker", :args => [{:bat => "bar"}])
        }.to change{
          Rubykiq.connection.llen("queue:default")
        }.from(0).to(1)

        # raw_job = Rubykiq.connection.lpop("queue:default")
        # job = MultiJson.decode(raw_job, :symbolize_keys => true)

      end

    end

    context :multiple do

      before(:each) do
        Rubykiq.connection.flushdb
      end

      it "should work" do
        expect {
          client.push(:class => "MyWorker", :args => [[{:bat => "bar"}],[{:bat => "foo"}]])
        }.to change{
          Rubykiq.connection.llen("queue:default")
        }.from(0).to(2)

        # raw_job = Rubykiq.connection.lpop("queue:default")
        # job = MultiJson.decode(raw_job, :symbolize_keys => true)

      end

    end

  end

end