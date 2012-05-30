require "spec_helper"

module Machete::DSL
  describe Builder do
    before do
      @builder = Builder.new
    end

    it "should respond to top level method" do
      @builder.should respond_to :send_with_arguments
    end

    context "build simple hash" do
      before do
        @result = Builder.build do
          send_with_arguments {}
        end
      end

      it "should return proper key in hash" do
        @result.should include(:SendWithArguments)
      end

      it "should have empty key" do
        @result[:SendWithArguments].should == {}
      end
    end

    context "build hash with arguments" do
      before do
        @result = Builder.build do
          send_with_arguments do
            attribute_1(value: 1)
            attribute_2(value: 2)
            array(:array) do
              attribute_2(value: 2)
              attribute_3(value: 3)
            end
            attribute_4 do
              nested_attribute(value: "nested")
            end
          end
        end
        @attributes = @result[:SendWithArguments]
      end

      it "should work with blocks" do
        @attributes.should include(:attribute_1 => {value: 1})
      end

      it "should work with hash" do
        @attributes.should include(:attribute_2 => {value: 2})
      end

      it "should work with many attributes with the same name (arrays)" do
        @attributes.should include(:array => [{:attribute_2 => {value: 2}}, {:attribute_3 => {value: 3}}])
      end

      it "should work with nested attributes" do
        @attributes[:attribute_4][:nested_attribute].should == {:value => "nested"}
      end
    end

    context "reserved words" do
      before do
        @result = Builder.build do
          _send do
            attribute_1(value: true)
          end
        end
      end

      it "should respond to special methods" do
        @builder.should respond_to(:_super)
      end

      it "should build proper hash with special method" do
        @result.should include(:Send => { :attribute_1 => { value: true } })
      end
    end
  end
end