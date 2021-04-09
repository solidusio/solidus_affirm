FactoryBot.modify do
  factory :address do
    if SolidusSupport.combined_first_and_last_name_in_address?
      transient do
        firstname { "John" }
        lastname { "Doe" }
      end

      name { "#{firstname} #{lastname}" }
    end
  end
end
