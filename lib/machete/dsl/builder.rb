module Machete
  module DSL
    class Builder
      RESERVED_WORDS = [
        :For, :If, :Alias, :Next, :Not, :Super, :When, :Case,
        :While,:Yield, :Class, :Module, :And, :Break, :Send,
      ].freeze

      attr_accessor :tree

      def self.build(array=false, &block)
        mb = Builder.new(array)
        mb.instance_eval(&block) if block_given?
        mb.tree
      end

      def self.dsl_method_name(name)
        if result = name.to_s.gsub!(/(.)([A-Z])/,'\1_\2')
          result.downcase
        else
          RESERVED_WORDS.include?(name) ? ("_" + name.to_s.downcase) : name.to_s.downcase
        end
      end

      Rubinius::AST.constants.each do |top_method|
        define_method dsl_method_name(top_method) do |*args, &block|
          __send__(top_method, *args, &block)
        end
      end

      def initialize(array=false)
        @tree = array ? Array.new : Hash.new
      end

      def method_missing method, *args, &block
        if block && args.first == :array
          add_element(method, Builder.build(true, &block))
        elsif block
          add_element(method, Builder.build(&block))
        elsif (args.first.is_a?(Hash) || args.first.is_a?(String))
          add_element(method, args.first)
        else
          {method => args.first}
        end
      end

      def add_element(method, item)
        if @tree.is_a? Hash
          @tree[method] = item
        else
          @tree << {method => item}
        end
      end
    end
  end
end