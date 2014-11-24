# main class
class RubyOnRun::VirtualMachine

  include InstructionInterpretation

  def initialize(stream)
    @stream = stream

    @code = RubyOnRun::Bytecode.load(@stream).body    
    @classes = []
    # initialize other things ...    
  end

  def run
    interpret(@code, nil, nil)
  end

  def interpret(code, scope, klass)
    @current_stack_frame = RubyOnRun::StackFrame.new(@code)
    @vm_stack = RubyOnRun::Stack.new @current_stack_frame
    debug = false
    while @current_stack_frame
      instruction = @current_stack_frame.next_instruction
      instruction.print if debug     
      send instruction.name, instruction.param_hash
      if debug
        p 'top = ' + @current_stack_frame.top.to_s if @current_stack_frame.top
        p 'locals = ' + @current_stack_frame.locals.to_s
		p 'binding = ' + @current_stack_frame.binding.to_s
        p '==========='
      end      
    end

    @return_value
  end

  def open_class(scope, dunno1, class_name)
    @current_stack_frame.binding[class_name] = RubyOnRun::RClass.new
  end

  # def call_under(dunno1, scope, klass)
  #   binding.pry
  #   true
  # end

end
