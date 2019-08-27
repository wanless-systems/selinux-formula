selinux:
  state: enforcing
  type: targeted
  booleans.enabled:
    - httpd_can_network_connect_db
  booleans.disabled:
    - httpd_can_network_connect
  ports:
    ssh:
      tcp:
        - 2224
  ports.absent:
    ssh:
      tcp:
        - 2223
  fcontext:
    /var/www/test.org/statics(/.*)?:
      user: system_u
      type: httpd_sys_rw_content_t
  fcontext.absent:
    - /var/www/test.org/src(/.*)?
    - /var/www/test.org/tests

  restoreconf:
    -
      name: /var/www/
      recursive: true
      force: true

  modules:
    gitlabsshkeygen:
      version: 1.0
      plain: |
        module gitlabsshkeygen 1.0;

        require {
    	type ssh_keygen_t;
    	type init_tmp_t;
    	class file { read open };
        }

        #============= ssh_keygen_t ==============
        allow ssh_keygen_t init_tmp_t:file open;

    gitlabnginx:
      version: 1.0
      plain: |
        module gitlabnginx 1.0;

        require {
    	type httpd_t;
    	type user_home_t;
    	type init_t;
    	type user_home_dir_t;
    	class sock_file write;
    	class unix_stream_socket connectto;
    	class file { read open };
    	class dir { search getattr };
        }

        #============= httpd_t ==============
        allow httpd_t init_t:unix_stream_socket connectto;

        #!!!! This avc can be allowed using one of the these booleans:
        #     httpd_read_user_content, httpd_enable_homedirs
        allow httpd_t user_home_dir_t:dir search;

        #!!!! This avc can be allowed using one of the these booleans:
        #     httpd_read_user_content, httpd_enable_homedirs
        allow httpd_t user_home_t:dir { search getattr };

        #!!!! This avc can be allowed using the boolean 'httpd_read_user_content'
        allow httpd_t user_home_t:file { read open };
        allow httpd_t user_home_t:sock_file write;
