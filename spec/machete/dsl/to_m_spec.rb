require "spec_helper"

describe "to_m" do
  context String do
    it "should return empty string" do
      "".to_m.should == ""
    end

    it "should return 'self'" do
      "string".to_m.should == "string"
    end
  end

  context Hash do
    it "should return empty string in case empty hash" do
      {}.to_m.should == ""
    end

    it "should close content with '<>' when key start with capital letter" do
      {:SendWithArguments => nil}.to_m.should == "SendWithArguments<>"
    end

    it "should add attribute to AST node" do
      {:SendWithArguments => { :attribute => 1}}.to_m.should == "SendWithArguments<attribute = 1>"
    end

    it "should add many attributes to AST node separated by comma" do
      {
        :SendWithArguments =>
          {
            :attribute_1 => 1,
            :attribute_2 => 2
          }
      }.to_m.should == "SendWithArguments<attribute_1 = 1, attribute_2 = 2>"
    end
  end

  context "DSL" do
    it "should add many attributes with the same name" do
      dsl = Machete::DSL::Builder.build do
        send_with_arguments do
          body(:array) do
            fixnum_literal(value: 1)
            fixnum_literal(value: 2)
          end
        end
      end

      dsl.to_m.should == "SendWithArguments<body = [FixnumLiteral<value = 1>, FixnumLiteral<value = 2>]>"
    end

    it "should proper create XSS check" do
      dsl = Machete::DSL::Builder.build do
        send_with_arguments do
          name(':send_file | :send_data')
          arguments do
            actual_arguments do
              array(:array) do
                hash_literal do
                  array(:array) do
                    symbol_literal(value: ":disposition")
                    string_literal(string: '"inline"')
                  end
                end
              end
            end
          end
        end
      end

      dsl.to_m.should == <<-XSS_CHECK.strip
        SendWithArguments<name = :send_file | :send_data, arguments = ActualArguments<array = [HashLiteral<array = [SymbolLiteral<value = :disposition>, StringLiteral<string = "inline">]>]>>
      XSS_CHECK

    end
  end


end