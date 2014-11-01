module InstructionInterpretation

  def method_missing(meth, *args, &block)
    raise "It is not defined how to interpret #{meth} with args #{args}"
  end

  def noop(args)
  
  end
  
  def push_nil(args)
    @current_stack_frame.push(nil)
  end
  
  def push_true(args)
    @current_stack_frame.push(true)
  end
  
  def push_false(args)
    @current_stack_frame.push(false)
  end
  
  def push_int(args)
    @current_stack_frame.push(args[0])
  end
  
  def push_self(args)
    # TODO
  end
  
  def set_literal(args)
    @current_stack_frame.pop
    literal = @current_stack_frame.literals[args[0]]
    @current_stack_frame.push(literal)
  end
  
  def push_literal(args)
    literal = @current_stack_frame.literals[args[0]]
    @current_stack_frame.push(literal)
  end
  
  def goto(args)
    @current_stack_frame.bytecode_pointer = args[0]
  end
  
  def goto_if_false(args)
    top = @current_stack_frame.pop
    @current_stack_frame.bytecode_pointer = args[0] if top.nil? || !top
  end
  
  def goto_if_true(args)
    top = @current_stack_frame.pop
    @current_stack_frame.bytecode_pointer = args[0] if !top.nil? && top
  end
  
  def ret(args)
    top = @current_stack_frame.pop
    if !@current_stack_frame.parent.nil?  
      @current_stack_frame.parent.push(top)
      @current_stack_frame = @current_stack_frame.parent
    else
	  # TODO: save the return value somewhere 
      @current_stack_frame = nil	  
    end
  end
  
  def swap_stack(args)
    top1 = @current_stack_frame.pop
    top2 = @current_stack_frame.pop
    @current_stack_frame.push(top1)
    @current_stack_frame.push(top2)
  end
  
  def dup_top(args)
    top = @current_stack_frame.top
	if top.class.name == "NilClass" || top.class.name == "FalseClass" || top.class.name == "TrueClass" || top.class.name == "Fixnum"
      @current_stack_frame.push(top) 
    else
	  @current_stack_frame.push(top.clone)    
	end
  end
  
  def dup_many(args)
    top_x = []
    args[0].times { top_x.push(@current_stack_frame.pop) }  
    top_x.reverse!
    top_x.each do |x|
      if x.class.name == "NilClass" || x.class.name == "FalseClass" || x.class.name == "TrueClass" || x.class.name == "Fixnum"	 
	    @current_stack_frame.push(x)
	  else
	    @current_stack_frame.push(x.clone)
      end		
    end
    top_x.each { |x| @current_stack_frame.push(x) }
  end
  
  def pop(args)
    @current_stack_frame.pop
  end
  
  def pop_many(args)
    args[0].times @current_stack_frame.pop
  end
  
  def rotate(args)
    top_x = []
    args[0].times { top_x.push(@current_stack_frame.pop) }
    top_x.each { |x| @current_stack_frame.push(x) } 
  end
  
  def move_down(args)
    top = @current_stack_frame.pop
    top_x = []
    args[0].times { top_x.push(@current_stack_frame.pop) }
    @current_stack_frame.push(top)
    top_x.reverse!
    top_x.each { |x| @current_stack_frame.push(x) }   
  end
  
  def set_local(args)
    @current_stack_frame.locals[args[0]] = @current_stack_frame.top
  end 
  
  def push_local(args)
    @current_stack_frame.push(@current_stack_frame.locals[args[0]])
  end 
  
  def push_local_depth(args)
    frame = @current_stack_frame
	args[0].times { frame = frame.parent }
	keys = frame.locals.keys
	@current_stack_frame.push(frame.locals[keys[args[1]]])
  end 

  def set_local_depth(args)
    frame = @current_stack_frame
	args[0].times { frame = frame.parent }
	key = frame.locals.keys[args[1]]
	frame.locals[key] = @current_stack_frame.top
  end
  
  def passed_arg(args)
  
  end
  
  def push_current_exception(args)
  
  end
  
  def clear_exception(args)
  
  end
  
  def push_exception_state(args)
  
  end
  
  def restore_exception_state(args)
  
  end
  
  def raise_exc(args)
  
  end
  
  def setup_unwind(args)
  
  end
  
  def pop_unwind(args)
  
  end
  
  def raise_return(args)
  
  end
  
  def ensure_return(args)
  
  end
  
  def raise_break(args)
  
  end
  
  def reraise(args)
  
  end

  def make_array(args)
    a = []
    args[0].times a.push(@current_stack_frame.pop)
    a.reverse!
    @current_stack_frame.push(a)
  end
  
  def cast_array(args)
    # TODO
  end

  def shift_array(args)
    a = @current_stack_frame.pop
    first = a.shift
    @current_stack_frame.push(a)
    @current_stack_frame.push(first)  
  end 
end