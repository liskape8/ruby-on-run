module RubyOnRun::VM::InstructionInterpretation

  attr_accessor :return_value

  def method_missing(meth, *args, &block)
    raise "It is not defined how to interpret #{meth} with args #{args}"
  end

  def noop(args, context)
  end
  
  def push_nil(args, context)
    context.push(nil)
  end
  
  def push_true(args, context)
    context.push(true)
  end
  
  def push_false(args, context)
    context.push(false)
  end
  
  def push_int(args, context)
    context.push RubyOnRun::Builtin::RFixnum.new(args[:number])
  end
  
  def push_self(args, context)
    context.push context.self
  end
  
  def set_literal(args, context)
    context.pop
    literal = context.literals[args[:literal]]
    context.push(literal)
  end
  
  def push_literal(args, context)
    literal = context.literals[args[:literal]]
    if literal.is_a? String
      context.push RubyOnRun::Builtin::RString.new(literal)
    else
      # symbols
      context.push(literal)
    end
  end
  
  def goto(args, context)
    context.bytecode_pointer = args[:location]
    @jump = true
  end
  
  def goto_if_false(args, context)
    top = context.pop
    if top.nil? || !top
      context.bytecode_pointer = args[:location]
      @jump = true
    end
  end
  
  def goto_if_true(args, context)
    top = context.pop
    if !top.nil? && top
      context.bytecode_pointer = args[:location]
      @jump = true
    end
  end
  
  def ret(args, context)
    top = context.pop
    if context.parent.nil?
      @return_value = top
      context = nil
    else      
      # p 'parent top: ' + context.parent.top.to_s
      context.parent.push(top)      
    end
  end
  
  def swap_stack(args, context)
    top1 = context.pop
    top2 = context.pop
    context.push(top1)
    context.push(top2)
  end
  
  def dup_top(args, context)
    top = context.top
    context.push(top)
  end
  
  def dup_many(args, context)
    top_x = []
    args[:count].times { top_x.push(context.pop) }  
    top_x.reverse!
    2.times { top_x.each { |x| context.push(x) } }		
  end
  
  def pop(args, context)
    context.pop
  end
  
  def pop_many(args, context)
    args[:count].times context.pop
  end
  
  def rotate(args, context)
    top_x = []
    args[:count].times { top_x.push(context.pop) }
    top_x.each { |x| context.push(x) } 
  end
  
  def move_down(args, context)
    top = context.pop
    top_x = []
    args[:positions].times { top_x.push(context.pop) }
    context.push(top)
    top_x.reverse!
    top_x.each { |x| context.push(x) }   
  end
  
  def set_local(args, context)
    context.binding[context.locals[args[:local]]] = context.top
  end 
  
  def push_local(args, context)
    context.push context.binding[context.locals[args[:local]]]
  end 
  
  def push_local_depth(args, context)
    ancestor_context = context
    args[:depth].times { ancestor_context = ancestor_context.parent }
    context.push(ancestor_context.binding[ancestor_context.locals[args[:index]]])
    # p 'binding in ancestor context: ' + ancestor_context.binding.to_s
  end 

  def set_local_depth(args, context)
    ancestor_context = context
    args[:depth].times { ancestor_context = ancestor_context.parent }
    ancestor_context.binding[ancestor_context.locals[args[:index]]] = context.top
    # p 'binding in ancestor context: ' + ancestor_context.binding.to_s
  end
  
  def make_array(args, context)
    a = RubyOnRun::Builtin::RArray.new
    args[:count].times { a.push(context.pop) }
    a.reverse!
    context.push(a)
  end
  
  def cast_array(args, context)
    # TODO
  end

  def shift_array(args, context)
    a = context.pop
    first = a.shift
    context.push(a)
    context.push(first)  
  end

  def set_ivar(args, context)
    top = context.top
    name = context.literals[args[:literal]]    
    context.self.set_instance_variable(name, top)
  end

  def push_ivar(args, context)
    var_name = context.literals[args[:literal]]
    context.push context.self.get_instance_variable(var_name)
  end  
  
  def push_const(args, context)
    if context.constants.keys.include?(context.literals[args[:literal]])
      context.push(context.constants[context.literals[args[:literal]]])
	else
	  # TODO push NameError 
	end
  end
  
  def set_const(args, context)
    context.constants[context.literals[args[:literal]]] = context.top
  end
  
  def set_const_at(args, context)
    top = context.pop
    mod = context.pop
    mod.send(context.literals[args[:literal]].to_s + "=", top)
    context.push(top)
  end
  
  def find_const(args, context)
    mod = context.pop
    if mod.methods.include?(context.literals[args[:literal]])
      # this means constant registered inside this module
      context.push(mod.send(context.literals[args[:literal]]))
    else
      #go up
      context.push context.literals[args[:literal]]
    # else
      # TODO push NameError
    end
  end

  def push_cpath_top(args, context)
    context.push(context.self)
  end

  def find_const_fast(args, context)
    find_const(args, context)
  end

  def meta_push_0(args, context)
    context.push(0)
  end

  def meta_push_1(args, context)
    context.push(1)
  end

  def meta_push_2(args, context)
    context.push(2)
  end

  def meta_push_neg_1(args, context)
    context.push(-1)
  end

  def string_dup(args, context)
    top = context.pop
    context.push(top.clone)
  end

  def allow_private(args, context)
    context.self.allow_private = true
  end

  def push_rubinius(args, context)
    context.push self # VirtualMachine takes care of this
  end

  def push_scope(args, context)
    # what can be scope? 
    context.push context.current_class
  end

  def add_scope(args, context)
    _module = context.pop
    context.current_class = _module
  end

  def push_stack_local(args, context)
    true
  end

  # Push the VariableScope for the current method/block invocation on the stack.
  def push_variables(args, context)
    context.push context.current_class
  end

  def create_block(args, context)
    code = context.literals[args[:literal]]
    context.push RubyOnRun::VM::BlockEnvironment.new(code, self, context)
  end

  def send_stack_with_block(args, parameters = [], context)
    debug = false
    block = context.pop
    args[:count].times { parameters << context.pop}
    receiver = context.pop
    message  = context.literals[args[:literal]]    
    receiver = resolve_receiver(receiver, context)    
    parameters = resolve_parameters(parameters, context)
    if debug
      p 'block = ' + block.to_s
      p 'receiver = ' + receiver.to_s 
      p 'parameters = ' + parameters.to_s
      p 'message = ' + message.to_s
    end
    result = if receiver.is_a? RubyOnRun::VM::RObject
      # heavy lifting here
      # method lookup and shit
      code = receiver.klass.method(message)
      new_context = RubyOnRun::VM::Context.new(code, receiver.klass, receiver, context, {})
      interpret(new_context)
    else
      # primitive for now
      # p receiver.methods
      receiver.send(message, *parameters)
    end
    p 'result = ' + result.to_s if debug 
    evaluate_block(result, parameters, block)
    context.push result
  end

  def send_stack(args, parameters = [], context)
    debug = false
    args[:count].times { parameters << context.pop}
    receiver = context.pop
    message  = context.literals[args[:literal]]


    receiver = resolve_receiver(receiver, context)    
    parameters = resolve_parameters(parameters, context)
    if debug
      p 'receiver = ' + receiver.to_s 
      p 'parameters = ' + parameters.to_s
      p 'message = ' + message.to_s
    end

    if receiver.is_a? RubyOnRun::Builtin
      binding.pry
      true
    elsif receiver.is_a?(RubyOnRun::VM::VirtualMachine) || receiver.is_a?(RubyOnRun::VM::BlockEnvironment)
      context.push receiver.send(message, *parameters)
    else
      code = receiver.get_singleton_method(message)
      code ||= find_method_in_chain(receiver.klass, message, context)

      _binding = create_binding(code, parameters)
      new_context = RubyOnRun::VM::Context.new(code, receiver.klass, receiver, context, _binding)
      interpret(new_context) # result is pushed on parent context stack in ret instruction
    end
  end

  # not in rubinius
  def native_code(args, context)
    # in future NativeCompiledCode will have this instruction + ret
    # maybe send to kernel or something
    context.push context.compiled_code.method.call(*context.binding.values.compact)
  end

  private

  # called as native code from ParentObject
  def method_visibility(arg)
    true
  end

  def find_method_in_chain(klass, method_name, context)
    raise "No method error #{method_name}" if klass.nil?

    if klass.method(method_name)
      klass.method(method_name)
    else
      find_method_in_chain(resolve_receiver(klass.superklass, context), method_name, context)
    end
  end

  def create_binding(code, parameters)
    Hash[code.local_names.zip(parameters)]
  end
  
  def evaluate_block(enumerator, parameters, block)
    enumerator.each do |x|      
      new_context = RubyOnRun::VM::Context.new(block.compiled_code, nil, nil, block.parent_context, {})
      new_context.binding[new_context.locals[0]] = x      
      interpret(new_context)
    end
  end

  def resolve_parameters(parameters, context)
    parameters.map{ |p| resolve_receiver(p, context) }
    parameters.reverse!
  end

  def resolve_receiver(receiver, context)

    if receiver.is_a? Symbol
      # that means Constant
      return @classes[receiver] if receiver[0].upcase == receiver[0] #its a our class!

      while (true)
        if !context.binding.has_key?(receiver)
          context = context.parent 
        else
          break
        end        
        return nil if context.nil?
      end
      resolve_receiver(context.binding[receiver], context) || receiver
    else
      receiver
    end
  end

  def push_const_fast(args, context)
    constant = context.literals[args[:literal]]
    context.push constant
  end  
  
  def check_serial(args, context) #optimization
    context.push false
  end
end
