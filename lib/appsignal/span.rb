module Appsignal
  class Span
    def initialize(name, trace_id=nil, parent_span_id=nil)
      @ext = if trace_id && parent_span_id
               Appsignal::Extension::Span.child(name, trace_id, parent_span_id)
             else
               Appsignal::Extension::Span.root(name)
             end
    end

    def trace_id
      @ext.trace_id
    end

    def span_id
      @ext.span_id
    end

    def []=(key, value)

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
