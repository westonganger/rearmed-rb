enabled = Rearmed.enabled_patches[:rails_4] == true

if defined?(ActionView) && enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_4, :link_to_confirm) == true
  ActionView::Helpers::UrlHelper.module_eval do
    def convert_options_to_data_attributes(options, html_options)
      if html_options
        html_options = html_options.stringify_keys
        html_options['data-remote'] = 'true' if link_to_remote_options?(options) || link_to_remote_options?(html_options)

        method  = html_options.delete('method')
        add_method_to_attributes!(html_options, method) if method
        
        ### CUSTOM - behave like Rails 3.2
        confirm  = html_options.delete('confirm')
        html_options['data-confirm'] = confirm if confirm

        html_options
      else
        link_to_remote_options?(options) ? {'data-remote' => 'true'} : {}
      end
    end
  end 
end

if defined?(ActiveRecord)

  ActiveRecord::Batches.module_eval do
    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_4, :find_in_relation_batches) == true
      def find_in_relation_batches(options = {})
        options.assert_valid_keys(:start, :batch_size)

        relation = self
        start = options[:start]
        batch_size = options[:batch_size] || 1000

        unless block_given?
          return to_enum(:find_in_relation_batches, options) do
            total = start ? where(table[primary_key].gteq(start)).size : size
            (total - 1).div(batch_size) + 1
          end
        end

        if logger && (arel.orders.present? || arel.taken.present?)
          logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        relation = relation.reorder(batch_order).limit(batch_size)
        #records = start ? relation.where(table[primary_key].gteq(start)).to_a : relation.to_a
        records = start ? relation.where(table[primary_key].gteq(start)) : relation

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id
          raise "Primary key not included in the custom select clause" unless primary_key_offset

          yield records

          break if records_size < batch_size

          records = relation.where(table[primary_key].gt(primary_key_offset))#.to_a
        end
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_4, :find_relation_each) == true
      def find_relation_each(options = {})
        if block_given?
          find_in_relation_batches(options) do |records|
            records.each { |record| yield record }
          end
        else
          enum_for :find_relation_each, options do
            options[:start] ? where(table[primary_key].gteq(options[:start])).size : size
          end
        end
      end
    end
  end


  if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_4, :or) == true
    module ActiveRecord
      module Querying
        delegate :or, :to => :all
      end
    end

    module ActiveRecord
      module QueryMethods
        class OrChain
          def initialize(scope)
            @scope = scope
          end

          def method_missing(method, *args, &block)
            right_relation = @scope.klass.unscoped do
              @scope.klass.send(method, *args, &block)
            end
            @scope.or(right_relation)
          end
        end

        # Post.where("id = 1").or.where("id = 2")
        # Post.where("id = 1").or.containing_the_letter_a
        # Post.where("id = 1").or(Post.where("id = 2"))
        # Post.where("id = 1").or("id = ?", 2)
        def or(opts = :chain, *rest)
          if opts == :chain
            OrChain.new(self)
          else
            left = self
            right = (ActiveRecord::Relation === opts) ? opts : klass.unscoped.where(opts, rest)

            unless left.where_values.empty? || right.where_values.empty?
              left.where_values = [left.where_ast.or(right.where_ast)]
              right.where_values = []
            end

            left = left.merge(right)
          end
        end

        # Returns an Arel AST containing only where_values
        def where_ast
          arel_wheres = []

          where_values.each do |where|
            arel_wheres << (String === where ? Arel.sql(where) : where)
          end

          return Arel::Nodes::Grouping.new(Arel::Nodes::And.new(arel_wheres)) if arel_wheres.length >= 2

          if Arel::Nodes::SqlLiteral === arel_wheres.first
            Arel::Nodes::Grouping.new(arel_wheres.first)
          else
            arel_wheres.first
          end
        end
      end
    end
  end

end
