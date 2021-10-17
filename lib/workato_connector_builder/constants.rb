module WorkatoConnectorBuilder
  module Constants
    TOP_LEVEL_KEYS = [
      :title,
      :connection,
      :test,
      :actions,
      :triggers,
      :object_definitions,
      :pick_lists,
      :methods,
      :secure_tunnel,
      :webhook_keys,
    ]

    # These are the only child keys that the top level key supports
    FIRST_CHILD_LEVEL_KEYS = {
      connection: [
        :fields,
        :authorization,
        :base_uri,
      ],
    }

    # These are the only keys that every grandchild of these top level or first level keys support
    SECOND_CHILD_LEVEL_KEYS = {
      actions: [
        :title,
        :subtitle,
        :description,
        :help,
        :config_fields,
        :input_fields,
        :execute,
        :output_fields,
        :sample_output,
        :retry_on_response,
        :retry_on_request,
        :max_retries,
        :summarize_input,
        :summarize_output,
      ],
      triggers: [
        :title,
        :subtitle,
        :description,
        :help,
        :config_fields,
        :input_fields,
        :webhook_key,
        :webhook_payload_type,
        :webhook_subscribe,
        :webhook_unsubscribe,
        :webhook_notification,
        :poll,
        :dedup,
        :output_fields,
        :sample_output,
        :summarize_input,
        :summarize_output
      ],
      authorization: [
        :type,
        :client_id,
        :client_secret,
        :authorization_url,
        :token_url,
        :acquire,
        :apply,
        :refresh_on,
        :detect_on,
        :refresh,
      ],
    }
  end
end