# frozen_string_literal: true

class WithModel::Model
  # Workaround for https://github.com/Casecommons/with_model/issues/35
  def cleanup_descendants_tracking
    cache_classes = Rails.application.config.cache_classes
    if defined?(ActiveSupport::DescendantsTracker) && !cache_classes
      ActiveSupport::DescendantsTracker.clear([@model])
    elsif @model.superclass.respond_to?(:direct_descendants)
      @model.superclass.subclasses.delete(@model)
    end
  end
end

RSpec.configure { |config| config.extend(WithModel) }
