require 'formula'

class ApcPhp < Formula
  homepage 'http://pecl.php.net/package/apc'
  url 'http://pecl.php.net/get/APC-3.1.9.tgz'
  md5 'a2cf7fbf6f3a87f190d897a53260ddaa'

  depends_on 'pcre'

  def patches
    # fixes "PHP Fatal error:  Unknown: apc_fcntl_unlock failed: in Unknown on line 0"
    # this has been fixed in the APC trunk but has not been released yet (as of 3.1.9)
    # https://bugs.php.net/bug.php?id=59750
    DATA
  end

  def install
    Dir.chdir "APC-#{version}" do
      system "phpize"
      system "./configure", "--prefix=#{prefix}", "--enable-apc-pthreadmutex"
      system "make"

      prefix.install %w(modules/apc.so apc.php)
    end
  end

  def caveats; <<-EOS.undent
    To finish installing apc-php:
      * Add the following lines to #{etc}/php.ini:
        [apc]
        extension="#{prefix}/apc.so"
        apc.enabled=1
        apc.shm_segments=1
        apc.shm_size=64M
        apc.ttl=7200
        apc.user_ttl=7200
        apc.num_files_hint=1024
        apc.mmap_file_mask=/tmp/apc.XXXXXX
        apc.enable_cli=1
      * Restart your webserver.
      * Write a PHP page that calls "phpinfo();"
      * Load it in a browser and look for the info on the apc module.
      * If you see it, you have been successful!
      * You can copy "#{prefix}/apc.php" to any site to see APC's usage.
    EOS
  end
end

__END__
diff --git a/APC-3.1.9/apc_lock.h b/APC-3.1.9/apc_lock.h
index 77f66d5..aafa3b7 100644
--- a/APC-3.1.9/apc_lock.h
+++ b/APC-3.1.9/apc_lock.h
@@ -154,7 +154,7 @@
 # define apc_lck_nb_lock(a)    apc_fcntl_nonblocking_lock(a TSRMLS_CC)
 # define apc_lck_rdlock(a)     apc_fcntl_rdlock(a TSRMLS_CC)
 # define apc_lck_unlock(a)     apc_fcntl_unlock(a TSRMLS_CC)
-# define apc_lck_rdunlock(a)   apc_fcntl_unlock(&a TSRMLS_CC)
+# define apc_lck_rdunlock(a)   apc_fcntl_unlock(a TSRMLS_CC)
 #endif
 
 #endif
