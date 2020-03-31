module Appsignal
  # TODO this doesn't need to be a wrapper, we can extend the class
  # from the C api.
  class Span
    def initialize(namespace=nil, trace_id=nil, parent_span_id=nil)
      @ext = if trace_id && parent_span_id
               Appsignal::Extension::Span.child(trace_id, parent_span_id)
             else
               Appsignal::Extension::Span.root(namespace || '')
             end
    end

    def child
      Appsignal::Span.new(nil, trace_id, span_id)
    end

    def trace_id
      @ext.trace_id
    end

    def span_id
      @ext.span_id
    end

    def add_error(error)
      unless error.is_a?(Exception)
        Appsignal.logger.error "Appsignal::Span#add_error: Cannot add error. " \
          "The given value is not an exception: #{error.inspect}"
        return
      end
      return unless error

      backtrace = cleaned_backtrace(error.backtrace)
      @ext.add_error(
        error.class.name,
        error.message.to_s,
        backtrace ? Appsignal::Utils::Data.generate(backtrace) : Appsignal::Extension.data_array_new
      )
    end

    def set_sample_data(key, data)
      return unless key && data && (data.is_a?(Array) || data.is_a?(Hash))
      @ext.set_sample_data(
        key.to_s,
        Appsignal::Utils::Data.generate(data, true)
      )
    rescue RuntimeError => e
      Appsignal.logger.error("Error generating data (#{e.class}: #{e.message}) for '#{data.inspect}'")
    end

    def name=(value)
      @ext.set_name(value)
    end

    def []=(key, value)
      case value
      when String
        @ext.set_attribute_string(key.to_s, value)
      when Integer
        # TODO do bigint trick too
        @ext.set_attribute_int(key.to_s, value)
      when TrueClass, FalseClass
        @ext.set_attribute_bool(key.to_s, value)
      when Float
        @ext.set_attribute_double(key.to_s, value)
      else
        raise TypeError, "value needs to be a string, int, bool or float"
      end
    end

    def instrument
      yield self if block_given?
    ensure
      @ext.close
    end

    def close
      @ext.close
    end

    # Dupe of one in transaction
    def cleaned_backtrace(backtrace)
      if defined?(::Rails) && backtrace
        ::Rails.backtrace_cleaner.clean(backtrace, nil)
      else
        backtrace
      end
    end
  end
end
