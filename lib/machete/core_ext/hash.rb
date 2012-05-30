class Hash
  def to_m
    result = []
    each do |key, value|
      chunk = key =~ /^[A-Z]/ ? "#{key}<#{value.to_m}>" : "#{key} = #{value.to_m}"
      result << chunk
    end

    result.join(", ")
  end
end