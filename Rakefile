# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/android'

  require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'Tratto'
  app.version_code = "13"
  app.version_name = "1.0.13"
  app.package = "br.com.tratoo"
  app.api_version = '23'
  app.target_api_version = '23'
  app.archs = Rake.application.top_level_tasks.first == "device" ? ["armv7"] : ['x86']
  app.permissions = [:access_network_state, :write_external_storage,:read_contacts, :write_contacts, :vibrate, :camera] # dont add :internet here, we already have as default
  app.resources_dirs = ["./resources"]
  main_activity = "WelcomeActivity"
  app.main_activity = main_activity
  app.main_activity = main_activity
  app.icon = "ic_launcher"
  app.manifest.child('application') do |application|
    application['android:theme'] = "@style/AppTheme.NoActionBar"
  end

  ["android.hardware.camera",
    "android.hardware.camera.autofocus",
    "android.hardware.camera.flash"].each do |feature_name|
    app.manifest.add_child('uses-feature') do |feature|
      feature['android:name'] = feature_name
      feature['android:required'] = 'false'
    end
  end

  # If we use "app.sub_activities", we cant define custom themes for each activity, so we need to do manually:
  %w(MainActivity ProfileActivity).each do |activity_name|
    app.manifest.child('application').add_child('activity') do |sub_activity|
  
      sub_activity['android:name'] = "#{activity_name}"
      sub_activity['android:screenOrientation'] = "portrait"
      sub_activity['android:label'] = "#{activity_name}"
      sub_activity['android:windowSoftInputMode'] = "adjustPan"
      sub_activity['android:parentActivityName'] = -> { main_activity }
      sub_activity.add_child('meta-data') do |meta|
        meta['android:name'] = 'android.support.PARENT_ACTIVITY'
        meta['android:value'] = main_activity
      end
    end
  end
  app.manifest.child('application').add_child('meta-data') do |meta_data|
    meta_data['android:name'] = "com.facebook.sdk.ApplicationId"
    meta_data['android:value'] = "@string/facebook_app_id"
  end
  
  app.manifest.child('application').add_child('activity') do |activity|
    activity['android:name'] = "com.facebook.FacebookActivity"
    activity['android:configChanges'] = "keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    activity['android:theme'] = "@android:style/Theme.Translucent.NoTitleBar"
    activity['android:label'] = "@string/app_name"
  end
  
  app.manifest.child('application').add_child('activity') do |activity|
    activity['android:name'] = "com.facebook.CustomTabActivity"
    activity['android:exported'] = "true"
    
    activity.add_child('intent-filter') do |intent|
      intent.add_child('action') { |action| action['android:name'] = 'android.intent.action.VIEW' }
      intent.add_child('category') { |category| category['android:name'] = 'android.intent.category.DEFAULT' }
      intent.add_child('category') { |category| category['android:name'] = 'android.intent.category.BROWSABLE' }
      intent.add_child('data') { |data| data['android:scheme'] = '@string/fb_login_protocol_scheme' }
    end
  end

  app.manifest.child('application').add_child('activity') do |activity|
    activity['android:name'] = "io.card.payment.CardIOActivity"
    activity['android:configChanges'] = "keyboardHidden|orientation"
  end

  app.manifest.child('application').add_child('activity') do |activity|
    activity['android:name'] = "io.card.payment.DataEntryActivity"
  end
  
  app.gradle do
    dependency 'com.android.support:appcompat-v7:24.0.0'
    dependency 'com.android.support:design:24.0.0'
    dependency 'com.android.support:support-v4:24.0.0'
    dependency 'com.facebook.android:facebook-android-sdk:4.16.1'
    dependency 'com.squareup.picasso:picasso:2.5.2'
    repository 'https://jitpack.io'
    dependency 'com.github.PhilJay:MPAndroidChart:v3.0.0'
    dependency "commons-io:commons-io:+"
    dependency 'com.bozapro.circular-slider-range:library:1.2.0'
    dependency 'io.card:android-sdk:5.4.2'
  end

  app.vendor_project jar: "vendor/android-smart-image-view-1.0.0.jar"

  app.vendor_project jar: "vendor/circleimageview-2.1.0/classes.jar",
  resources: "vendor/circleimageview-2.1.0/res",
  manifest: "vendor/circleimageview-2.1.0/AndroidManifest.xml"

  app.vendor_project jar: "vendor/circleprogress-1.1.0/circleProgressClasses.jar",
  resources: "vendor/circleprogress-1.1.0/res",
  manifest: "vendor/circleprogress-1.1.0/AndroidManifest.xml"
  
end
