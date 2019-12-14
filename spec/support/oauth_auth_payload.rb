def oauth_auth_payload(provider)
  JSON.parse(File.read(Rails.root.join('spec/fixtures/oauth_payloads.json')))[provider]
end
