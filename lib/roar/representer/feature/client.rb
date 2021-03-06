require "roar/representer/feature/http_verbs"

module Roar
  # Automatically add accessors for properties and collections. Also mixes in HttpVerbs.
  module Representer
    module Feature
      module Client
        include HttpVerbs

        def self.extended(base)
          base.instance_eval do
            representable_attrs.each do |attr|
              name = attr.name
              next if name == "links" # ignore hyperlinks.

              # TODO: could anyone please make this better?
              instance_eval %Q{
                def #{name}=(v)
                  @#{name} = v
                end

                def #{name}
                  @#{name}
                end
              }
            end
          end
        end

        def to_hash(options={})
          options[:links] ||= false
          super(options)
        end

        def to_xml(options={}) # sorry, but i'm not even sure if anyone uses this module.
          options[:links] ||= false
          super(options)
        end
      end
    end
  end
end
