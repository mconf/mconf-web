# Ordered YAMLs
class Hash
  # copy of ruby's to_yaml method, prepending sort.
  # before each so we get an ordered yaml file
  def to_yaml( opts = {} )
    YAML::quick_emit( self, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v| #<- Adding sort.
          map.add( k, v )
        end
      end
    end
  end
end
