require "spec_helper"

module Machete
  include Matchers

  describe Parser do
    RSpec::Matchers.define :be_parsed_as do |ast|
      match do |input|
        Parser.new.parse(input).should == ast
      end
    end

    RSpec::Matchers.define :not_be_parsed do |message|
      match do |input|
        lambda {
          Parser.new.parse(input)
        }.should raise_exception(Parser::SyntaxError, message)
      end
    end

    before :each do
      @i42 = LiteralMatcher.new(42)
      @i43 = LiteralMatcher.new(43)
      @i44 = LiteralMatcher.new(44)

      @foo = NodeMatcher.new(:Foo)
      @foo_a = NodeMatcher.new(:Foo, :a => @i42)
      @foo_ab = NodeMatcher.new(:Foo, :a => @i42, :b => @i43)

      @ch4243 = ChoiceMatcher.new([@i42, @i43])
      @ch424344 = ChoiceMatcher.new([@i42, @i43, @i44])
    end

    def node_matcher_with_attr(attr)
      NodeMatcher.new(:Foo, { attr => @i42 })
    end

    # Canonical expression is "42 | 43".
    it "parses expression" do
      '42'.should be_parsed_as(@i42)
      '42 | 43'.should be_parsed_as(@ch4243)
      '42 | 43 | 44'.should be_parsed_as(@ch424344)
    end

    # Canonical primary is "42".
    it "parses primary" do
      'Foo<a = 42>'.should be_parsed_as(@foo_a)
      '42'.should be_parsed_as(@i42)
    end

    # Canonical node is "Foo".
    it "parses node" do
      'Foo'.should be_parsed_as(@foo)
      'Foo<a = 42, b = 43>'.should be_parsed_as(@foo_ab)
    end

    # Canonical attrs is "a = 42, b = 43".
    it "parses attrs" do
      'Foo<a = 42>'.should be_parsed_as(@foo_a)
      'Foo<a = 42, b = 43>'.should be_parsed_as(@foo_ab)
    end

    # Canonical attr is "a = 42".
    it "parses attr" do
      'Foo<a = 42 | 43>'.should be_parsed_as(NodeMatcher.new(:Foo, :a => @ch4243))
    end

    # Canonical literal is "42".
    it "parses literal" do
      ':a'.should be_parsed_as(LiteralMatcher.new(:a))
      '42'.should be_parsed_as(@i42)
      '"abcd"'.should be_parsed_as(LiteralMatcher.new("abcd"))
    end

    # Canonical VAR_NAME is "a".
    it "parses VAR_NAME" do
      'Foo<a = 42>'.should be_parsed_as(node_matcher_with_attr(:a))
      'Foo<z = 42>'.should be_parsed_as(node_matcher_with_attr(:z))
      'Foo<_ = 42>'.should be_parsed_as(node_matcher_with_attr(:_))
      'Foo<aa = 42>'.should be_parsed_as(node_matcher_with_attr(:aa))
      'Foo<az = 42>'.should be_parsed_as(node_matcher_with_attr(:az))
      'Foo<aA = 42>'.should be_parsed_as(node_matcher_with_attr(:aA))
      'Foo<aZ = 42>'.should be_parsed_as(node_matcher_with_attr(:aZ))
      'Foo<a0 = 42>'.should be_parsed_as(node_matcher_with_attr(:a0))
      'Foo<a9 = 42>'.should be_parsed_as(node_matcher_with_attr(:a9))
      'Foo<a_ = 42>'.should be_parsed_as(node_matcher_with_attr(:a_))
      'Foo<abcd = 42>'.should be_parsed_as(node_matcher_with_attr(:abcd))
    end

    # Canonical CLASS_NAME is "A".
    it "parses CLASS_NAME" do
      'A'.should be_parsed_as(NodeMatcher.new(:A))
      'Z'.should be_parsed_as(NodeMatcher.new(:Z))
      'Aa'.should be_parsed_as(NodeMatcher.new(:Aa))
      'Az'.should be_parsed_as(NodeMatcher.new(:Az))
      'AA'.should be_parsed_as(NodeMatcher.new(:AA))
      'AZ'.should be_parsed_as(NodeMatcher.new(:AZ))
      'A0'.should be_parsed_as(NodeMatcher.new(:A0))
      'A9'.should be_parsed_as(NodeMatcher.new(:A9))
      'A_'.should be_parsed_as(NodeMatcher.new(:A_))
      'Abcd'.should be_parsed_as(NodeMatcher.new(:Abcd))
    end

    # Canonical SYMBOL is ":a".
    it "parses SYMBOL" do
      ':a'.should be_parsed_as(LiteralMatcher.new(:a))
      ':z'.should be_parsed_as(LiteralMatcher.new(:z))
      ':A'.should be_parsed_as(LiteralMatcher.new(:A))
      ':Z'.should be_parsed_as(LiteralMatcher.new(:Z))
      ':_'.should be_parsed_as(LiteralMatcher.new(:_))
      ':aa'.should be_parsed_as(LiteralMatcher.new(:aa))
      ':az'.should be_parsed_as(LiteralMatcher.new(:az))
      ':aA'.should be_parsed_as(LiteralMatcher.new(:aA))
      ':aZ'.should be_parsed_as(LiteralMatcher.new(:aZ))
      ':a0'.should be_parsed_as(LiteralMatcher.new(:a0))
      ':a9'.should be_parsed_as(LiteralMatcher.new(:a9))
      ':a_'.should be_parsed_as(LiteralMatcher.new(:a_))
      ':abcd'.should be_parsed_as(LiteralMatcher.new(:abcd))
    end

    # Canonical INTEGER is "42".
    it "parses INTEGER" do
      '+1'.should be_parsed_as(LiteralMatcher.new(1))
      '-1'.should be_parsed_as(LiteralMatcher.new(-1))
      '1'.should be_parsed_as(LiteralMatcher.new(1))
      '0'.should be_parsed_as(LiteralMatcher.new(0))
      '9'.should be_parsed_as(LiteralMatcher.new(9))
      '10'.should be_parsed_as(LiteralMatcher.new(10))
      '19'.should be_parsed_as(LiteralMatcher.new(19))
      '123'.should be_parsed_as(LiteralMatcher.new(123))
    end

    # Canonical STRING is "\"abcd\"".
    it "parses STRING" do
      "''".should be_parsed_as(LiteralMatcher.new(""))
      "'a'".should be_parsed_as(LiteralMatcher.new("a"))
      "'abc'".should be_parsed_as(LiteralMatcher.new("abc"))

      '""'.should be_parsed_as(LiteralMatcher.new(""))
      '"a"'.should be_parsed_as(LiteralMatcher.new("a"))
      '"abc"'.should be_parsed_as(LiteralMatcher.new("abc"))
    end

    it "skips whitespace before tokens" do
      '42'.should be_parsed_as(@i42)
      ' 42'.should be_parsed_as(@i42)
      "\t42".should be_parsed_as(@i42)
      "\r42".should be_parsed_as(@i42)
      "\n42".should be_parsed_as(@i42)
      '   42'.should be_parsed_as(@i42)
    end

    it "skips whitespace after tokens" do
      '42'.should be_parsed_as(@i42)
      '42 '.should be_parsed_as(@i42)
      "42\t".should be_parsed_as(@i42)
      "42\r".should be_parsed_as(@i42)
      "42\n".should be_parsed_as(@i42)
      '42   '.should be_parsed_as(@i42)
    end

    it "handles lexical errors" do
      '@#%'.should not_be_parsed("Unexpected character: \"@\".")
    end

    it "handles syntax errors" do
      '42 43'.should not_be_parsed("Unexpected token: \"43\".")
    end
  end
end