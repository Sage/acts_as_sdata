# Use this method instead of just ExceptionClass.new. It adds non-nil
# backtrace and other properties

def raised_exception(exception_class, message)
  begin
    raise exception_class, message
  rescue Exception => exception_instance
    exception_instance
  end  
end
