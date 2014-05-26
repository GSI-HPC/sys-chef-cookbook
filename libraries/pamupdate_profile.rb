class PamUpdate

  class Profile

    include Comparable

    attr_reader :fields

    def <=>(another)
      priority = another.fields()[:Priority] <=> fields()[:Priority]
      if priority == 0
        fields()[:Name] <=> another.fields()[:Name]
      else
        priority
      end
    end

    private
    attr_reader :filename, :content
    attr_accessor :filename
    attr_writer :fields

    def initialize(source)
      self.fields = Hash.new
      if source.kind_of?(String)
         self.filename = source
        self.content = File.read(filename)
        parse()
      elsif source.kind_of?(Hash)
        source.each do |k,v|
          self.fields[k.to_sym] = v
        end
      else
        raise ProfileError, "Wrong type of data to \
initialize object of class profile."
      end
      validate()
    end # def initialize

    def validate

      acc = true
      fields().each_key do |k|
        acc &&= k.instance_of?(Symbol)
        if ! acc
          raise ProfileError, "#{k} is not a symbol."
        end
      end

      if ! fields()[:Name]
        raise ProfileError, "Object #{self.object_id} does not have a name."
      elsif ! fields()[:Default]
        raise ProfileError, "#{fields()[:Name]} does not have a value for fields[:Default]."
      elsif ! fields()[:Priority]
        raise ProfileError, "#{fields()[:Name]} does not have a Priority set."
      end
    end

    def content=(text)
      @content = text
    end

    def parse
      fieldname = String.new
      content.each_line do |line|
        if matches = %r{^(\S+):\s+(.*)$}.match(line)
          fieldname = matches[1]
          if fieldname == "Conflicts"
            fields[fieldname.to_sym] = matches[2].split(',').map { |c| c.strip}
          else
            fields[fieldname.to_sym] = matches[2]
          end # if
        elsif matches = %r{^\s+}.match(line)
          fields[fieldname.to_sym] = line.strip
        end # if
      end # File

      unless fields()[:"Session-Interactive-Only"]
        self.fields[:'Session-noninteractive-Type'] = fields()[:'Session-Type'];
        self.fields[:'Session-noninteractive'] = fields()[:'Session'];
        self.fields[:'Session-noninteractive-Initial'] = fields()[:'Session-Initial'];
      end # end if
    end # def parse
  end # class Profile
end # class PamUpdate
