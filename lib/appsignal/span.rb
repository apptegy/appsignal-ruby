module Appsignal
  # TODO this doesn't need to be a wrapper, we can extend the class
  # from the C api.
  class Span
    def initialize(name, trace_id=nil, parent_span_id=nil)
      @ext = if trace_id && parent_span_id
               Appsignal::Extension::Span.child(name, trace_id, parent_span_id)
             else
               Appsignal::Extension::Span.root(name)
             end
    end

    def child(name)
      Appsignal::Span.new(name, trace_id, span_id)
    end

    def trace_id
      @ext.trace_id
    end

    def span_id
      @ext.span_id
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
  end
end
