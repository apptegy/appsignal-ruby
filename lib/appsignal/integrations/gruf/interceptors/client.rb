# frozen_string_literal: true

module Appsignal
  module Integrations
    module Gruf
      module Interceptors
        class Client < ::Gruf::Interceptors::ClientInterceptor
          def call(request_context:)
            yield
          rescue Exception => e
            Appsignal.send_error(e) do |transaction|
              transaction.set_tags(trace_data) if opentelemetry?
              transaction.set_tags(method: request_context.method)
            end

            raise e
          end

          private

          def opentelemetry?
            defined?(OpenTelemetry)
          end

          def trace_data
            ctx = OpenTelemetry::Trace.current_span.context
            trace_id = ctx.trace_id.unpack1("H*")
            span_id = ctx.span_id.unpack1("H*")

            { trace_id: trace_id, span_id: span_id }
          end
        end
      end
    end
  end
end
