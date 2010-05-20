module SData
  class Predicate < Struct.new(:field, :relation, :value)
    def self.parse(payload_map, predicate_string)
      match_data = predicate_string.match(/(\w+)\s(gt|lt|eq)\s('?.+'?|'')/) || []
      self.new payload_map.map_field(match_data[1].underscore).tap{|v| puts v}, match_data[2], strip_quotes(match_data[3])
    end

    def self.strip_quotes(value)
     return value unless value.is_a?(String)
     value = value.gsub("%27", "'")
     return value unless value =~ /'.*?'/
     return value[1,value.length-2]
    end

    def to_conditions      
      if field && relation && value
        ConditionsBuilder.build_conditions field, relation.to_sym, value
      else
        {}
      end
    end
  end
end