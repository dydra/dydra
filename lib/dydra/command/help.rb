# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # ...
  class Help < Command
    HELP = "Shows this help."

    ##
    # @param  [String] command
    # @return [void]
    def execute(command = nil)
      puts "Commands:"
      Dydra::Command.constants.each do |klass_name|
        klass = Dydra::Command.const_get(klass_name)
        next unless klass.is_a?(Class) && Dydra::Command.eql?(klass.superclass)
        help = klass.const_get(:HELP)
        next if help.nil? # skip any unimplemented/undocumented commands
        puts "    %-12s%s" % [klass_name.downcase, help]
      end
    end
  end # Help
end # Dydra::Command
