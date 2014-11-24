# main class
class RubyOnRun::VirtualMachine

  include InstructionInterpretation

  DEBUG = false

  def initialize(stream)
    @code = RubyOnRun::Bytecode.load(stream).body # compiledCode
    # @vm_stack = RubyOnRun::Stack.new context
    @classes = {} # HEAP in the future
  end

  def run
    interpret RubyOnRun::Context.new(@code, nil, MainContext.new)
  end

  def interpret(context)
    while true
      instruction = context.next_instruction
      break if instruction.nil?
      instruction.print if DEBUG     
      send instruction.name, instruction.param_hash, context
      if DEBUG
        p 'top = ' + context.top.to_s if context.top
        p 'locals = ' + context.locals.to_s
        p 'binding = ' + context.binding.to_s
        p '==========='
      end      
    end
    @return_value
  end

  def invoke

  end

  def open_class(class_name, dunno1, scope)
    binding.pry
    @classes[class_name] ||= RubyOnRun::RClass.new
    @classes[class_name]
  end

  def call_under(dunno1, scope, klass)
    binding.pry
    true
  end

   class MainContext # RClass

    attr_accessor :allow_private
  
    def initialize
      @allow_private = false
    end

    # def send(meth, *args, &block)
    #   raise "Method #{meth} is not implemented yet"
    # end 

  end



end
