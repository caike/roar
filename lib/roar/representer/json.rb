require 'roar/representer'
require 'roar/representer/feature/hypermedia'
require 'representable/json'

module Roar
  module Representer
    module JSON
      def self.included(base)
        base.class_eval do
          include Representer
          include Representable::JSON

          extend ClassMethods
          include InstanceMethods # otherwise Representable overrides our #to_json.
        end
      end

      module InstanceMethods
        def from_json(document, options={})
          document = '{}' if document.nil? or document.empty?

          super
        end

        # Generic entry-point for rendering.
        def serialize(*args)
          to_json(*args)
        end

        def deserialize(*args)
          from_json(*args)
        end
      end


      module ClassMethods
        # TODO: move to instance method, or remove?
        def links_definition_options
          # FIXME: this doesn't belong into the generic JSON representer.
          {
            :collection     => true,
            :class          => Feature::Hypermedia::Hyperlink,
            :extend         => HyperlinkRepresenter,
            :exec_context   => :decorator,
          }
        end
      end


      require "representable/json/hash"
      # Represents a hyperlink in standard roar+json hash representation.
      module HyperlinkRepresenter
        include Representable::JSON::Hash
      end
    end
  end
end
