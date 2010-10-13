module SData
  module Application
    module Traits
      ErrorHandling = Trait.new do
        def log_exception(exception)
          logger.info "<#{exception.class}> #{exception.to_s} [#{request.path.inspect}]"
          backtrace = exception.backtrace.reject { |trace_element| trace_element.starts_with?('/usr') or trace_element.starts_with?('(') }
          logger.info backtrace.join("\n")
        end
        
        error do
          exception = request.env['sinatra.error']
          log_exception(exception)

          error_payload = SData::Diagnosis::DiagnosisMapper.map(exception, request.path)
          status error_payload.send('http_status_code') || '500'          
          error_payload.to_xml(:root).to_s
        end
      end
    end
  end
end

