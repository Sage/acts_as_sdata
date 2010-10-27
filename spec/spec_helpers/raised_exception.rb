# call-seq:
#   raised_exception(RuntimeError, 'Big Bada Boom') => #<RuntimeError:Big Bada Boom>
#
# Use this method instead of just ExceptionClass.new.
# It adds non-nil backtrace and other necessary properties

def raised_exception(exception_class, message)
  begin
    raise exception_class, message
  rescue Exception => exception_instance
    exception_instance
  end  
end
