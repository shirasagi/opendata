# coding: utf-8
module SS::Relation::File
  extend ActiveSupport::Concern
  extend SS::Translation

  def save_relation_file(name)
    dump name
    exit
  end

  module ClassMethods
    def belongs_to_file(name, opts = {})
      store = opts[:store_as] || "#{name.to_s.singularize}_id"
      field store, type: (opts[:type] || String)
      belongs_to name, class_name: (opts[:class_name] || "SS::File")
      permit_params "in_#{name}"

      attr_accessor "in_#{name}"
      #before_save "save_#{name}", if: ->{ send("in_#{name}").present? }
      #define_method("save_#{name}") { save_relation_file(name) }
    end
  end
end
