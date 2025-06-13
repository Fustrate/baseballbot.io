# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :data, :https
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :unsafe_inline, :https

    # CSP blocks the React DevTools extension in Firefox
    policy.script_src_elem :self, :unsafe_inline, :https if Rails.env.development?

    policy.base_uri :self
    # policy.require_trusted_types_for :script

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = -> { it.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
