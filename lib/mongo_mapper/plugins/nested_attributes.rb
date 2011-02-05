# this is minimal version of accepts_nested_attributes_for for MongoMapper
# no options, not tested on embedded documents, tested for 'many' associations
# based on https://github.com/tjtuom/mm-nested-attributes/blob/master/lib/mongo_mapper/plugins/associations/nested_attributes.rb
# and https://gist.github.com/d313817a57fd079e4df7
#
# TODO: add options
# TODO: make it work for all association types
# TODO: make it work for embedded documents
# TODO: add tests and make them pass!



module MongoMapper
  module Plugins
    module NestedAttributes
      extend ActiveSupport::Concern



      # CLASS METHODS
      
      module ClassMethods

        def accepts_nested_attributes_for(association_name)
          class_eval %{
            if method_defined?(:#{association_name}_attributes=)
              remove_method(:#{association_name}_attributes=)
            end
            def #{association_name}_attributes=(attributes)
              assign_nested_attributes_for_many_association(:#{association_name}, attributes)
            end
          }, __FILE__, __LINE__
        end

      end



      # INSTANCE METHODS
      
      module InstanceMethods
        
        private
        
        UNASSIGNABLE_KEYS = %w( id _destroy )
        
        # MANY ASSOCIATION
        
        def assign_nested_attributes_for_many_association(association_name, attributes_collection)
          
          unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
            raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
          end
          
          if attributes_collection.is_a? Hash
            attributes_collection = attributes_collection.sort_by{ |index, _| index.to_i }.map{ |_, attributes| attributes }
          end

          attributes_collection.each do |attributes|
            attributes = attributes.with_indifferent_access
            if attributes['id'].blank?
              add_new_to_association(association_name, attributes) unless has_destroy_flag?(attributes)                            
            elsif existing_record = find_existing_record(association_name, attributes)
              if has_destroy_flag?(attributes) 
                destroy_existing_record(association_name, existing_record) 
              else 
                assign_to_existing_record(existing_record, attributes)
              end
            end
          end
          
        end
        
        
        
        def add_new_to_association(association_name, attributes)
          send(association_name).build( attributes.except(*UNASSIGNABLE_KEYS) )
        end

        def find_existing_record(association_name, attributes)
          send(association_name).detect{ |record| record.id.to_s == attributes['id'].to_s }
        end
        
        def assign_to_existing_record(existing_record, attributes)
          existing_record.attributes = attributes.except(*UNASSIGNABLE_KEYS)
        end
        
        def destroy_existing_record(association_name, existing_record)
          if existing_record.class.embeddable?
            send(association_name).delete(existing_record)
          else
            send(association_name).destroy_all(:id => existing_record.id)
          end
        end
        
        def has_destroy_flag?(hash)
          true_values = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set
          hash['_destroy'].present? && true_values.include?(hash['_destroy'])
        end
        
        
      end
      
    end
  end
end