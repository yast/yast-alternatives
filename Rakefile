require "yast/rake"

Yast::Tasks.configuration do |conf|
  conf.obs_api = "https://api.opensuse.org"
  conf.obs_target = "openSUSE_Leap_15.4"
  conf.obs_sr_project = "openSUSE:Leap:15.4:Update"
  conf.obs_project = "YaST:openSUSE:15.4"

  conf.skip_license_check << /doc/
  conf.skip_license_check << /.*desktop$/
end
