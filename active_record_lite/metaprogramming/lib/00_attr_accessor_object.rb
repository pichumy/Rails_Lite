class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
        heredoc = <<-MAGIC_STRING
          def #{name}
            @#{name}
          end

          def #{name}=(value)
            @#{name} = value
          end
        MAGIC_STRING

        eval(heredoc)
    end

  end
end
