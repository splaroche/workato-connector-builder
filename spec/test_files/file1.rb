{
  :title => 2,
  :connection => {
    fields: [
      'a field'
    ],
    invalid_key: 'this is invalid!',
    authorization: {
      'type': 'soemthihgn',
      :token_url => 'something else',
      :invalid_key => 'another invalid key!'
    },
  },
  :triggers => {
    trigger_one: {
      invalid_key: 'invaluid!',
      :poll => lambda do
      end,
      'subtitle' => 'a subtitle',
      :title => 'a title of a thing!'
    }
  }
}