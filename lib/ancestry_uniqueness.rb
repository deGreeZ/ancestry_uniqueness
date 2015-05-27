require "ancestry_uniqueness/version"

class AncestryUniquenessValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    exclude_self = record.try(:id) ? ["#{record.class.table_name}.id <> ?", record.id] : []
    scope_opts = [*options[:scope]]

    scope = scope_opts.inject({}) do |s, attr|
      s.merge({attr.to_sym => record.send(attr)})
    end

    if record.siblings.where(exclude_self).where(scope.merge({attribute.to_sym => record.send(attribute)})).any?
      record.errors.add(attribute, options[:message] || :taken)
    end
  end

end
