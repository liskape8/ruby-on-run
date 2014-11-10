# class representing a frame in VMStack
class RubyOnRun::StackFrame

  attr_accessor :literals, :bytecode_pointer, :parent, :locals, :constants, :instance, :method, :bytecode, :args, :self 


  def initialize(compiled_code)
    @compiled_code = compiled_code
    @stack = []
    @literals = compiled_code.literals
    @bytecode_pointer = 0
    @bytecode = compiled_code.iseq
    @self = MainContext.new

    # @locals = compiled_code.locals
  end

  def next_instruction
    i = RubyOnRun::InstructionSet.parse_instruction(@bytecode[@bytecode_pointer..-1])
    if @jump
      @jump = false
    else
      @bytecode_pointer += 1 + i.args.size
    end
    i
  end

  def push(x)
    @stack.push(x)
  end

  def pop
    @stack.pop
  end

  def top
    top = @stack.pop
    @stack.push(top)
    top
  end

  class MainContext

    def method_missing(meth, *args, &block)
      raise "Method #{meth} is not implemented yet"
    end

  end

end
