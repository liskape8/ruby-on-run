require_relative './builtin'

module RubyOnRun::Builtin
  class RRange
    
    include RubyOnRun::Builtin::Builtin
    extend RubyOnRun::Builtin::Builtin

    def new(*args)
      
    end

    def self.allocate()
      new
    end
  end
end
