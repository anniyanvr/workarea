module Workarea
  class Segment
    module Rules
      class BrowserInfo < Base
        field :general, type: Array, default: []
        field :device, type: Array, default: []
        field :platform, type: Array, default: []

        def qualifies?(visit)
          return false if general.blank? && device.blank? && platform.blank?

          general_match?(visit.browser) ||
            device_match?(visit.browser) ||
            platform_match?(visit.browser)
        end

        def general_match?(browser)
          general.blank? || general.any? { |g| browser.try("#{g}?") }
        end

        def device_match?(browser)
          device.blank? || device.any? { |d| browser.device.try("#{d}?") }
        end

        def platform_match?(browser)
          platform.blank? || platform.any? { |p| browser.platform.try("#{p}?") }
        end
      end
    end
  end
end
