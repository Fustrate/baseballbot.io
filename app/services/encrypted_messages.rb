# frozen_string_literal: true

class EncryptedMessages
  delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

  protected

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(
      ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:encrypted_messages, :key)).generate_key(
        Rails.application.credentials.dig(:encrypted_messages, :salt),
        ActiveSupport::MessageEncryptor.key_len
      )
    )
  end
end
