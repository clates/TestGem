$config = {
    :baseUrl => "http://10.2.2.6",
    :appRoot => "applet-container",
      :mongo => {
          :ip => "10.2.2.2",
        :port => 27017
    },
    :general => {
                            :screenshots_directory => "screenshots",
                                    :implicit_wait => 1,
                               :wait_until_timeout => 20,
        :print_custom_wait_failures_after_attempts => 10,
                         :max_custom_wait_attempts => 45,
                       :custom_wait_sleep_interval => 0.5
    }
}