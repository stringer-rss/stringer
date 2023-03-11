# frozen_string_literal: true

module FeverAPI::Response
  ACTIONS = [
    FeverAPI::Authentication,
    FeverAPI::ReadFeeds,
    FeverAPI::ReadGroups,
    FeverAPI::ReadFeedsGroups,
    FeverAPI::ReadFavicons,
    FeverAPI::ReadItems,
    FeverAPI::ReadLinks,
    FeverAPI::SyncUnreadItemIds,
    FeverAPI::SyncSavedItemIds,
    FeverAPI::WriteMarkItem,
    FeverAPI::WriteMarkFeed,
    FeverAPI::WriteMarkGroup
  ].freeze

  def self.call(params)
    result = { api_version: FeverAPI::API_VERSION }
    ACTIONS.each { |action| result.merge!(action.call(**params)) }
    result.to_json
  end
end
