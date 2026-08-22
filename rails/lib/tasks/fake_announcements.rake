# frozen_string_literal: true

namespace :fake_data do
  desc 'Seeds fake announcements and a demo user for browser testing'
  task seed: :environment do
    auth = Rails.application.config.auth
    announcements_facade = Rails.application.config.announcements

    demo_email = 'demo@example.com'
    demo_password = 'Password123!'

    puts "==> Ensuring demo user (#{demo_email}) exists..."
    begin
      auth.sign_up(demo_email, demo_password)
      puts "    Created demo user #{demo_email}"
    rescue Auth::Errors::DuplicatedEmailError
      puts "    Demo user #{demo_email} already exists"
    end

    sign_in_res = auth.sign_in(demo_email, demo_password)
    user_id = auth.authenticate(sign_in_res.access_token).user_id.to_s

    fake_items = [
      # Warsaw cluster (Lat: ~52.23, Lon: ~21.01)
      {
        title: 'Lost Golden Retriever (Max)',
        content: 'Friendly golden retriever lost near Saxon Garden. Wearing a blue collar with a bell.',
        latitude: 52.2396,
        longitude: 21.0048,
        publish: true
      },
      {
        title: 'Found Tabby Cat near Old Town',
        content: 'Small green-eyed tabby found wandering near the Royal Castle. Very gentle.',
        latitude: 52.2479,
        longitude: 21.0142,
        publish: true
      },
      {
        title: 'Lost Persian Cat (Luna)',
        content: 'White fluffy Persian cat escaped from balcony in Mokotów. Shy, please do not chase.',
        latitude: 52.2023,
        longitude: 21.0210,
        publish: true
      },
      {
        title: 'Found Young Husky near Vistula River',
        content: 'Energetic black/white husky found playing near Bulwary Wiślane without a leash.',
        latitude: 52.2412,
        longitude: 21.0321,
        publish: true
      },

      # London cluster (Lat: ~51.50, Lon: ~-0.12)
      {
        title: 'Lost Beagle in Hyde Park',
        content: 'Tri-color beagle ran off chasing squirrels near the Serpentine. Microchipped.',
        latitude: 51.5073,
        longitude: -0.1657,
        publish: true
      },
      {
        title: 'Found Dwarf Rabbit in Camden',
        content: 'Grey and white dwarf bunny found in a backyard garden in Camden Town.',
        latitude: 51.5390,
        longitude: -0.1426,
        publish: true
      },
      {
        title: 'Lost Ginger Cat (Oliver)',
        content: 'Very vocal ginger cat missing around Soho / Covent Garden. Needs daily medicine.',
        latitude: 51.5136,
        longitude: -0.1312,
        publish: true
      },

      # New York cluster (Lat: ~40.71, Lon: ~-74.00)
      {
        title: 'Lost French Bulldog (Buster)',
        content: 'Fawn Frenchie lost near Washington Square Park. Reward offered!',
        latitude: 40.7308,
        longitude: -73.9973,
        publish: true
      },
      {
        title: 'Found Cockatiel in Brooklyn',
        content: 'Yellow cockatiel flew onto our balcony in Williamsburg. Whistles tunes.',
        latitude: 40.7081,
        longitude: -73.9571,
        publish: true
      },

      # Paris (Lat: ~48.85, Lon: ~2.35)
      {
        title: 'Lost Black Cat (Minou)',
        content: 'All black cat with yellow eyes lost near Montmartre steps.',
        latitude: 48.8867,
        longitude: 2.3431,
        publish: true
      },

      # Draft announcements (for "My Announcements" view)
      {
        title: 'Draft: Missing Hamster',
        content: 'Escaped somewhere in the living room, still searching.',
        latitude: 52.2500,
        longitude: 21.0500,
        publish: false
      }
    ]

    puts "==> Creating #{fake_items.size} announcements for #{demo_email}..."
    created_count = 0
    published_count = 0

    fake_items.each do |item|
      draft = announcements_facade.add_new_draft(user_id)
      announcements_facade.update_title(user_id, draft.id, item[:title])
      announcements_facade.update_content(user_id, draft.id, item[:content])
      announcements_facade.update_location(
        user_id,
        draft.id,
        { latitude: item[:latitude], longitude: item[:longitude] }
      )

      if item[:publish]
        announcements_facade.publish(user_id, draft.id)
        published_count += 1
        puts "    [Published] #{item[:title]} at (#{item[:latitude]}, #{item[:longitude]})"
      else
        puts "    [Draft]     #{item[:title]}"
      end
      created_count += 1
    end

    puts ''
    puts '=' * 60
    puts ' Fake data generation complete!'
    puts " - Total created:   #{created_count}"
    puts " - Total published: #{published_count}"
    puts ''
    puts ' Demo Credentials for Browser Sign-in:'
    puts "   Email:    #{demo_email}"
    puts "   Password: #{demo_password}"
    puts '=' * 60
  end
end
